import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:tripmate/models/user_profile.dart';
import 'package:tripmate/screens/emergency_screen.dart';
import 'package:tripmate/screens/privacy_settings_screen.dart';
import 'package:tripmate/screens/profile_edit_screen.dart';
import 'package:tripmate/screens/settings_screen.dart';

final UserProfile sampleProfile = UserProfile(
  name: 'Sarah Johnson',
  bio: 'Adventure enthusiast & travel photographer',
  location: 'San Francisco, CA',
  joinDate: '2022',
  profileImageUrl: 'https://images.pexels.com/photos/943084/pexels-photo-943084.jpeg?auto=compress&cs=tinysrgb&w=800',
  pastTrips: [
    Trip(
      name: 'Bali Adventure',
      dates: 'Oct 15-22, 2023',
      rating: 4.9,
      imageUrl: 'https://images.pexels.com/photos/31182223/pexels-photo-31182223/free-photo-of-bustling-tokyo-street-with-neon-signage.jpeg?auto=compress&cs=tinysrgb&w=600',
    ),
    Trip(
      name: 'Tokyo Explorer',
      dates: 'Aug 5-12, 2023',
      rating: 4.9,
      imageUrl: 'https://images.pexels.com/photos/2614818/pexels-photo-2614818.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    ),
    Trip(
      name: 'Paris Expedition',
      dates: 'Jun 10-17, 2023',
      rating: 4.8,
      imageUrl: 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34',
    ),
  ],
);

class ProfileScreen extends StatefulWidget {
  final UserProfile userProfile;
  const ProfileScreen({super.key, required this.userProfile});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _image;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return _buildWideContainers(context);
        } else {
          return _buildNormalContainer(context);
        }
      },
    );
  }

  Widget _buildNormalContainer(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) => _handleMenuSelection(context, value),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'edit_profile',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.grey[700]),
                      SizedBox(width: 10),
                      Text('Edit Profile'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings, color: Colors.grey[700]),
                      SizedBox(width: 10),
                      Text('Settings'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'privacy_settings',
                  child: Row(
                    children: [
                      Icon(Icons.privacy_tip, color: Colors.grey[700]),
                      SizedBox(width: 10),
                      Text('Privacy Settings'),
                    ],
                  ),
                ),
                PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'help',
                  child: Row(
                    children: [
                      Icon(Icons.help_outline, color: Colors.grey[700]),
                      SizedBox(width: 10),
                      Text('Help & Support'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'about',
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.grey[700]),
                      SizedBox(width: 10),
                      Text('About'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'sos',
                  child: Row(
                    children: [
                      Icon(Icons.emergency_outlined, color: Colors.grey[700]),
                      SizedBox(width: 10),
                      Text('Emergency'),
                    ],
                  ),
                ),
              ],
              icon: Icon(Icons.more_vert),
            ),
          ],
        ),
      body: _buildProfileContent(context, isWideScreen: false),
    );
  }

  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'edit_profile':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProfileEditScreen(),
          ),
        );
        break;
      case 'settings':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SettingsScreen(),
          ),
        );
        break;
      case 'privacy_settings':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PrivacySettingsScreen(),
          ),
        );
        break;
      case 'help':
      // Navigate to help screen or open help dialog
        _showHelpDialog(context);
        break;
      case 'about':
        _showAboutDialog(context);
        break;
      case 'sos':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EmergencySosScreen(),
        ),
      );
    }
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Help & Support'),
          content: Text('Need assistance? Contact our support team at support@tripmate.com'),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AboutDialog(
          applicationName: 'TripMate',
          applicationVersion: '1.0.0',
          applicationIcon: FlutterLogo(),
          children: [
            Text('Your travel companion app'),
          ],
        );
      },
    );
  }


  Widget _buildWideContainers(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar with profile info
          Container(
            width: 350,
            color: Colors.grey[100],
            child: _buildProfileHeader(isWideScreen: true),
          ),
          // Main content area
          Expanded(
            child: _buildProfileContent(context, isWideScreen: true),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, {required bool isWideScreen}) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(isWideScreen ? 24.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (!isWideScreen) _buildProfileHeader(isWideScreen: false),

            SizedBox(height: 24),

            _buildProfileTabs(),

            SizedBox(height: 16),

            _buildPastTrips(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader({required bool isWideScreen}) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: isWideScreen ? 80 : 60,
              backgroundImage: _image != null
                  ? FileImage(_image!)
                  : NetworkImage(widget.userProfile.profileImageUrl) as ImageProvider,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: InkWell(
                onTap: _pickImage,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Text(
          widget.userProfile.name,
          style: TextStyle(
            fontSize: isWideScreen ? 28 : 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          widget.userProfile.bio,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: isWideScreen ? 16 : 14,
          ),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on, size: 16, color: Colors.grey),
            Text(
              '${widget.userProfile.location} • Joined ${widget.userProfile.joinDate}',
              style: TextStyle(
                color: Colors.grey,
                fontSize: isWideScreen ? 14 : 12,
              ),
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildProfileTabs() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: [
              Tab(text: 'Past Trips'),
              Tab(text: 'Bookings'),
              Tab(text: 'Reviews'),
            ],
          ),
          // Placeholder for TabBarView if needed
        ],
      ),
    );
  }

  Widget _buildPastTrips(BuildContext context) {
    // Determine the number of columns based on screen width
    int crossAxisCount = _calculateCrossAxisCount(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Past Trips',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8, // Adjust this for desired card proportion
          ),
          itemCount: sampleProfile.pastTrips.length,
          itemBuilder: (context, index) {
            final trip = sampleProfile.pastTrips[index];
            return _buildTripCard(trip);
          },
        ),
      ],
    );
  }

  int _calculateCrossAxisCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width > 1200) return 3;
    if (width > 800) return 2;
    return 1;
  }

  Widget _buildTripCard(Trip trip) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Image.network(
                trip.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          trip.dates,
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      SizedBox(width: 4),
                      Text(
                        trip.rating.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

