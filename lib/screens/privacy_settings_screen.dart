import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State <PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  // Toggle states
  bool _showProfile = false;
  bool _shareLocation = false;
  bool _allowContact = false;
  bool _shareActivity = false;
  bool _shareTripHistory = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Privacy Settings Title
            Text(
              'Privacy Settings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 24),

            // Profile Visibility Section
            _buildSectionHeader(
              icon: Icons.privacy_tip_outlined,
              title: 'Profile Visibility',
              iconColor: Colors.blue,
            ),

            SizedBox(height: 16),

            // Show profile to everyone
            _buildToggleOption(
              title: 'Show profile to everyone',
              subtitle: 'Others can view your profile',
              value: _showProfile,
              onChanged: (value) {
                setState(() {
                  _showProfile = value;
                });
              },
            ),

            // Share location history
            _buildToggleOption(
              title: 'Share location history',
              subtitle: 'Your location will be visible to companions',
              value: _shareLocation,
              onChanged: (value) {
                setState(() {
                  _shareLocation = value;
                });
              },
            ),

            // Allow contact by other users
            _buildToggleOption(
              title: 'Allow contact by other users',
              subtitle: 'Receive messages from other travelers',
              value: _allowContact,
              onChanged: (value) {
                setState(() {
                  _allowContact = value;
                });
              },
            ),

            SizedBox(height: 24),

            // Data Sharing Section
            _buildSectionHeader(
              icon: Icons.lock_outline,
              title: 'Data Sharing',
              iconColor: Colors.blue,
            ),

            SizedBox(height: 16),

            // Share activity status
            _buildToggleOption(
              title: 'Share activity status',
              subtitle: 'Show when you\'re online',
              value: _shareActivity,
              onChanged: (value) {
                setState(() {
                  _shareActivity = value;
                });
              },
            ),

            // Share trip history
            _buildToggleOption(
              title: 'Share trip history',
              subtitle: 'Allow others to see your past trips',
              value: _shareTripHistory,
              onChanged: (value) {
                setState(() {
                  _shareTripHistory = value;
                });
              },
            ),

            SizedBox(height: 16),

            // Blocked Users
            _buildNavigationOption(
              icon: Icons.block_outlined,
              title: 'Blocked Users',
              onTap: () {
                // Navigate to blocked users screen
              },
            ),

            // Privacy Checkup
            _buildNavigationOption(
              icon: Icons.warning_amber_outlined,
              title: 'Privacy Checkup',
              onTap: () {
                // Navigate to privacy checkup screen
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget for section headers with icons
  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: iconColor,
          size: 22,
        ),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Widget for toggle options with title and subtitle
  Widget _buildToggleOption({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: Colors.blue,
          ),
        ],
      ),
    );
  }

  // Widget for navigation options (with arrow)
  Widget _buildNavigationOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey[700]),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}