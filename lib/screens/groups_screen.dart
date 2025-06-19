import 'package:flutter/material.dart';
import 'package:tripmate/services/travelgroups_service.dart';
import 'package:tripmate/screens/groups_details_screen.dart';

class JoinGroupsScreen extends StatefulWidget {
  const JoinGroupsScreen({super.key});

  @override
  State<JoinGroupsScreen> createState() => _JoinGroupsScreenState();
}

class _JoinGroupsScreenState extends State<JoinGroupsScreen> {
  final TravelGroupsService _travelGroupsService = TravelGroupsService();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> travelGroups = [];
  List<Map<String, dynamic>> filteredGroups = [];
  bool isLoading = true;
  String selectedFilter = 'All Groups';
  String searchQuery = '';

  // List of filter categories
  final List<String> filterCategories = [
    'All Groups',
    'Nearby',
    'This Month',
    'Budget',
  ];

  // Default images for different destinations
  final Map<String, String> defaultImages = {
    'bali': 'https://images.pexels.com/photos/2474690/pexels-photo-2474690.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'paris': 'https://images.pexels.com/photos/161853/paris-france-tower-eiffel-161853.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'italy': 'https://images.pexels.com/photos/208701/pexels-photo-208701.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'swiss': 'https://images.pexels.com/photos/753772/pexels-photo-753772.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'japan': 'https://images.pexels.com/photos/161251/senso-ji-temple-japan-kyoto-landmark-161251.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'thailand': 'https://images.pexels.com/photos/1371360/pexels-photo-1371360.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'default': 'https://images.pexels.com/photos/1271619/pexels-photo-1271619.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
  };

  @override
  void initState() {
    super.initState();
    _loadTravelGroups();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _searchController.text;
    });
    _applyFilters();
  }

  Future<void> _loadTravelGroups() async {
    try {
      setState(() {
        isLoading = true;
      });

      final groups = await _travelGroupsService.getTravelGroups();

      // Process groups to add member counts and images
      List<Map<String, dynamic>> processedGroups = [];

      for (var group in groups) {
        // Get member count
        final memberCount = await _travelGroupsService.getGroupMembersCount(group['group_id']);

        // Check if current user is already a member
        final isCurrentUserMember = await _travelGroupsService.isUserMemberOfGroup(group['group_id']);

        // Add processed data
        processedGroups.add({
          ...group,
          'members': memberCount,
          'image': _getImageForDestination(group['destination'] ?? ''),
          'dates': _formatDates(group['start_date'], group['end_date']),
          'isCurrentUserMember': isCurrentUserMember,
        });
      }

      setState(() {
        travelGroups = processedGroups;
        filteredGroups = processedGroups;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading groups: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = travelGroups;

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((group) {
        final groupName = (group['group_name'] ?? '').toLowerCase();
        final destination = (group['destination'] ?? '').toLowerCase();
        final tags = (group['tags'] ?? '').toLowerCase();
        final query = searchQuery.toLowerCase();

        return groupName.contains(query) ||
            destination.contains(query) ||
            tags.contains(query);
      }).toList();
    }

    // Apply category filter
    switch (selectedFilter) {
      case 'This Month':
        final now = DateTime.now();
        final thisMonth = DateTime(now.year, now.month);
        final nextMonth = DateTime(now.year, now.month + 1);

        filtered = filtered.where((group) {
          try {
            final startDate = DateTime.parse(group['start_date']);
            return startDate.isAfter(thisMonth) && startDate.isBefore(nextMonth);
          } catch (e) {
            return false;
          }
        }).toList();
        break;

      case 'Budget':
      // Filter groups with budget under $1000
        filtered = filtered.where((group) {
          final maxBudget = group['budget_range_max'];
          return maxBudget != null && maxBudget <= 1000;
        }).toList();
        break;

      case 'Nearby':
      // TODO: Implement location-based filtering
      // For now, this is a placeholder
        break;

      case 'All Groups':
      default:
      // No additional filtering needed
        break;
    }

    setState(() {
      filteredGroups = filtered;
    });
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

  String _formatDates(String? startDate, String? endDate) {
    if (startDate == null || endDate == null) return 'TBD';

    try {
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);

      return '${_formatDate(start)} - ${_formatDate(end)}';
    } catch (e) {
      return 'TBD';
    }
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  // This callback will be called when a user joins/leaves a group from the details screen
  void _onGroupActionCompleted() {
    // Refresh the groups list to update member counts and membership status
    _loadTravelGroups();
  }

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
                  // Title with refresh button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Join Groups',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: isLoading ? null : _loadTravelGroups,
                        icon: isLoading
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : const Icon(Icons.refresh),
                        color: Colors.blue,
                      ),
                    ],
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
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search travel groups',
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey[600]),
                            onPressed: () {
                              _searchController.clear();
                            },
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
                  bool isSelected = filterCategories[index] == selectedFilter;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(filterCategories[index]),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            selectedFilter = filterCategories[index];
                          });
                          _applyFilters();
                        }
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

            // Results count
            if (!isLoading && searchQuery.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Found ${filteredGroups.length} groups',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),

            // Travel group grid
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredGroups.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.group_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      searchQuery.isNotEmpty
                          ? 'No groups found for "$searchQuery"'
                          : 'No travel groups found',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      searchQuery.isNotEmpty
                          ? 'Try adjusting your search terms'
                          : 'Be the first to create one!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              )
                  : RefreshIndicator(
                onRefresh: _loadTravelGroups,
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: filteredGroups.length,
                  itemBuilder: (context, index) {
                    final group = filteredGroups[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GroupDetailsScreen(
                              group: group,
                              onJoinGroup: _onGroupActionCompleted, // Now properly passes the callback
                            ),
                          ),
                        );
                      },
                      child: TravelGroupCard(
                        name: group['group_name'] ?? 'Unknown Group',
                        location: group['destination'] ?? 'Unknown',
                        dates: group['dates'] ?? 'TBD',
                        members: group['members'] ?? 0,
                        status: group['status'] ?? 'Open',
                        imagePath: group['image'],
                        isCurrentUserMember: group['isCurrentUserMember'] ?? false,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Navigate to create group screen and refresh when returning
          final result = await Navigator.pushNamed(context, '/create_groups');
          if (result == true) {
            // Refresh the groups list if a group was created
            _loadTravelGroups();
          }
        },
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Create a group",
          style: TextStyle(color: Colors.white),
        ),
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
  final bool isCurrentUserMember;

  const TravelGroupCard({
    super.key,
    required this.name,
    required this.location,
    required this.dates,
    required this.members,
    required this.status,
    required this.imagePath,
    this.isCurrentUserMember = false,
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
          // Image with member badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: AspectRatio(
                  aspectRatio: 1.5,
                  child: Image.network(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 40, color: Colors.grey),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Member badge
              if (isCurrentUserMember)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Joined',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
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
                        color: status == 'Open' ? Colors.green[50] : Colors.orange[50],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: status == 'Open' ? Colors.green[600] : Colors.orange[600],
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

