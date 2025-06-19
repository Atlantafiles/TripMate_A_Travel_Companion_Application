import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class TravelPackagesService {
  // Get Supabase client from the global instance
  final supabase = Supabase.instance.client;

  // Helper method to validate UUID format
  bool _isValidUUID(String uuid) {
    final uuidRegex = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$');
    return uuidRegex.hasMatch(uuid.toLowerCase());
  }

  // Helper method to parse JSON fields from database
  void _parseJsonFields(Map<String, dynamic> package) {
    try {
      if (package['inclusions'] is String) {
        package['inclusions'] = json.decode(package['inclusions']);
      }
      if (package['exclusions'] is String) {
        package['exclusions'] = json.decode(package['exclusions']);
      }
      if (package['itinerary'] is String) {
        package['itinerary'] = json.decode(package['itinerary']);
      }
      if (package['images'] is String) {
        package['images'] = json.decode(package['images']);
      }
    } catch (e) {
      print('JSON parsing error: $e');
    }
  }

  // MAIN METHOD: Get all travel packages WITH agency names using JOIN
  Future<List<Map<String, dynamic>>> getTravelPackages({
    String? destination,
    String? packageType,
    double? minPrice,
    double? maxPrice,
    int? minDuration,
    int? maxDuration,
    String? agencyId,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    int page = 1,
    int limit = 20,
  }) async {
    try {
      print('=== FETCHING PACKAGES WITH AGENCY NAMES ===');

      // Use JOIN to get agency name along with package data
      // The syntax is: trippackages.*, travelagencies(name)
      var query = supabase
          .from('trippackages')
          .select('*, travelagencies(name)');

      // Apply filters
      if (destination != null) {
        query = query.ilike('destination', '%$destination%');
      }
      if (agencyId != null) {
        query = query.eq('agency_id', agencyId);
      }
      if (packageType != null) {
        query = query.eq('package_type', packageType);
      }
      if (minPrice != null) {
        query = query.gte('price_per_person', minPrice);
      }
      if (maxPrice != null) {
        query = query.lte('price_per_person', maxPrice);
      }
      if (minDuration != null) {
        query = query.gte('duration_days', minDuration);
      }
      if (maxDuration != null) {
        query = query.lte('duration_days', maxDuration);
      }

      final response = await query
          .order(sortBy, ascending: sortOrder == 'asc')
          .range((page - 1) * limit, page * limit - 1);

      print('✓ Packages fetched with JOIN: ${response.length}');
      if (response.isNotEmpty) {
        print('Sample package structure: ${response.first.keys.toList()}');
        print('Sample travelagencies data: ${response.first['travelagencies']}');
      }

      final packages = List<Map<String, dynamic>>.from(response);

      // Process each package to extract agency name and parse JSON fields
      for (var package in packages) {
        _parseJsonFields(package);

        // Extract agency name from the joined data
        if (package['travelagencies'] != null) {
          final agencyData = package['travelagencies'];
          if (agencyData is Map && agencyData['name'] != null) {
            package['name'] = agencyData['name'];
          } else if (agencyData is List && agencyData.isNotEmpty && agencyData.first['name'] != null) {
            package['name'] = agencyData.first['name'];
          }
        }

        // Clean up the nested structure (optional)
        // package.remove('travelagencies');
      }

      return packages;

    } catch (e) {
      print('JOIN failed: $e');
      print('Falling back to separate queries...');

      // Fallback: Get packages first, then fetch agency names separately
      return await _getTravelPackagesWithSeparateLookup(
        destination: destination,
        packageType: packageType,
        minPrice: minPrice,
        maxPrice: maxPrice,
        minDuration: minDuration,
        maxDuration: maxDuration,
        agencyId: agencyId,
        sortBy: sortBy,
        sortOrder: sortOrder,
        page: page,
        limit: limit,
      );
    }
  }

  // FALLBACK METHOD: Get packages and agency names separately
  Future<List<Map<String, dynamic>>> _getTravelPackagesWithSeparateLookup({
    String? destination,
    String? packageType,
    double? minPrice,
    double? maxPrice,
    int? minDuration,
    int? maxDuration,
    String? agencyId,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    int page = 1,
    int limit = 20,
  }) async {
    try {
      print('=== USING SEPARATE LOOKUP METHOD ===');

      // Get packages first
      var query = supabase.from('trippackages').select();

      // Apply filters
      if (destination != null) {
        query = query.ilike('destination', '%$destination%');
      }
      if (agencyId != null) {
        query = query.eq('agency_id', agencyId);
      }
      if (packageType != null) {
        query = query.eq('package_type', packageType);
      }
      if (minPrice != null) {
        query = query.gte('price_per_person', minPrice);
      }
      if (maxPrice != null) {
        query = query.lte('price_per_person', maxPrice);
      }
      if (minDuration != null) {
        query = query.gte('duration_days', minDuration);
      }
      if (maxDuration != null) {
        query = query.lte('duration_days', maxDuration);
      }

      final packages = await query
          .order(sortBy, ascending: sortOrder == 'asc')
          .range((page - 1) * limit, page * limit - 1);

      print('✓ Got ${packages.length} packages');

      // Get all unique agency IDs from the packages
      final agencyIds = packages
          .map((p) => p['agency_id'] as String?)
          .where((id) => id != null)
          .toSet()
          .toList();

      print('Unique agency IDs: $agencyIds');

      // Fetch all agency names in one query
      final agencyNamesMap = <String, String>{};
      if (agencyIds.isNotEmpty) {
        final agenciesResponse = await supabase
            .from('travelagencies')
            .select('agency_id, name')
            .inFilter('agency_id', agencyIds);

        print('Agencies found: ${agenciesResponse.length}');

        for (var agency in agenciesResponse) {
          if (agency['agency_id'] != null && agency['name'] != null) {
            agencyNamesMap[agency['agency_id']] = agency['name'];
          }
        }
      }

      print('Agency names map: $agencyNamesMap');

      // Add agency names to packages
      final packagesWithAgencyNames = <Map<String, dynamic>>[];
      for (var package in packages) {
        final packageData = Map<String, dynamic>.from(package);
        _parseJsonFields(packageData);

        final agencyId = packageData['agency_id'] as String?;
        if (agencyId != null && agencyNamesMap.containsKey(agencyId)) {
          packageData['name'] = agencyNamesMap[agencyId];
        } else {
          packageData['name'] = 'Unknown Agency';
          print('No agency name found for ID: $agencyId');
        }

        packagesWithAgencyNames.add(packageData);
      }

      return packagesWithAgencyNames;

    } catch (e) {
      print('Error in separate lookup: $e');
      throw Exception('Error fetching packages: $e');
    }
  }

  // ENHANCED METHOD: Get packages by agency (for logged-in agency)
  Future<List<Map<String, dynamic>>> getPackagesByAgency() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Agency is not authenticated');
      }

      print('=== USER DEBUG INFO ===');
      print('User ID: ${user.id}');
      print('User Email: ${user.email}');

      String? agencyId;
      agencyId = user.userMetadata?['agency_id'];
      agencyId ??= user.appMetadata['agency_id'];
      agencyId ??= user.id;

      print('Final agency_id to use: $agencyId');

      // Try to get packages with agency name using JOIN
      try {
        final response = await supabase
            .from('trippackages')
            .select('*, travelagencies(name)')
            .eq('agency_id', agencyId)
            .order('created_at', ascending: false);

        print('✓ Packages with JOIN: ${response.length}');

        final packages = List<Map<String, dynamic>>.from(response);
        for (var package in packages) {
          _parseJsonFields(package);

          // Extract agency name
          if (package['travelagencies'] != null) {
            final agencyData = package['travelagencies'];
            if (agencyData is Map && agencyData['name'] != null) {
              package['name'] = agencyData['name'];
            } else if (agencyData is List && agencyData.isNotEmpty && agencyData.first['name'] != null) {
              package['name'] = agencyData.first['name'];
            }
          }
        }

        return packages;

      } catch (joinError) {
        print('JOIN failed for agency packages: $joinError');

        // Fallback: Get packages first, then agency name
        final response = await supabase
            .from('trippackages')
            .select()
            .eq('agency_id', agencyId)
            .order('created_at', ascending: false);

        print('✓ Packages without JOIN: ${response.length}');

        // Get agency name separately
        String? agencyName;
        try {
          final agencyResponse = await supabase
              .from('travelagencies')
              .select('name')
              .eq('agency_id', agencyId)
              .maybeSingle();

          agencyName = agencyResponse?['name'];
          print('Agency name: $agencyName');
        } catch (e) {
          print('Could not fetch agency name: $e');
        }

        final packages = List<Map<String, dynamic>>.from(response);
        for (var package in packages) {
          _parseJsonFields(package);
          package['name'] = agencyName ?? 'Unknown Agency';
        }

        return packages;
      }
    } catch (e) {
      print('Error in getPackagesByAgency: $e');
      throw Exception('Error fetching agency packages: $e');
    }
  }

  // ENHANCED METHOD: Get package details with agency name
  Future<Map<String, dynamic>> getPackageDetails(String packageId) async {
    try {
      // Try to get package with agency name using JOIN
      try {
        final response = await supabase
            .from('trippackages')
            .select('*, travelagencies(name)')
            .eq('package_id', packageId)
            .single();

        _parseJsonFields(response);

        // Extract agency name
        if (response['travelagencies'] != null) {
          final agencyData = response['travelagencies'];
          if (agencyData is Map && agencyData['name'] != null) {
            response['name'] = agencyData['name'];
          } else if (agencyData is List && agencyData.isNotEmpty && agencyData.first['name'] != null) {
            response['name'] = agencyData.first['name'];
          }
        }

        return response;

      } catch (joinError) {
        print('JOIN failed for package details: $joinError');

        // Fallback: Get package first, then agency name
        final response = await supabase
            .from('trippackages')
            .select()
            .eq('package_id', packageId)
            .single();

        _parseJsonFields(response);

        // Get agency name separately
        final agencyId = response['agency_id'] as String?;
        if (agencyId != null) {
          try {
            final agencyResponse = await supabase
                .from('travelagencies')
                .select('name')
                .eq('agency_id', agencyId)
                .maybeSingle();

            response['name'] = agencyResponse?['name'] ?? 'Unknown Agency';
          } catch (e) {
            print('Could not fetch agency name: $e');
            response['name'] = 'Unknown Agency';
          }
        }

        return response;
      }
    } catch (e) {
      throw Exception('Error fetching package details: $e');
    }
  }

  // DEBUGGING METHODS

  // Test the relationship between tables
  Future<void> debugTableRelationship() async {
    try {
      print('=== DEBUGGING TABLE RELATIONSHIP ===');

      // Check if we can access both tables
      final packagesCount = await supabase
          .from('trippackages')
          .select('agency_id')
          .limit(1);

      final agenciesCount = await supabase
          .from('travelagencies')
          .select('agency_id, name')
          .limit(1);

      print('✓ Can access trippackages: ${packagesCount.isNotEmpty}');
      print('✓ Can access travelagencies: ${agenciesCount.isNotEmpty}');

      if (packagesCount.isNotEmpty && agenciesCount.isNotEmpty) {
        print('Sample package agency_id: ${packagesCount.first['agency_id']}');
        print('Sample agency: ${agenciesCount.first}');

        // Test JOIN
        try {
          final joinTest = await supabase
              .from('trippackages')
              .select('package_id, title, agency_id, travelagencies(name)')
              .limit(1);

          print('✓ JOIN test successful: ${joinTest.first}');
        } catch (e) {
          print('✗ JOIN test failed: $e');
        }
      }

    } catch (e) {
      print('Error debugging relationship: $e');
    }
  }

  // Check if agency_ids match between tables
  Future<void> debugAgencyIdMatches() async {
    try {
      print('=== CHECKING AGENCY ID MATCHES ===');

      // Get some agency_ids from packages
      final packages = await supabase
          .from('trippackages')
          .select('agency_id')
          .limit(5);

      print('Package agency_ids:');
      for (var package in packages) {
        final agencyId = package['agency_id'];
        print('  - $agencyId');

        // Check if this agency exists
        final agencyExists = await supabase
            .from('travelagencies')
            .select('name')
            .eq('agency_id', agencyId)
            .maybeSingle();

        if (agencyExists != null) {
          print('    ✓ Agency exists: ${agencyExists['name']}');
        } else {
          print('    ✗ Agency not found');
        }
      }

    } catch (e) {
      print('Error checking agency matches: $e');
    }
  }

  // ORIGINAL METHODS (keeping your existing functionality)

  Future<Map<String, dynamic>> createTravelPackage({
    required String agencyId,
    required String title,
    required String destination,
    required int durationDays,
    required double pricePerPerson,
    required int maxTravelers,
    required List<String> inclusions,
    required List<String> exclusions,
    required List<Map<String, String>> itinerary,
    required String tags,
  }) async {
    try {
      if (!_isValidUUID(agencyId)) {
        throw Exception('Invalid agency ID format. Expected UUID.');
      }

      final agencyCheck = await supabase
          .from('travelagencies')
          .select('agency_id')
          .eq('agency_id', agencyId)
          .maybeSingle();

      if (agencyCheck == null) {
        throw Exception('Agency not found with the provided ID.');
      }

      final packageData = {
        'agency_id': agencyId,
        'title': title,
        'destination': destination,
        'duration_days': durationDays,
        'price_per_person': pricePerPerson,
        'max_travelers': maxTravelers,
        'inclusions': inclusions,
        'exclusions': exclusions,
        'itinerary': itinerary,
        'tags': tags,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await supabase
          .from('trippackages')
          .insert(packageData)
          .select()
          .single();

      return response;
    } catch (e) {
      if (e.toString().contains('invalid input syntax for type uuid')) {
        throw Exception('Invalid agency ID format. Please check the agency ID.');
      }
      print('Create package error: $e');
      throw Exception('Error creating package: $e');
    }
  }

  Future<Map<String, dynamic>> updateTravelPackage({
    required String packageId,
    required String agencyId,
    required String title,
    required String destination,
    required int durationDays,
    required double pricePerPerson,
    required int maxTravelers,
    required List<String> inclusions,
    required List<String> exclusions,
    required List<Map<String, String>> itinerary,
    required String tags,
  }) async {
    try {
      if (!_isValidUUID(agencyId)) {
        throw Exception('Invalid agency ID format. Expected UUID.');
      }

      final agencyCheck = await supabase
          .from('travelagencies')
          .select('agency_id')
          .eq('agency_id', agencyId)
          .maybeSingle();

      if (agencyCheck == null) {
        throw Exception('Agency not found with the provided ID.');
      }

      final packageData = {
        'agency_id': agencyId,
        'title': title,
        'destination': destination,
        'duration_days': durationDays,
        'price_per_person': pricePerPerson,
        'max_travelers': maxTravelers,
        'inclusions': inclusions,
        'exclusions': exclusions,
        'itinerary': itinerary,
        'tags': tags,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await supabase
          .from('trippackages')
          .update(packageData)
          .eq('package_id', packageId)
          .select()
          .single();

      return response;
    } catch (e) {
      if (e.toString().contains('invalid input syntax for type uuid')) {
        throw Exception('Invalid agency ID format. Please check the agency ID.');
      }
      throw Exception('Error updating package: $e');
    }
  }

  Future<bool> deleteTravelPackage(String packageId) async {
    try {
      await supabase
          .from('trippackages')
          .delete()
          .eq('package_id', packageId);

      return true;
    } catch (e) {
      throw Exception('Error deleting package: $e');
    }
  }

  Future<List<Map<String, dynamic>>> searchPackages(String query) async {
    try {
      // Use the enhanced method that includes agency names
      final packages = await getTravelPackages();

      // Filter based on search query
      return packages.where((package) {
        final title = package['title']?.toString().toLowerCase() ?? '';
        final destination = package['destination']?.toString().toLowerCase() ?? '';
        final tags = package['tags']?.toString().toLowerCase() ?? '';
        final agencyName = package['name']?.toString().toLowerCase() ?? '';
        final searchQuery = query.toLowerCase();

        return title.contains(searchQuery) ||
            destination.contains(searchQuery) ||
            tags.contains(searchQuery) ||
            agencyName.contains(searchQuery);
      }).toList();
    } catch (e) {
      throw Exception('Error searching packages: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getFeaturedPackages({int limit = 10}) async {
    try {
      // Try with JOIN first
      try {
        final response = await supabase
            .from('trippackages')
            .select('*, travelagencies(name)')
            .eq('is_featured', true)
            .order('created_at', ascending: false)
            .limit(limit);

        final packages = List<Map<String, dynamic>>.from(response);
        for (var package in packages) {
          _parseJsonFields(package);

          // Extract agency name
          if (package['travelagencies'] != null) {
            final agencyData = package['travelagencies'];
            if (agencyData is Map && agencyData['name'] != null) {
              package['name'] = agencyData['name'];
            }
          }
        }

        return packages;
      } catch (e) {
        // Fallback to basic query
        final response = await supabase
            .from('trippackages')
            .select()
            .eq('is_featured', true)
            .order('created_at', ascending: false)
            .limit(limit);

        final packages = List<Map<String, dynamic>>.from(response);
        for (var package in packages) {
          _parseJsonFields(package);
          package['name'] = 'Unknown Agency';
        }

        return packages;
      }
    } catch (e) {
      throw Exception('Error fetching featured packages: $e');
    }
  }

  // Booking methods (keeping your existing functionality)
  Future<Map<String, dynamic>> bookPackage({
    required String packageId,
    required String userId,
    required String departureDate,
    required int numberOfTravelers,
    required List<Map<String, dynamic>> travelerDetails,
    required String pickupLocation,
    String? specialRequests,
    required Map<String, dynamic> emergencyContact,
  }) async {
    try {
      final bookingData = {
        'package_id': packageId,
        'user_id': userId,
        'departure_date': departureDate,
        'number_of_travelers': numberOfTravelers,
        'traveler_details': travelerDetails,
        'pickup_location': pickupLocation,
        'special_requests': specialRequests,
        'emergency_contact': emergencyContact,
        'booking_status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await supabase
          .from('bookings')
          .insert(bookingData)
          .select()
          .single();

      return response;
    } catch (e) {
      throw Exception('Error creating booking: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserBookings(String userId) async {
    try {
      final response = await supabase
          .from('bookings')
          .select('*, trippackages(*, travelagencies(name))')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Error fetching bookings: $e');
    }
  }

  Future<Map<String, dynamic>> getBookingDetails(String bookingId) async {
    try {
      final response = await supabase
          .from('bookings')
          .select('*, trippackages(*, travelagencies(name))')
          .eq('booking_id', bookingId)
          .single();

      return response;
    } catch (e) {
      throw Exception('Error fetching booking details: $e');
    }
  }

  Future<bool> cancelBooking(String bookingId, String reason) async {
    try {
      await supabase
          .from('bookings')
          .update({
        'booking_status': 'cancelled',
        'cancellation_reason': reason,
        'cancelled_at': DateTime.now().toIso8601String(),
      })
          .eq('booking_id', bookingId);

      return true;
    } catch (e) {
      throw Exception('Error cancelling booking: $e');
    }
  }

  Future<List<String>> uploadPackageImages(String packageId, List<XFile> imageFiles) async {
    final List<String> imageUrls = [];

    try {
      for (int i = 0; i < imageFiles.length; i++) {
        final file = imageFiles[i];
        final fileName = '${packageId}_${DateTime.now().millisecondsSinceEpoch}_$i.${file.path.split('.').last}';

        // Upload to Supabase Storage
        final bytes = await file.readAsBytes();
        await supabase.storage
            .from('trippackages')
            .uploadBinary(fileName, bytes);

        // Get public URL
        final url = supabase.storage
            .from('trippackages')
            .getPublicUrl(fileName);

        imageUrls.add(url);
      }

      return imageUrls;
    } catch (e) {
      print('Error uploading images: $e');
      throw Exception('Failed to upload images: $e');
    }
  }


  Future<bool> submitPackageReview({
    required String packageId,
    required String bookingId,
    required String userId,
    required int rating,
    required String title,
    required String reviewText,
    List<String>? imageUrls,
  }) async {
    try {
      final reviewData = {
        'package_id': packageId,
        'booking_id': bookingId,
        'user_id': userId,
        'rating': rating,
        'title': title,
        'review_text': reviewText,
        'images': imageUrls ?? [],
        'created_at': DateTime.now().toIso8601String(),
      };

      await supabase
          .from('reviews')
          .insert(reviewData);

      return true;
    } catch (e) {
      throw Exception('Error submitting review: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getPackageReviews(String packageId, {int page = 1, int limit = 10}) async {
    try {
      final response = await supabase
          .from('reviews')
          .select('*, users(name, avatar_url)')
          .eq('package_id', packageId)
          .order('created_at', ascending: false)
          .range((page - 1) * limit, page * limit - 1);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Error fetching reviews: $e');
    }
  }
  // Add these methods to your TravelPackagesService class

// Get count of packages for the current agency (more efficient than fetching all)
  Future<int> getPackageCountByAgency() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Agency is not authenticated');
      }

      String? agencyId;
      agencyId = user.userMetadata?['agency_id'];
      if (agencyId == null) {
        agencyId = user.appMetadata['agency_id'];
      }
      if (agencyId == null) {
        agencyId = user.id;
      }

      // Use Supabase count function for better performance
      final response = await supabase
          .from('trippackages')
          .select('package_id')
          .eq('agency_id', agencyId);

      return response.length;
    } catch (e) {
      print('Error getting package count: $e');
      throw Exception('Error fetching package count: $e');
    }
  }

// Get count of bookings for packages owned by the current agency
  Future<int> getBookingCountByAgency() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Agency is not authenticated');
      }

      String? agencyId;
      agencyId = user.userMetadata?['agency_id'];
      if (agencyId == null) {
        agencyId = user.appMetadata['agency_id'];
      }
      if (agencyId == null) {
        agencyId = user.id;
      }

      // Get booking count through JOIN with trippackages
      final response = await supabase
          .from('bookings')
          .select('booking_id, trippackages!inner(agency_id)')
          .eq('trippackages.agency_id', agencyId);

      return response.length;
    } catch (e) {
      print('Error getting booking count: $e');
      // Fallback: get packages first, then count bookings
      try {
        final user = supabase.auth.currentUser;
        if (user == null) {
          throw Exception('Agency is not authenticated');
        }

        String? agencyId;
        agencyId = user.userMetadata?['agency_id'];
        if (agencyId == null) {
          agencyId = user.appMetadata['agency_id'];
        }
        if (agencyId == null) {
          agencyId = user.id;
        }

        final packages = await supabase
            .from('trippackages')
            .select('package_id')
            .eq('agency_id', agencyId);

        if (packages.isEmpty) return 0;

        final packageIds = packages.map((p) => p['package_id']).toList();

        final bookings = await supabase
            .from('bookings')
            .select('booking_id')
            .inFilter('package_id', packageIds);

        return bookings.length;
      } catch (fallbackError) {
        print('Fallback booking count failed: $fallbackError');
        return 0;
      }
    }
  }

// Get dashboard stats in one call
  Future<Map<String, int>> getDashboardStats() async {
    try {
      final packageCount = await getPackageCountByAgency();
      final bookingCount = await getBookingCountByAgency();

      return {
        'packages': packageCount,
        'bookings': bookingCount,
      };
    } catch (e) {
      print('Error getting dashboard stats: $e');
      return {
        'packages': 0,
        'bookings': 0,
      };
    }
  }
}