import 'package:flutter/material.dart';
import 'package:tripmate/services/travel_agency_auth_service.dart';


class AgencyProfileScreen extends StatefulWidget {
  const AgencyProfileScreen({super.key});

  @override
  State<AgencyProfileScreen> createState() => _AgencyProfileScreenState();
}

class _AgencyProfileScreenState extends State<AgencyProfileScreen> {
  final TravelAgencyAuthService _authService = TravelAgencyAuthService();
  bool _isLoggingOut = false;
  bool _isLoading = true;
  Map<String, dynamic>? _agencyProfile;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAgencyProfile();
  }

  Future<void> _loadAgencyProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Debug: Check if user is signed in
      print('🔍 Debug: Checking auth state...');
      final currentUser = _authService.getCurrentUser();
      print('👤 Current user: ${currentUser?.id}');
      print('📧 Current user email: ${currentUser?.email}');
      print('✅ Is signed in: ${_authService.isSignedIn()}');

      if (!_authService.isSignedIn()) {
        throw Exception('User is not signed in');
      }

      // Debug: Test table structure first
      print('🔧 Testing table structure...');
      await _authService.testTableStructure();

      print('🔄 Fetching agency profile...');
      final profile = await _authService.getCurrentAgencyProfile();
      print('📊 Profile data: $profile');

      setState(() {
        _agencyProfile = profile;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading profile: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Debug method to test direct database access
  Future<void> _testDatabaseConnection() async {
    try {
      print('🧪 Testing direct database connection...');
      await _authService.testTableStructure();

      // Test if we can get any data from the table
      final currentUser = _authService.getCurrentUser();
      if (currentUser != null) {
        print('🔍 Attempting to query for user: ${currentUser.id}');
      }
    } catch (e) {
      print('❌ Database test failed: $e');
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text("Are you sure you want to delete your account? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Account deleted")),
              );
              // Trigger delete logic here
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    setState(() {
      _isLoggingOut = true;
    });

    try {
      // Call the signOut method from your auth service
      await _authService.signOut();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Logged out successfully"),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to sign-in screen and clear navigation stack
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/agency_signin',
              (route) => false, // This removes all previous routes
        );
      }
    } catch (e) {
      // Handle logout error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Logout failed: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _handleLogout();
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Profile Header Section
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (_errorMessage != null)
              Column(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Failed to load profile",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _loadAgencyProfile,
                        icon: const Icon(Icons.refresh),
                        label: const Text("Retry"),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: _testDatabaseConnection,
                        icon: const Icon(Icons.bug_report),
                        label: const Text("Debug"),
                      ),
                    ],
                  ),
                ],
              )
            else
              Column(
                children: [
                  Text(
                    _agencyProfile?['name'] ?? 'Agency Name',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _agencyProfile?['email'] ?? 'No email',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),

                  // Verification Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: (_agencyProfile?['is_verified'] ?? false)
                          ? Colors.green[100]
                          : Colors.orange[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          (_agencyProfile?['is_verified'] ?? false)
                              ? Icons.verified
                              : Icons.pending,
                          size: 16,
                          color: (_agencyProfile?['is_verified'] ?? false)
                              ? Colors.green[700]
                              : Colors.orange[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          (_agencyProfile?['is_verified'] ?? false)
                              ? 'Verified Agency'
                              : 'Pending Verification',
                          style: TextStyle(
                            fontSize: 12,
                            color: (_agencyProfile?['is_verified'] ?? false)
                                ? Colors.green[700]
                                : Colors.orange[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Rating Display
                  if (_agencyProfile?['rating'] != null && _agencyProfile!['rating'] > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '${_agencyProfile!['rating'].toStringAsFixed(1)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Additional Info Cards
                  if (_agencyProfile != null) ...[
                    const SizedBox(height: 20),
                    _buildInfoCard(),
                  ],
                ],
              ),

            const SizedBox(height: 30),

            // List Items
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text("Edit Profile"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigate to Edit Profile screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text("Change Password"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigate to Change Password screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text("Delete Account"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showDeleteConfirmation(context),
            ),
            ListTile(
              leading: _isLoggingOut
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.logout),
              title: Text(_isLoggingOut ? "Logging out..." : "Logout"),
              trailing: _isLoggingOut
                  ? null
                  : const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _isLoggingOut ? null : _showLogoutConfirmation,
            ),

            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 5),
            const Text(
              "Version 1.0.0",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            TextButton.icon(
              onPressed: () {
                // Navigate to help screen
              },
              icon: const Icon(Icons.help_outline, size: 18),
              label: const Text("Help & Support"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Agency Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          if (_agencyProfile!['phone'] != null) ...[
            _buildInfoRow(Icons.phone, 'Phone', _agencyProfile!['phone']),
            const SizedBox(height: 8),
          ],

          if (_agencyProfile!['license_number'] != null) ...[
            _buildInfoRow(Icons.card_membership, 'License', _agencyProfile!['license_number']),
            const SizedBox(height: 8),
          ],

          if (_agencyProfile!['website'] != null) ...[
            _buildInfoRow(Icons.language, 'Website', _agencyProfile!['website']),
            const SizedBox(height: 8),
          ],

          if (_agencyProfile!['address'] != null) ...[
            _buildInfoRow(Icons.location_on, 'Address', _agencyProfile!['address']),
            const SizedBox(height: 8),
          ],

          if (_agencyProfile!['description'] != null) ...[
            _buildInfoRow(Icons.info_outline, 'Description', _agencyProfile!['description']),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}