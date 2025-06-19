import 'package:flutter/material.dart';
import 'package:tripmate/screens/profile_screen.dart';
import 'package:tripmate/services/travelgroups_service.dart';
import 'package:tripmate/screens/groups_details_screen.dart';

void main() {
  runApp(const TripMateApp());
}

class TripMateApp extends StatelessWidget {
  const TripMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Icon(Icons.location_on, color: Colors.black),
        title: Text("New York", style: TextStyle(color: Colors.black)),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen(userProfile: sampleProfile,)),
              );
            },
            child: const CircleAvatar(
              backgroundImage: NetworkImage(
                  "https://images.pexels.com/photos/943084/pexels-photo-943084.jpeg?auto=compress&cs=tinysrgb&w=800"),
            ),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SearchBar(),
              SizedBox(height: 20),
              SectionTitle("Featured Groups"),
              FeaturedGroups(),
              SizedBox(height: 20),
              SectionTitle("Recommended for You"),
              RecommendedForYou(),
              SizedBox(height: 20),
              SectionTitle("Popular Destinations"),
              PopularDestinations(),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  const SearchBar({super.key});
  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: "Where do you want to go?",
        prefixIcon: Icon(Icons.search, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}

class FeaturedGroups extends StatefulWidget {
  const FeaturedGroups({super.key});

  @override
  State<FeaturedGroups> createState() => _FeaturedGroupsState();
}

class _FeaturedGroupsState extends State<FeaturedGroups> {
  final TravelGroupsService _travelGroupsService = TravelGroupsService();
  List<Map<String, dynamic>> featuredGroups = [];
  bool isLoading = true;

  // Default images for different destinations
  final Map<String, String> defaultImages = {
    'bali': 'https://images.pexels.com/photos/2474690/pexels-photo-2474690.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'paris': 'https://images.pexels.com/photos/161853/paris-france-tower-eiffel-161853.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'italy': 'https://images.pexels.com/photos/208701/pexels-photo-208701.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'swiss': 'https://images.pexels.com/photos/753772/pexels-photo-753772.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'japan': 'https://images.pexels.com/photos/161251/senso-ji-temple-japan-kyoto-landmark-161251.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'thailand': 'https://images.pexels.com/photos/1371360/pexels-photo-1371360.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'mountain': 'https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0',
    'beach': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e',
    'default': 'https://images.pexels.com/photos/1271619/pexels-photo-1271619.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
  };

  @override
  void initState() {
    super.initState();
    _loadFeaturedGroups();
  }

  Future<void> _loadFeaturedGroups() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Get all travel groups
      final groups = await _travelGroupsService.getTravelGroups();

      // Process groups to add member counts and images
      List<Map<String, dynamic>> processedGroups = [];

      for (var group in groups) {
        // Get member count for each group
        final memberCount = await _travelGroupsService.getGroupMembersCount(group['group_id']);

        // Add processed data
        processedGroups.add({
          ...group,
          'members': memberCount,
          'image': _getImageForDestination(group['destination'] ?? ''),
          'rating': _generateRating(), // Generate a random rating for display
        });
      }

      // Sort by least number of members and take first 2
      processedGroups.sort((a, b) => (a['members'] as int).compareTo(b['members'] as int));

      setState(() {
        featuredGroups = processedGroups.take(2).toList();
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error loading featured groups: $error');
    }
  }

  String _getImageForDestination(String destination) {
    final lowerDestination = destination.toLowerCase();
    for (var key in defaultImages.keys) {
      if (key != 'default' && lowerDestination.contains(key)) {
        return defaultImages[key]!;
      }
    }
    return defaultImages['default']!;
  }

  String _generateRating() {
    // Generate a random rating between 4.0 and 5.0
    final ratings = ['4.5', '4.6', '4.7', '4.8', '4.9', '5.0'];
    ratings.shuffle();
    return ratings.first;
  }

  void _onGroupTap(Map<String, dynamic> group) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupDetailsScreen(
          group: group,
          onJoinGroup: () {
            // Refresh featured groups when user joins/leaves a group
            _loadFeaturedGroups();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 200,
        child: Row(
          children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (featuredGroups.isEmpty) {
      return SizedBox(
        height: 200,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.group_outlined, size: 40, color: Colors.grey[400]),
                SizedBox(height: 8),
                Text(
                  'No travel groups found',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  'Be the first to create one!',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: featuredGroups
          .map((group) => Expanded(
        child: GestureDetector(
          onTap: () => _onGroupTap(group),
          child: Card(
            elevation: 2,
            margin: EdgeInsets.symmetric(horizontal: 4),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(10)),
                  child: Image.network(
                    group["image"]!,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 100,
                        color: Colors.grey[300],
                        child: Icon(Icons.image, size: 40, color: Colors.grey),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 100,
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group["group_name"] ?? "Unknown Group",
                        style: TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        group["destination"] ?? "Unknown Location",
                        style: TextStyle(color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 16),
                              Text(group["rating"]!)
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.people_outline, size: 16, color: Colors.grey[600]),
                              SizedBox(width: 2),
                              Text(
                                '${group["members"]}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ))
          .toList(),
    );
  }
}

class RecommendedForYou extends StatelessWidget {
  const RecommendedForYou({super.key});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            child: Image.network(
              "https://images.unsplash.com/photo-1502602898657-3e91760cbb34",
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Paris Explorer", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("7 days", style: TextStyle(color: Colors.grey)),
                Row(
                  children: [
                    Text("₹1,299", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                    Spacer(),
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    Text("4.9")
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class PopularDestinations extends StatelessWidget {
  final List<Map<String, String>> destinations = [
    {
      "city": "Rome",
      "country": "Italy",
      "trips": "248",
      "image": "https://images.pexels.com/photos/2827374/pexels-photo-2827374.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2"
    },
    {
      "city": "Bangkok",
      "country": "Thailand",
      "trips": "186",
      "image": "https://images.pexels.com/photos/2678418/pexels-photo-2678418.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2"
    },
    {
      "city": "Barcelona",
      "country": "Spain",
      "trips": "167",
      "image": "https://images.pexels.com/photos/31140605/pexels-photo-31140605/free-photo-of-stunning-wooden-church-in-karelia-russia.jpeg?auto=compress&cs=tinysrgb&w=800"
    },
    {
      "city": "Amsterdam",
      "country": "Netherlands",
      "trips": "159",
      "image": "https://images.pexels.com/photos/31160557/pexels-photo-31160557/free-photo-of-golden-pavilion-reflected-in-tranquil-pond-kyoto.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2"
    },
  ];

  PopularDestinations({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: destinations.length,
      itemBuilder: (context, index) {
        final destination = destinations[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(destination["image"]!, width: double.infinity, height: double.infinity, fit: BoxFit.cover),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(destination["city"]!, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(destination["country"]!, style: TextStyle(color: Colors.white)),
                    Text("${destination["trips"]} trips", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}