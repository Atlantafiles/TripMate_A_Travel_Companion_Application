import 'package:flutter/material.dart';
import 'package:tripmate/models/notif_model.dart';

class NotificationsScreen extends StatelessWidget {
   NotificationsScreen ({super.key});

  // Sample notification data
  final List<NotificationItem> notifications = [
    NotificationItem(
      title: 'Trip Reminder',
      subtitle: 'Your trip to Bali starts tomorrow!',
      timeSince: '2h ago',
      icon: Icons.flight_takeoff
    ),
    NotificationItem(
      title: 'New Group Invite',
      subtitle: 'Join \'Adventure Seekers\' group',
      timeSince: '5h ago',
      icon: Icons.group_add
    ),
    NotificationItem(
      title: 'Review Request',
      subtitle: 'Rate your Tokyo trip experience',
      timeSince: '1d ago',
      icon: Icons.star_border
   ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
            children: [
              _buildFilterChip(context, 'All', isSelected: true),
              SizedBox(width: 8),
              _buildFilterChip(context, 'Trips'),
              SizedBox(width: 8),
              _buildFilterChip(context, 'Groups'),
            ],
          ),
        ),
      ),
    ),
    body: LayoutBuilder(
      builder: (context, constraints) {
        return ListView.separated(
          padding: EdgeInsets.symmetric(
            vertical: 16,
            horizontal: constraints.maxWidth > 600 ?
            constraints.maxWidth * 0.2 : 16
          ),
          itemCount: notifications.length,
          separatorBuilder: (context, index) => Divider(
            color: Colors.grey.shade300,
            height: 1,
          ),
          itemBuilder: (context, index) {
            final notification = notifications[index];
              return ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade50,
                  child: Icon(
                    notification.icon,
                    color: Colors.blue,
                  ),
                ),
                title: Text(
                notification.title,
                style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  notification.subtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                trailing: Text(
                  notification.timeSince,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Helper method to create filter chips
  Widget _buildFilterChip(BuildContext context, String label, {bool isSelected = false}) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {},
      selectedColor: Colors.blue.shade100,
      backgroundColor: Colors.grey.shade200,
      labelStyle: TextStyle(
        color: isSelected ? Colors.blue : Colors.black54,
      ),
    );
  }
}