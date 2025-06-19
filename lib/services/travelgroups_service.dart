import 'package:supabase_flutter/supabase_flutter.dart';

class TravelGroupsService {
  final SupabaseClient supabase = Supabase.instance.client;

  // CREATE - Create a new travel group
  Future<Map<String, dynamic>?> createTravelGroup({
    required String groupName,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    required double budgetMin,
    required double budgetMax,
    required int maxMembers,
    required List<String> selectedActivities,
    bool isPrivate = false,
  }) async {
    try {
      // Enhanced user authentication check
      final user = supabase.auth.currentUser;
      if (user == null || user.id == null) {
        throw Exception('User not authenticated - please log in again');
      }

      final userId = user.id;
      print('Creating group for user ID: $userId');

      // Verify user exists in database
      final userExists = await supabase
          .from('users')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      if (userExists == null) {
        throw Exception('User profile not found in database');
      }

      // Prepare the data for insertion
      final groupData = {
        'group_name': groupName,
        'created_by': userId, // This should now be valid
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'destination': destination,
        'budget_range_min': budgetMin,
        'budget_range_max': budgetMax,
        'max_members': maxMembers,
        'is_private': isPrivate,
        'status': 'Open',
        'tags': selectedActivities.join(', '),
      };

      print('Group data to insert: $groupData');

      // Insert the group into the database
      final response = await supabase
          .from('travelgroups')
          .insert(groupData)
          .select()
          .single();

      print('Group created successfully: $response');

      // Also add the creator as the first member
      await supabase.from('group_members').insert({
        'group_id': response['group_id'],
        'user_id': userId,
        'role': 'admin',
      });

      return response;
    } catch (error) {
      print('Detailed error creating travel group: $error');

      // Provide more specific error messages
      if (error.toString().contains('foreign key constraint')) {
        throw Exception('User account verification failed. Please try logging out and back in.');
      } else if (error.toString().contains('not present in table')) {
        throw Exception('User profile not found. Please complete your profile setup.');
      } else {
        throw Exception('Failed to create travel group: $error');
      }
    }
  }
  // READ - Get all travel groups with optional filtering
  Future<List<Map<String, dynamic>>> getTravelGroups({
    String? destination,
    String? status,
    bool? isPrivate,
    int? limit,
  }) async {
    try {
      // Start with the base query
      PostgrestFilterBuilder query = supabase
          .from('travelgroups')
          .select('*');

      // Apply filters if provided
      if (destination != null && destination.isNotEmpty) {
        query = query.ilike('destination', '%$destination%');
      }

      if (status != null) {
        query = query.eq('status', status);
      }

      if (isPrivate != null) {
        query = query.eq('is_private', isPrivate);
      }

      // Build the final query with ordering and limit
      PostgrestTransformBuilder finalQuery = query.order('created_at', ascending: false);

      if (limit != null) {
        finalQuery = finalQuery.limit(limit);
      }

      final response = await finalQuery;
      print('Fetched ${response.length} travel groups');
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      print('Error fetching travel groups: $error');
      throw Exception('Failed to fetch travel groups: $error');
    }
  }

  // READ - Get a specific travel group by ID
  Future<Map<String, dynamic>?> getTravelGroupById(String groupId) async {
    try {
      final response = await supabase
          .from('travelgroups')
          .select('*, profiles:created_by(username, full_name, profile_picture)')
          .eq('group_id', groupId)
          .single();

      print('Fetched travel group: $response');
      return response;
    } catch (error) {
      print('Error fetching travel group: $error');
      throw Exception('Failed to fetch travel group: $error');
    }
  }

  // READ - Get travel groups created by current user
  Future<List<Map<String, dynamic>>> getMyTravelGroups() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await supabase
          .from('travelgroups')
          .select('*')
          .eq('created_by', userId)
          .order('created_at', ascending: false);

