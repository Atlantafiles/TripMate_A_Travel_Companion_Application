import 'package:flutter/material.dart';

class JoinGroupsScreen extends StatelessWidget {
  JoinGroupsScreen({super.key});

  // List of travel groups
  final List<Map<String, dynamic>> travelGroups = [
    {
      'name': 'Mountain Explorers',
      'location': 'Swiss Alps',
      'dates': 'Aug 15-22',
      'members': 6,
      'status': 'Open',
      'image': 'https://images.pexels.com/photos/753772/pexels-photo-753772.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    },
    {
      'name': 'Beach Paradise',
      'location': 'Bali',
      'dates': 'Sep 10-17',
      'members': 4,
      'status': 'Open',
      'image': 'assets/images/beach.jpg',
    },
    {
      'name': 'City Wanderers',
      'location': 'Paris',
      'dates': 'Oct 1-7',
      'members': 8,
      'status': 'Open',
      'image': 'assets/images/paris.jpg',
    },
    {
      'name': 'Venice Adventure',
      'location': 'Italy',
      'dates': 'Sep 20-27',
      'members': 5,
      'status': 'Open',
      'image': 'https://images.pexels.com/photos/208701/pexels-photo-208701.jpeg',
    },
  ];

  // List of filter categories
  final List<String> filterCategories = [
    'All Groups',
    'Nearby',
    'This Month',
    'Budget',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and search bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Text(
                    'Join Groups',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Search bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search travel groups',
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        Icon(Icons.tune, color: Colors.grey[600]),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Filter categories
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: filterCategories.length,
                itemBuilder: (context, index) {
                  bool isSelected = index == 0; // First item is selected by default
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(filterCategories[index]),
                      onSelected: (selected) {
                        // Handle filter selection
                      },
                      backgroundColor: Colors.white,
                      selectedColor: Colors.blue,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // Travel group grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: travelGroups.length,
                itemBuilder: (context, index) {
                  final group = travelGroups[index];
                  return GestureDetector(
                    onTap: () {
                      // Navigate to group details screen when a card is tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GroupDetailsScreen(group: group),
                        ),
                      );
                    },
                    child: TravelGroupCard(
                      name: group['name'],
                      location: group['location'],
                      dates: group['dates'],
                      members: group['members'],
                      status: group['status'],
                      imagePath: group['image'],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16, right: 16),
            child: FloatingActionButton.extended(
              onPressed: () {
                // Action for creating a group
                Navigator.pushNamed(context, '/create_groups');
              },
              backgroundColor: Colors.blue,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "Create a group",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class TravelGroupCard extends StatelessWidget {
  final String name;
  final String location;
  final String dates;
  final int members;
  final String status;
  final String imagePath;

  const TravelGroupCard({
    super.key,
    required this.name,
    required this.location,
    required this.dates,
    required this.members,
    required this.status,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 1.5,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback for missing images
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 40, color: Colors.grey),
                  );
                },
              ),
            ),
          ),

          // Group details
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Group name
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                // Location and dates
                Text(
                  '$location • $dates',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                // Members and status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Members count
                    Row(
                      children: [
                        Icon(Icons.people_outline, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '$members',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    // Status chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: Colors.green[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// New GroupDetailsScreen class for displaying the details of a selected group
class GroupDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> group;

  const GroupDetailsScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(group['name']),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group image
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.asset(
                group['image'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.image, size: 64, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),

            // Group info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Group name and status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          group['name'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          group['status'],
                          style: TextStyle(
                            color: Colors.green[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Location
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 20, color: Colors.grey[700]),
                      const SizedBox(width: 8),
                      Text(
                        group['location'],
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Dates
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 20, color: Colors.grey[700]),
                      const SizedBox(width: 8),
                      Text(
                        group['dates'],
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Members
                  Row(
                    children: [
                      Icon(Icons.people_outline, size: 20, color: Colors.grey[700]),
                      const SizedBox(width: 8),
                      Text(
                        '${group['members']} members',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'About this trip',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Join this amazing trip to ${group['location']}! Experience the beauty and culture of this destination with a friendly group of travelers. The trip includes accommodations, guided tours, and plenty of free time to explore on your own.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Join button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle join group action
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Request sent to join this group!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Join This Group',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
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