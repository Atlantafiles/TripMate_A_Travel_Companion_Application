import 'package:flutter/material.dart';
import 'package:tripmate/models/emergency_model.dart';

class EmergencySosScreen extends StatelessWidget {
  EmergencySosScreen ({super.key});

  // Sample emergency contacts
  final List<EmergencyContact> contacts = [
    EmergencyContact(name: 'John Smith', relationship: 'Brother'),
    EmergencyContact(name: 'Mary Johnson', relationship: 'Friend'),
    EmergencyContact(name: 'Robert Wilson', relationship: 'Emergency Contact'),
  ];

  @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Emergency SOS',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // SOS Button
              GestureDetector(
                onLongPress: () {
                  // Implement SOS activation logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('SOS Activated'))
                  );
                },
                child: Container(
                  width: 250,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.5),
                        spreadRadius: 10,
                        blurRadius: 20,
                      )
                    ]
                  ),
                  child: Center(
                    child: Text(
                      'SOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Instruction Text
              Text(
                'Press and hold to activate SOS',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),

              SizedBox(height: 32),

              // Emergency Contacts Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Text(
                      'Emergency Contacts',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Contact List
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey[300],
                        child: Icon(Icons.person, color: Colors.grey[600]),
                      ),
                      title: Text(
                        contact.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(contact.relationship),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Call Icon
                          IconButton(
                            icon: Icon(Icons.call, color: Colors.blue),
                            onPressed: () {
                              // Implement call functionality
                              _showCallDialog(context, contact.name);
                            },
                          ),
                          // Message Icon
                          IconButton(
                            icon: Icon(Icons.message, color: Colors.green),
                            onPressed: () {
                              // Implement message functionality
                              _showMessageDialog(context, contact.name);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Location Sharing Info
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.grey),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Location sharing will be activated during emergency',
                        style: TextStyle(
                          color: Colors.grey,
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

    // Dialog to simulate calling
    void _showCallDialog(BuildContext context, String contactName) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Calling'),
            content: Text('Calling $contactName...'),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    // Dialog to simulate messaging
    void _showMessageDialog(BuildContext context, String contactName) {
      final TextEditingController messageController = TextEditingController();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Send Message to $contactName'),
            content: TextField(
              controller: messageController,
              decoration: InputDecoration(
                hintText: 'Type your emergency message...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: Text('Send'),
                onPressed: () {
                  // Implement send message logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Message sent to $contactName'))
                  );
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
}