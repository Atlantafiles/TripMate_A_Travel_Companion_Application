import 'package:flutter/material.dart';
import 'package:tripmate/screens/login_screen.dart';
import 'package:tripmate/screens/notification_screen.dart';
import 'package:tripmate/services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  bool _isDarkMode = false;
  bool _isLoggingOut = false;

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
      barrierDismissible: !_isLoggingOut,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Log Out'),
              content: _isLoggingOut
                  ? const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text('Logging out...'),
                ],
              )
                  : const Text('Are you sure you want to log out?'),
              actions: _isLoggingOut
                  ? []
                  : [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
                TextButton(
                  child: const Text(
                    'Log Out',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () async {
                    setDialogState(() {
                      _isLoggingOut = true;
                    });

                    setState(() {
                      _isLoggingOut = true;
                    });

                    try {
                      final success = await _authService.signOut(context: context);

                      if (success) {
                        // Close the dialog first
                        if (mounted) {
                          Navigator.of(dialogContext).pop();
                        }

                        // Add a small delay to ensure dialog is closed
                        await Future.delayed(const Duration(milliseconds: 100));

                        // Navigate to login/onboarding screen - try multiple approaches
                        if (mounted) {
                          // Try approach 1: pushNamedAndRemoveUntil
                          try {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/onboarding',
                                  (route) => false,
                            );
                          } catch (e) {
                            print('Route /login not found, trying /onboarding: $e');
                            try {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/onboarding',
                                    (route) => false,
                              );
                            } catch (e2) {
                              print('Route /onboarding not found, trying / (root): $e2');
                              try {
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  '/',
                                      (route) => false,
                                );
                              } catch (e3) {
                                print('All named routes failed, using pushAndRemoveUntil with MaterialPageRoute: $e3');
                                // Fallback: Use MaterialPageRoute
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) =>  const LoginScreen(),
                                  ),
                                      (route) => false,
                                );
                              }
                            }
                          }
                        }
                      } else {
                        throw Exception('Logout failed');
                      }
                    } catch (e) {
                      print('Logout error in settings: $e');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Logout failed. Please try again.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setDialogState(() {
                          _isLoggingOut = false;
                        });
                        setState(() {
                          _isLoggingOut = false;
                        });
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // // Placeholder method - replace with your actual login screen
  // Widget _getLoginScreen() {
  //   // Return your actual login/onboarding screen widget here
  //   // For example: return LoginScreen() or OnboardingScreen()
  //   return '/login';
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
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
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Feature coming soon!')),
                          );
                        },
                      ),
                      SettingsItem(
                        icon: Icons.lock_outline,
                        title: 'Password & Security',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Feature coming soon!')),
                          );
                        },
                      ),
                      SettingsItem(
                        icon: Icons.payment,
                        title: 'Payment Methods',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Feature coming soon!')),
                          );
                        },
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
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Feature coming soon!')),
                          );
                        },
                      ),
                      SettingsItem(
                        icon: Icons.notifications_none,
                        title: 'Notifications',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotificationsScreen(),
                            ),
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
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Feature coming soon!')),
                          );
                        },
                      ),
                      SettingsItem(
                        icon: Icons.contact_mail_outlined,
                        title: 'Contact Us',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Feature coming soon!')),
                          );
                        },
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _isLoggingOut ? null : _showLogoutDialog,
                      child: _isLoggingOut
                          ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Logging Out...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                          : const Row(
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