      print('Fetched ${response.length} groups created by user');
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      print('Error fetching user travel groups: $error');
      throw Exception('Failed to fetch user travel groups: $error');
    }
  }

  // JOIN - Join a travel group
  // Add this method to your TravelGroupsService class

  // Test database connection
  Future<bool> testConnection() async {
    try {
      final result = await supabase.from('group_members').select('count').limit(1);
      return true;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }

  // Join group with maximum error handling
  Future<void> joinTravelGroup(String groupId) async {
    print('🔄 Starting join process...');

    // Check authentication
    final user = supabase.auth.currentUser;
    if (user == null) {
      print('❌ User not authenticated');
      throw Exception('Please log in to join groups');
    }

    print('✅ User authenticated: ${user.id}');
    print('🎯 Target group: $groupId');

    try {
      // Test basic connection first
      print('🔍 Testing database connection...');
      final connectionTest = await testConnection();
      if (!connectionTest) {
        throw Exception('Database connection failed');
      }
      print('✅ Database connection OK');

      // Check if already a member (with timeout)
      print('🔍 Checking existing membership...');
      final existingCheck = await supabase
          .from('group_members')
          .select('id')
          .eq('group_id', groupId)
          .eq('user_id', user.id)
          .maybeSingle();

      if (existingCheck != null) {
        print('⚠️ Already a member');
        throw Exception('You are already a member of this group');
      }
      print('✅ Not a member yet');

      // Prepare insert data
      final insertData = {
        'group_id': groupId,
        'user_id': user.id,
        'joined_at': DateTime.now().toIso8601String(),
        'role': 'member',
      };

      print('📝 Inserting data: $insertData');

      // Insert with explicit error handling
      final insertResult = await supabase
          .from('group_members')
          .insert(insertData)
          .select('id')
          .single();

      print('✅ Successfully joined! Insert result: $insertResult');

    } catch (e) {
      print('❌ Join failed with error: $e');

      // Provide specific error messages
      final errorString = e.toString().toLowerCase();

      if (errorString.contains('infinite recursion') ||
          errorString.contains('policy')) {
        throw Exception('Database policy error. Please try again or contact support.');
      } else if (errorString.contains('permission') ||
          errorString.contains('denied')) {
        throw Exception('Permission denied. Please log out and back in.');
      } else if (errorString.contains('already') ||
          errorString.contains('duplicate')) {
        throw Exception('You are already a member of this group');
      } else if (errorString.contains('network') ||
          errorString.contains('timeout')) {
        throw Exception('Network error. Please check your connection.');
      } else {
        throw Exception('Unable to join group. Please try again.');
      }
    }
  }

  // Get group members count
  Future<int> getGroupMembersCount(String groupId) async {
    try {
      final response = await supabase
          .from('group_members')
          .select('id')
          .eq('group_id', groupId);

      return response.length;
    } catch (error) {
      print('Error getting group member count: $error');
      return 0;
    }
  }

  // Get group members
  Future<List<Map<String, dynamic>>> getGroupMembers(String groupId) async {
    try {
      final response = await supabase
          .from('group_members')
          .select('*, profiles:user_id(username, full_name, profile_picture)')
          .eq('group_id', groupId);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      print('Error getting group members: $error');
      throw Exception('Failed to get group members: $error');
    }
  }

  // UPDATE - Update a travel group
  Future<Map<String, dynamic>?> updateTravelGroup({
    required String groupId,
    String? groupName,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    double? budgetMin,
    double? budgetMax,
    int? maxMembers,
    List<String>? selectedActivities,
    bool? isPrivate,
    String? status,
  }) async {
    try {
      // Check if current user is the creator of the group
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Verify ownership
      final existingGroup = await supabase
          .from('travelgroups')
          .select('created_by')
          .eq('group_id', groupId)
          .single();

      if (existingGroup['created_by'] != userId) {
        throw Exception('You can only edit groups you created');
      }

      // Prepare update data (only include non-null values)
      final Map<String, dynamic> updateData = {};

      if (groupName != null) updateData['group_name'] = groupName;
      if (destination != null) updateData['destination'] = destination;
      if (startDate != null) updateData['start_date'] = startDate.toIso8601String();
      if (endDate != null) updateData['end_date'] = endDate.toIso8601String();
      if (budgetMin != null) updateData['budget_range_min'] = budgetMin;
      if (budgetMax != null) updateData['budget_range_max'] = budgetMax;
      if (maxMembers != null) updateData['max_members'] = maxMembers;
      if (isPrivate != null) updateData['is_private'] = isPrivate;
      if (status != null) updateData['status'] = status;
      if (selectedActivities != null) {
        updateData['tags'] = selectedActivities.join(', ');
      }

      if (updateData.isEmpty) {
        throw Exception('No data to update');
      }

      final response = await supabase
          .from('travelgroups')
          .update(updateData)
          .eq('group_id', groupId)
          .select()
          .single();

      print('Group updated successfully: $response');
      return response;
    } catch (error) {
      print('Error updating travel group: $error');
      throw Exception('Failed to update travel group: $error');
    }
  }

  // DELETE - Delete a travel group
  Future<bool> deleteTravelGroup(String groupId) async {
    try {
      // Check if current user is the creator of the group
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Verify ownership
      final existingGroup = await supabase
          .from('travelgroups')
          .select('created_by')
          .eq('group_id', groupId)
          .single();

      if (existingGroup['created_by'] != userId) {
        throw Exception('You can only delete groups you created');
      }

      // Delete group members first (foreign key constraint)
      await supabase
          .from('group_members')
          .delete()
          .eq('group_id', groupId);

      // Delete the group
      await supabase
          .from('travelgroups')
          .delete()
          .eq('group_id', groupId);

      print('Group deleted successfully');
      return true;
    } catch (error) {
      print('Error deleting travel group: $error');
      throw Exception('Failed to delete travel group: $error');
    }
  }

  // Leave a travel group
  Future<bool> leaveTravelGroup(String groupId) async {
    print('🔄 Starting leave group process...');

    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        print('❌ User not authenticated');
        throw Exception('User not authenticated');
      }

      print('✅ User authenticated: $userId');
      print('🎯 Target group: $groupId');

      // First, let's check if the user is actually a member
      print('🔍 Checking current membership...');
      final membershipCheck = await supabase
          .from('group_members')
          .select('*')
          .eq('group_id', groupId)
          .eq('user_id', userId)
          .maybeSingle();

      if (membershipCheck == null) {
        print('⚠️ User is not a member of this group');
        throw Exception('You are not a member of this group');
      }

      print('✅ Confirmed membership: $membershipCheck');

      // Check if user is the creator (creators can't leave, they must delete the group)
      print('🔍 Checking if user is group creator...');
      final group = await supabase
          .from('travelgroups')
          .select('created_by, group_name')
          .eq('group_id', groupId)
          .single();

      print('📋 Group info: $group');

      if (group['created_by'] == userId) {
        print('❌ User is the creator - cannot leave');
        throw Exception('Group creators cannot leave the group. Please delete the group instead.');
      }

      print('✅ User is not creator, can leave');

      // Now attempt to remove user from group
      print('🗑️ Removing user from group...');
      final deleteResult = await supabase
          .from('group_members')
          .delete()
          .eq('group_id', groupId)
          .eq('user_id', userId);

      print('✅ Successfully left group');
      return true;

    } catch (error) {
      print('❌ Leave group failed: $error');

      // Re-throw the error to be handled by the UI
      throw error;
    }
  }

  //1troubleshoot membership
  Future<void> debugMembershipStatus(String groupId) async {
    print('=== DEBUG MEMBERSHIP STATUS ===');

    final user = supabase.auth.currentUser;
    print('Current user: ${user?.id}');
    print('Target group: $groupId');

    if (user?.id != null) {
      try {
        // Check membership in group_members table
        final membership = await supabase
            .from('group_members')
            .select('*')
            .eq('group_id', groupId)
            .eq('user_id', user!.id);

        print('Membership records: $membership');

        // Check group details
        final groupInfo = await supabase
            .from('travelgroups')
            .select('*')
            .eq('group_id', groupId)
            .maybeSingle();

        print('Group info: $groupInfo');

        // Check all members of this group
        final allMembers = await supabase
            .from('group_members')
            .select('*')
            .eq('group_id', groupId);

        print('All group members: $allMembers');

      } catch (e) {
        print('Debug error: $e');
      }
    }
  }

  //Checking if a user is member or not
  Future<bool> isUserMemberOfGroup(String groupId) async {
    try {
      print('🔍 Checking membership for group: $groupId');

      final user = supabase.auth.currentUser;
      if (user == null) {
        print('❌ No authenticated user');
        return false;
      }

      print('👤 Checking for user: ${user.id}');

      final result = await supabase
          .from('group_members')
          .select('id, role, joined_at')
          .eq('group_id', groupId)
          .eq('user_id', user.id)
          .maybeSingle();

      print('🔍 Membership result: $result');

      final isMember = result != null;
      print('✅ Is member: $isMember');

      return isMember;
    } catch (e) {
      print('❌ Error checking membership: $e');
      return false;
    }
  }

  Future<void> debugTableStructure() async {
    try {
      final result = await supabase
          .from('group_members')
          .select('*')
          .limit(1);
      print('Table structure check successful: ${result.length} records found');
    } catch (e) {
      print('Table structure error: $e');
    }
  }

  // UTILITY - Convert budget range string to min/max values
  Map<String, double> parseBudgetRange(String budgetRange) {
    switch (budgetRange) {
      case 'Under \$500':
        return {'min': 0, 'max': 500};
      case '\$500 - \$1000':
        return {'min': 500, 'max': 1000};
      case '\$1000 - \$2000':
        return {'min': 1000, 'max': 2000};
      case '\$2000 - \$5000':
        return {'min': 2000, 'max': 5000};
      case 'Over \$5000':
        return {'min': 5000, 'max': 999999};
      default:
        return {'min': 500, 'max': 1000};
    }
  }

  // UTILITY - Format budget range for display
  String formatBudgetRange(double min, double max) {
    if (min == 0 && max <= 500) return 'Under \$500';
    if (min == 500 && max == 1000) return '\$500 - \$1000';
    if (min == 1000 && max == 2000) return '\$1000 - \$2000';
    if (min == 2000 && max == 5000) return '\$2000 - \$5000';
    if (min >= 5000) return 'Over \$5000';
    return '\${min.toInt()} - \${max.toInt()}';
  }

  // UTILITY - Parse activities string to list
  List<String> parseActivities(String? tags) {
    if (tags == null || tags.isEmpty) return [];
    return tags.split(', ').where((tag) => tag.isNotEmpty).toList();
  }

  // New method to join a group
  Future<Map<String, dynamic>> joinGroup({
    required String groupId,
    required String userId,
    String role = 'member',
  }) async {
    try {
      // First check if user is already a member
      final existingMember = await supabase
          .from('group_members')
          .select()
          .eq('group_id', groupId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingMember != null) {
        return {
          'success': false,
          'error': 'You are already a member of this group',
        };
      }

      // Insert new member
      await supabase.from('group_members').insert({
        'group_id': groupId,
        'user_id': userId,
        'role': role,
        'joined_at': DateTime.now().toIso8601String(),
      });

      return {
        'success': true,
        'message': 'Successfully joined the group!',
      };
    } catch (error) {
      return {
        'success': false,
        'error': 'Failed to join group: ${error.toString()}',
      };
    }
  }

  // Method to check if user is already a member
  Future<bool> isUserMember(String groupId, String userId) async {
    try {
      final result = await supabase
          .from('group_members')
          .select()
          .eq('group_id', groupId)
          .eq('user_id', userId)
          .maybeSingle();

      return result != null;
    } catch (error) {
      print('Error checking membership: $error');
      return false;
    }
  }


  // Method to leave a group
  Future<Map<String, dynamic>> leaveGroup({
    required String groupId,
    required String userId,
  }) async {
    try {
      await supabase
          .from('group_members')
          .delete()
          .eq('group_id', groupId)
          .eq('user_id', userId);

      return {
        'success': true,
        'message': 'Successfully left the group',
      };
    } catch (error) {
      return {
        'success': false,
        'error': 'Failed to leave group: ${error.toString()}',
      };
    }
  }

  // Method to get user's groups
  Future<List<Map<String, dynamic>>> getUserGroups(String userId) async {
    try {
      final result = await supabase
          .from('group_members')
          .select('''
            *,
            groups:group_id (
              *
            )
          ''')
          .eq('user_id', userId);

      return List<Map<String, dynamic>>.from(result);
    } catch (error) {
      print('Error fetching user groups: $error');
      return [];
    }
  }

  Future<void> debugUserAuth() async {
    final user = supabase.auth.currentUser;
    print('Current user: ${user?.id}');
    print('User email: ${user?.email}');

    if (user?.id != null) {
      // Check if user exists in your users/profiles table
      try {
        final userRecord = await supabase
            .from('users') // or 'profiles' depending on your table name
            .select('*')
            .eq('id', user!.id)
            .maybeSingle();

        print('User record in database: $userRecord');
      } catch (e) {
        print('Error checking user in database: $e');
      }
    }
  }
}