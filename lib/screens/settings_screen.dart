import 'package:flutter/material.dart';
import 'package:tripmate/screens/notification_screen.dart';
import 'package:tripmate/screens/onboarding_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;

  void _toggleDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
      // TODO: Implement dark mode theme switching
    });
  }

  Widget _buildSettingsSection({
    required String title,
    required List<SettingsItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: items.map((item) => _buildSettingsItem(item)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(SettingsItem item) {
    return ListTile(
      leading: Icon(item.icon, color: Colors.blue),
      title: Text(item.title),
      trailing: item.trailing ?? Icon(Icons.chevron_right),
      onTap: item.onTap,
    );
  }

  void _showLogoutDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Log Out'),
            content: Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Log Out', style: TextStyle(color: Colors.red)),
                onPressed: () {
                  // Clear any stored authentication tokens
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => OnboardingScreen(),
                    ),
                  );
                },
              ),
            ],
          );
        }
    );
  }

    @override
      Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
          centerTitle: true,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Account Settings Section
                    _buildSettingsSection(
                      title: 'Account Settings',
                      items: [
                        SettingsItem(
                          icon: Icons.person_outline,
                          title: 'Personal Information',
                          // onTap: () => Navigator.of(context).push(
                          //   MaterialPageRoute(
                          //     builder: (context) => PersonalInformationScreen(),
                          //   ),
                          // ),
                        ),
                        SettingsItem(
                          icon: Icons.lock_outline,
                          title: 'Password & Security',
                          // onTap: () => Navigator.of(context).push(
                          //   MaterialPageRoute(
                          //     builder: (context) => PasswordSecurityScreen(),
                          //   ),
                          // ),
                        ),
                        SettingsItem(
                          icon: Icons.payment,
                          title: 'Payment Methods',
                          // onTap: () => Navigator.of(context).push(
                          //   MaterialPageRoute(
                          //     builder: (context) => PaymentMethodsScreen(),
                          //   ),
                          // ),
                        ),
                      ],
                    ),

                    // Preferences Section
                    _buildSettingsSection(
                      title: 'Preferences',
                      items: [
                        SettingsItem(
                          icon: Icons.language,
                          title: 'Language',
                          // onTap: () => Navigator.of(context).push(
                          //   MaterialPageRoute(
                          //     builder: (context) => LanguageScreen(),
                          //   ),
                          // ),
                        ),
                        SettingsItem(
                          icon: Icons.notifications_none,
                          title: 'Notifications',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => NotificationsScreen()),
                            );
                          },
                        ),
                        SettingsItem(
                          icon: Icons.dark_mode_outlined,
                          title: 'Dark Mode',
                          trailing: Switch(
                            value: _isDarkMode,
                            onChanged: _toggleDarkMode,
                          ),
                        ),
                      ],
                    ),

                    // Support Section
                    _buildSettingsSection(
                      title: 'Support',
                      items: [
                        SettingsItem(
                          icon: Icons.help_outline,
                          title: 'Help Center',
                          // onTap: () => Navigator.of(context).push(
                          //   MaterialPageRoute(
                          //     builder: (context) => HelpCenterScreen(),
                          //   ),
                          // ),
                        ),
                        SettingsItem(
                          icon: Icons.contact_mail_outlined,
                          title: 'Contact Us',
                          // onTap: () => Navigator.of(context).push(
                          //   MaterialPageRoute(
                          //     builder: (context) => ContactUsScreen(),
                          //   ),
                          // ),
                        ),
                      ],
                    ),

                    // Logout Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _showLogoutDialog,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout),
                            SizedBox(width: 10),
                            Text(
                              'Log Out',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }
  }

// Helper class to define settings items
  class SettingsItem {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;

  SettingsItem({
  required this.icon,
  required this.title,
  this.onTap,
  this.trailing,
  });
  }



