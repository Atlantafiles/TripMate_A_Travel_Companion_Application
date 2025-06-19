import 'package:supabase_flutter/supabase_flutter.dart';

class TravelAgencyAuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Sign up method for travel agencies
  Future<AuthResponse> signUpAgency({
    required String email,
    required String password,
    required String name,
    String? phone,
    String? description,
    String? licenseNumber,
    String? website,
    String? address,
    double? rating,
  }) async {
    print('🔄 Starting agency signup process...');

    try {
      // First, create the user account with Supabase Auth
      print('📧 Creating auth user for: $email');
      final AuthResponse authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      print('✅ Auth response received');
      print('👤 User ID: ${authResponse.user?.id}');
      print('📧 User email: ${authResponse.user?.email}');
      print('✔️ Email confirmed: ${authResponse.user?.emailConfirmedAt != null}');

      if (authResponse.user != null) {
        // Wait a moment to ensure auth state is properly set
        await Future.delayed(Duration(milliseconds: 500));

        // Prepare the data for insertion
        final agencyData = {
          'agency_id': authResponse.user!.id,
          'name': name,
          'email': email,
          'is_verified': false,
          'rating': rating ?? 0.0,
        };

        // Add optional fields only if they have values
        if (phone != null && phone.isNotEmpty) {
          agencyData['phone'] = phone;
        }
        if (description != null && description.isNotEmpty) {
          agencyData['description'] = description;
        }
        if (licenseNumber != null && licenseNumber.isNotEmpty) {
          agencyData['license_number'] = licenseNumber;
        }
        if (website != null && website.isNotEmpty) {
          agencyData['website'] = website;
        }
        if (address != null && address.isNotEmpty) {
          agencyData['address'] = address;
        }

        print('📝 Attempting to insert agency data:');
        print('   Table: travelagencies');
        print('   Data: $agencyData');

        try {
          // Test if we can access the table first
          print('🔍 Testing table access...');
          final testResponse = await _supabase
              .from('travelagencies')
              .select('count')
              .limit(1);
          print('✅ Table access successful: $testResponse');

          // Now try to upsert
          print('💾 Inserting agency data...');
          final response = await _supabase
              .from('travelagencies')
              .upsert(agencyData)
              .select();

          print('✅ Insert successful!');
          print('📊 Insert response: $response');

          if (response.isEmpty) {
            print('⚠️ Warning: Insert response is empty');
          }

        } catch (insertError) {
          print('❌ Insert operation failed');
          print('🔥 Insert error type: ${insertError.runtimeType}');
          print('💥 Insert error: $insertError');

          if (insertError is PostgrestException) {
            print('🔍 PostgrestException details:');
            print('   Code: ${insertError.code}');
            print('   Message: ${insertError.message}');
            print('   Details: ${insertError.details}');
            print('   Hint: ${insertError.hint}');
          }

          // Clean up the auth user since profile creation failed
          print('🧹 Cleaning up auth user...');
          try {
            await _supabase.auth.signOut();
            print('✅ Auth cleanup successful');
          } catch (signOutError) {
            print('❌ Auth cleanup failed: $signOutError');
          }

          rethrow; // Re-throw to be caught by outer catch block
        }
      } else {
        print('❌ Auth response user is null');
        throw Exception('Failed to create user account');
      }

      print('🎉 Agency signup completed successfully');
      return authResponse;

    } on AuthException catch (e) {
      print('🔐 Auth Exception occurred');
      print('   Message: ${e.message}');
      throw AuthException(e.message);
    } on PostgrestException catch (e) {
      print('🗄️ Database Exception occurred');
      print('   Code: ${e.code}');
      print('   Message: ${e.message}');
      print('   Details: ${e.details}');
      print('   Hint: ${e.hint}');

      throw Exception('Failed to create agency profile: ${e.message} (Code: ${e.code})');
    } catch (e) {
      print('💥 Unexpected error occurred');
      print('   Type: ${e.runtimeType}');
      print('   Error: $e');

      // Clean up auth user on any unexpected error
      if (_supabase.auth.currentUser != null) {
        try {
          await _supabase.auth.signOut();
          print('✅ Emergency auth cleanup successful');
        } catch (signOutError) {
          print('❌ Emergency auth cleanup failed: $signOutError');
        }
      }
      throw Exception('Unexpected error during sign up: $e');
    }
  }

  // Test method to check table structure
  Future<void> testTableStructure() async {
    try {
      print('🔍 Testing table structure...');

      // Try to get table info
      final response = await _supabase
          .from('travelagencies')
          .select()
          .limit(1);

      print('✅ Table query successful: $response');
    } catch (e) {
      print('❌ Table structure test failed: $e');
      if (e is PostgrestException) {
        print('   Code: ${e.code}');
        print('   Message: ${e.message}');
        print('   Details: ${e.details}');
      }
    }
  }

  // Sign in method for travel agencies
  Future<AuthResponse> signInAgency({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse authResponse = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return authResponse;
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw Exception('Unexpected error during sign in: $e');
    }
  }


  // Get current agency profile
  Future<Map<String, dynamic>?> getCurrentAgencyProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      final response = await _supabase
          .from('travelagencies')
          .select()
          .eq('agency_id', user.id)
          .single();

      return response;
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        // No rows returned
        return null;
      }
      throw Exception('Failed to fetch agency profile: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error fetching profile: $e');
    }
  }

  // Update agency profile
  Future<void> updateAgencyProfile({
    String? name,
    String? phone,
    String? description,
    String? licenseNumber,
    String? website,
    String? address,
    double? rating,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      final updateData = <String, dynamic>{};

      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (description != null) updateData['description'] = description;
      if (licenseNumber != null) updateData['license_number'] = licenseNumber;
      if (website != null) updateData['website'] = website;
      if (address != null) updateData['address'] = address;
      if (rating != null) updateData['rating'] = rating;

      if (updateData.isNotEmpty) {
        await _supabase
            .from('travelagencies')
            .update(updateData)
            .eq('agency_id', user.id);
      }
    } on PostgrestException catch (e) {
      throw Exception('Failed to update agency profile: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error updating profile: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Error signing out: $e');
    }
  }

  // Check if user is signed in
  bool isSignedIn() {
    return _supabase.auth.currentUser != null;
  }

  // Get current user
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw Exception('Error resetting password: $e');
    }
  }

  // Verify agency (admin function)
  Future<void> verifyAgency(String agencyId) async {
    try {
      await _supabase
          .from('travelagencies')
          .update({'is_verified': true})
          .eq('agency_id', agencyId);
    } on PostgrestException catch (e) {
      throw Exception('Failed to verify agency: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error verifying agency: $e');
    }
  }

  // Listen to auth state changes
  Stream<AuthState> get authStateStream {
    return _supabase.auth.onAuthStateChange;
  }

  // Delete agency account
  Future<void> deleteAgencyAccount() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      // First delete from travelagencies table
      await _supabase
          .from('travelagencies')
          .delete()
          .eq('agency_id', user.id);

      // Note: Supabase doesn't allow deleting auth users from client side
      // This would need to be handled via RLS policies or server-side functions
      // For now, we'll just sign out the user
      await signOut();

    } on PostgrestException catch (e) {
      throw Exception('Failed to delete agency data: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error deleting account: $e');
    }
  }

  // Check if agency is verified
  Future<bool> isAgencyVerified() async {
    try {
      final profile = await getCurrentAgencyProfile();
      return profile?['is_verified'] ?? false;
    } catch (e) {
      return false;
    }
  }
}