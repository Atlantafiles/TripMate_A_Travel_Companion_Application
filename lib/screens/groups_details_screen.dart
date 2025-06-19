import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tripmate/services/travelgroups_service.dart';

class GroupDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> group;
  final VoidCallback? onJoinGroup;

  const GroupDetailsScreen({
    super.key,
    required this.group,
    this.onJoinGroup,
  });

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  final TravelGroupsService _travelGroupsService = TravelGroupsService();
  bool _isLoading = false;
  bool _isCurrentUserMember = false;
  bool _isCurrentUserCreator = false; // Add this to track if user is creator
  int _membersCount = 0;

  @override
  void initState() {
    super.initState();
    _checkMembershipStatus();
    _loadMembersCount();
    _checkIfUserIsCreator(); // Add this check
  }

  Future<void> _checkMembershipStatus() async {
    try {
      final isMember = await _travelGroupsService.isUserMemberOfGroup(
        widget.group['group_id'] ?? widget.group['id']?.toString() ?? '',
      );
      if (mounted) {
        setState(() {
          _isCurrentUserMember = isMember;
        });
      }
    } catch (e) {
      print('Error checking membership status: $e');
    }
  }

  // Add method to check if current user is the creator
  Future<void> _checkIfUserIsCreator() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final groupCreatorId = widget.group['created_by'];
        if (mounted) {
          setState(() {
            _isCurrentUserCreator = (user.id == groupCreatorId);
          });
        }
      }
    } catch (e) {
      print('Error checking if user is creator: $e');
    }
  }

  Future<void> _loadMembersCount() async {
    try {
      final count = await _travelGroupsService.getGroupMembersCount(
        widget.group['group_id'] ?? widget.group['id']?.toString() ?? '',
      );
      if (mounted) {
        setState(() {
          _membersCount = count;
        });
      }
    } catch (e) {
      print('Error loading members count: $e');
    }
  }

  Future<void> _joinGroup() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final groupId = widget.group['group_id'] ?? widget.group['id']?.toString() ?? '';

      if (groupId.isEmpty) {
        throw Exception('Invalid group ID');
      }

      print('Attempting to join group: $groupId');

      await _travelGroupsService.joinTravelGroup(groupId);

      if (mounted) {
        setState(() {
          _isCurrentUserMember = true;
          _membersCount += 1;
          _isLoading = false;
        });

        _showMessage('Successfully joined the group!', isError: false);
        widget.onJoinGroup?.call();
      }
    } catch (error) {
      print('Join group error: $error');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showMessage('Failed to join group: $error', isError: true);
      }
    }
  }

  Future<void> _leaveGroup() async {
    // Show confirmation dialog
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Group'),
        content: const Text('Are you sure you want to leave this group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Leave', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLeave != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _travelGroupsService.leaveTravelGroup(
        widget.group['group_id'] ?? widget.group['id']?.toString() ?? '',
      );

      if (mounted) {
        setState(() {
          _isCurrentUserMember = false;
          _membersCount = _membersCount > 0 ? _membersCount - 1 : 0;
          _isLoading = false;
        });

        _showMessage('Successfully left the group', isError: false);
        widget.onJoinGroup?.call();
      }
    } catch (error) {
      print('Leave group error: $error');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Check if this is a creator trying to leave
        if (error.toString().contains('Group creators cannot leave')) {
          _showCreatorLeaveDialog();
        } else {
          _showMessage('Failed to leave group: $error', isError: true);
        }
      }
    }
  }

  // Show dialog for creators who try to leave
  void _showCreatorLeaveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cannot Leave Group'),
        content: const Text(
          'As the group creator, you cannot leave this group. You can either delete the group or transfer ownership to another member.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showDeleteGroupDialog();
            },
            child: const Text(
              'Delete Group',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // Show delete group confirmation dialog
  void _showDeleteGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to delete this group?'),
            const SizedBox(height: 8),
            const Text(
              'This action cannot be undone and will:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            const Text('• Remove all members from the group'),
            const Text('• Delete all group data permanently'),
            const Text('• Cancel any planned activities'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteGroup();
            },
            child: const Text(
              'Delete Permanently',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // Delete the group
  Future<void> _deleteGroup() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final groupId = widget.group['group_id'] ?? widget.group['id']?.toString() ?? '';

      final success = await _travelGroupsService.deleteTravelGroup(groupId);

      if (success && mounted) {
        _showMessage('Group deleted successfully', isError: false);

        // Navigate back to previous screen
        Navigator.pop(context);
        widget.onJoinGroup?.call(); // Refresh the parent screen
      }
    } catch (error) {
      print('Delete group error: $error');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showMessage('Failed to delete group: $error', isError: true);
      }
    }
  }

  void _showMessage(String message, {required bool isError}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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

  String _formatBudgetRange(double? min, double? max) {
    if (min == null || max == null) return 'Budget not specified';
    if (min == max) return '\$${min.toInt()}';
    return '\$${min.toInt()} - \$${max.toInt()}';
  }

  List<String> _parseActivities(String? tags) {
    if (tags == null || tags.isEmpty) return [];
    return tags.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group['group_name'] ?? 'Group Details'),
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
              child: Image.network(
                widget.group['image'] ?? 'https://images.pexels.com/photos/1271619/pexels-photo-1271619.jpeg',
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
                          widget.group['group_name'] ?? 'Unknown Group',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: widget.group['status'] == 'Open' ? Colors.green[50] : Colors.orange[50],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.group['status'] ?? 'Open',
                          style: TextStyle(
                            color: widget.group['status'] == 'Open' ? Colors.green[600] : Colors.orange[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Location
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 20, color: Colors.grey[700]),
                      const SizedBox(width: 8),
                      Text(
                        widget.group['destination'] ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Dates
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 20, color: Colors.grey[700]),
                      const SizedBox(width: 8),
                      Text(
                        widget.group['dates'] ?? _formatDates(widget.group['start_date'], widget.group['end_date']),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Members
                  Row(
                    children: [
                      Icon(Icons.people_outline, size: 20, color: Colors.grey[700]),
                      const SizedBox(width: 8),
                      Text(
                        '$_membersCount members',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Budget range
                  if (widget.group['budget_range_min'] != null && widget.group['budget_range_max'] != null)
                    Row(
                      children: [
                        Icon(Icons.attach_money, size: 20, color: Colors.grey[700]),
                        const SizedBox(width: 8),
                        Text(
                          _formatBudgetRange(
                            widget.group['budget_range_min']?.toDouble(),
                            widget.group['budget_range_max']?.toDouble(),
                          ),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 24),

                  // Activities
                  if (widget.group['tags'] != null && widget.group['tags'].isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Activities',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: _parseActivities(widget.group['tags'])
                              .map((activity) => Chip(
                            label: Text(activity),
                            backgroundColor: Colors.blue[50],
                            labelStyle: TextStyle(color: Colors.blue[700]),
                          ))
                              .toList(),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),

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
                    widget.group['description'] ??
                        'Join this amazing trip to ${widget.group['destination'] ?? 'this destination'}! Experience the beauty and culture of this destination with a friendly group of travelers. The trip includes accommodations, guided tours, and plenty of free time to explore on your own.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Join/Leave button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : widget.group['status'] == 'Open'
                          ? (_isCurrentUserMember ? _leaveGroup : _joinGroup)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isCurrentUserMember ? Colors.red : Colors.blue,
                        disabledBackgroundColor: Colors.grey[300],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : Text(
                        _isCurrentUserMember
                            ? (_isCurrentUserCreator ? 'Manage Group' : 'Leave Group')
                            : widget.group['status'] == 'Open'
                            ? 'Join This Group'
                            : 'Group is ${widget.group['status']}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: (widget.group['status'] == 'Open' && !_isLoading)
                              ? Colors.white
                              : Colors.grey[600],
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