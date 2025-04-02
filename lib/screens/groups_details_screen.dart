import 'package:flutter/material.dart';

class GroupDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> groupData;

  const GroupDetailsScreen({
    super.key,
    required this.groupData,
  });

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.groupData;
    final String title = group['title'] ?? 'Group Trip';
    final String location = group['location'] ?? 'Unknown Location';
    final String dateRange = group['dateRange'] ?? 'TBD';
    final String hostName = group['hostName'] ?? 'Unknown Host';
    final double hostRating = group['hostRating'] ?? 0.0;
    final int hostTrips = group['hostTrips'] ?? 0;
    final String budget = group['budget'] ?? 'Unknown';
    final String duration = group['duration'] ?? 'Unknown';
    final String spots = group['spots'] ?? 'Unknown';
    final String about = group['about'] ?? 'No description available.';
    final List<Map<String, dynamic>> activities = List<Map<String, dynamic>>.from(
        group['activities'] ?? []);
    final String status = group['status'] ?? 'Closed';

    return Scaffold(
      body: Stack(
        children: [
          // Background image with gradient overlay
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(group['imageUrl'] ?? 'https://via.placeholder.com/400x200'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Content
          CustomScrollView(
            slivers: [
              // App bar with back button and share icon
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.share, color: Colors.black),
                      onPressed: () {},
                    ),
                  ),
                ],
                floating: true,
                pinned: false,
                expandedHeight: MediaQuery.of(context).size.height * 0.25,
              ),

              // Rest of the content
              SliverList(
                delegate: SliverChildListDelegate([
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and location
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 25, 20, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    location,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(
                                    ' • ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(
                                    dateRange,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Host information
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage(
                                  group['hostImageUrl'] ?? 'https://via.placeholder.com/40x40',
                                ),
                              ),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hosted by $hostName',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.star, color: Colors.amber, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        '$hostRating • ($hostTrips trips)',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Spacer(),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                                decoration: BoxDecoration(
                                  color: status.toLowerCase() == 'open' ? Colors.green[100] : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    color: status.toLowerCase() == 'open' ? Colors.green[800] : Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Trip details
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildTripDetail('Budget', budget),
                                VerticalDivider(color: Colors.grey[300], thickness: 1),
                                _buildTripDetail('Duration', duration),
                                VerticalDivider(color: Colors.grey[300], thickness: 1),
                                _buildTripDetail('Group', spots),
                              ],
                            ),
                          ),
                        ),

                        // Tabs
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: TabBar(
                            controller: _tabController,
                            labelColor: Colors.blue[700],
                            unselectedLabelColor: Colors.grey[600],
                            indicator: UnderlineTabIndicator(
                              borderSide: BorderSide(color: Colors.blue, width: 2),
                              insets: EdgeInsets.symmetric(horizontal: 45),
                            ),
                            tabs: [
                              Tab(text: 'Overview'),
                              Tab(text: 'Members'),
                              Tab(text: 'Discussions'),
                            ],
                          ),
                        ),

                        // Tab content
                        SizedBox(
                          height: 500, // Set a height or use IndexedStack if needed
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              // Overview tab
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'About this trip',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      about,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[800],
                                        height: 1.5,
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      'Activities',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 15),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: activities.map((activity) {
                                        return _buildActivityItem(
                                          icon: _getActivityIcon(activity['type']),
                                          label: activity['name'] ?? 'Activity',
                                        );
                                      }).toList(),
                                    ),
                                    SizedBox(height: 40),
                                  ],
                                ),
                              ),

                              // Members tab (placeholder)
                              Center(child: Text('Members content')),

                              // Discussions tab (placeholder)
                              Center(child: Text('Discussions content')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          ),

          // Join button at the bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Request to Join',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripDetail(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({required IconData icon, required String label}) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.blue,
            size: 24,
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  IconData _getActivityIcon(String? activityType) {
    switch (activityType?.toLowerCase()) {
      case 'hiking':
        return Icons.directions_walk;
      case 'photography':
        return Icons.camera_alt;
      case 'food':
        return Icons.restaurant;
      case 'culture':
        return Icons.account_balance;
      case 'adventure':
        return Icons.landscape;
      case 'nightlife':
        return Icons.nightlife;
      case 'shopping':
        return Icons.shopping_bag;
      case 'sightseeing':
        return Icons.remove_red_eye;
      default:
        return Icons.star;
    }
  }
}

// Example usage:
class GroupDetailsExample extends StatelessWidget {
  const GroupDetailsExample ({super.key});
  @override
  Widget build(BuildContext context) {
    final exampleGroupData = {
      'title': 'Mountain Explorers',
      'location': 'Swiss Alps',
      'dateRange': 'Aug 15-22',
      'imageUrl': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4',
      'hostName': 'Sarah',
      'hostImageUrl': 'https://randomuser.me/api/portraits/women/44.jpg',
      'hostRating': 4.9,
      'hostTrips': 120,
      'budget': '\$1000-2000',
      'duration': '8 days',
      'spots': '6/8 spots',
      'status': 'Open',
      'about': 'Join us for an incredible 8-day adventure in the Swiss Alps. We\'ll explore stunning mountain trails, experience local culture, and create unforgettable memories together.',
      'activities': [
        {'type': 'hiking', 'name': 'Hiking'},
        {'type': 'photography', 'name': 'Photography'},
        {'type': 'food', 'name': 'Local Food'},
        {'type': 'culture', 'name': 'Culture'},
      ],
    };

    return MaterialApp(
      home: GroupDetailsScreen(groupData: exampleGroupData),
    );
  }
}