import 'package:flutter/material.dart';
import 'package:tripmate/models/user_profile.dart';
import 'package:tripmate/screens/profile_edit_screen.dart';
import 'package:tripmate/screens/login_screen.dart';


class CustomDrawer extends StatelessWidget {
  final UserProfile userProfile;

  const CustomDrawer({super.key, required this.userProfile});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header
          UserAccountsDrawerHeader(
            accountName: Text(
              userProfile.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            accountEmail: Text(userProfile.bio),
            currentAccountPicture: GestureDetector(
              onTap: () => _editProfile(context),
              child: CircleAvatar(
                backgroundImage: NetworkImage(userProfile.profileImageUrl),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.blue[800],
            ),
          ),

          // Drawer Menu Items
          _buildDrawerItem(
            context: context,
            icon: Icons.travel_explore,
            title: 'My Trips',
            onTap: () => _navigateTo(context, 'trips'),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.bookmark_border,
            title: 'Bookings',
            onTap: () => _navigateTo(context, 'bookings'),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.settings,
            title: 'Settings',
            onTap: () => _navigateTo(context, 'settings'),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () => _navigateTo(context, 'support'),
          ),

          const Divider(),

          _buildDrawerItem(
            context: context,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () => _navigateTo(context, 'privacy'),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.logout,
            title: 'Logout',
            onTap: () => _logout(context),
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  // Drawer Item Builder
  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color
  }) {
    return ListTile(
      leading: Icon(
          icon,
          color: color ?? Theme.of(context).iconTheme.color
      ),
      title: Text(
          title,
          style: TextStyle(color: color)
      ),
      onTap: onTap,
    );
  }

  // Navigation Methods
  void _editProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileEditScreen(),
      ),
    );
  }

  void _navigateTo(BuildContext context, String route) {
    Navigator.pop(context); // Close drawer
    switch (route) {
      case 'trips':
      // Navigate to trips screen
        break;
      case 'bookings':
      // Navigate to bookings screen
        break;
      case 'settings':
      // Navigate to settings screen
        break;
      case 'support':
      // Navigate to help & support screen
        break;
      case 'privacy':
      // Navigate to privacy policy screen
        break;
    }
  }

  void _logout(BuildContext context) {
    // Implement logout logic
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }
}