import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateNewGroupScreen extends StatelessWidget {
  const CreateNewGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _CreateNewGroupContent();
  }
}

class _CreateNewGroupContent extends StatefulWidget {
  @override
  _CreateNewGroupContentState createState() => _CreateNewGroupContentState();
}

class _CreateNewGroupContentState extends State<_CreateNewGroupContent> {
  // Date controllers
  DateTime? startDate;
  DateTime? endDate;

  // Selected activities
  final Map<String, bool> selectedActivities = {
    'Hiking': false,
    'Road Trips': false,
    'Photography': false,
    'Food Tours': false,
    'Sightseeing': false,
    'Adventure': false,
    'Cultural': false,
    'Nightlife': false,
    'Shopping': false,
  };

  // Activity icons
  final Map<String, IconData> activityIcons = {
    'Hiking': Icons.directions_walk,
    'Road Trips': Icons.directions_car,
    'Photography': Icons.camera_alt,
    'Food Tours': Icons.restaurant,
    'Sightseeing': Icons.account_balance,
    'Adventure': Icons.landscape,
    'Cultural': Icons.emoji_events,
    'Nightlife': Icons.nightlife,
    'Shopping': Icons.shopping_bag,
  };

  // Budget controller
  String budgetRange = "\$500 - \$1000";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Create New Group',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Container(
            color: Colors.grey[300],
            height: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Destination field
              _buildSectionTitle('Where are you going?'),
              _buildDestinationField(),
              SizedBox(height: 24),

              // Travel dates
              _buildSectionTitle('When are you traveling?'),
              _buildDateSelectionRow(),
              SizedBox(height: 24),

              // Budget range
              _buildSectionTitle('What\'s your budget range?'),
              _buildBudgetField(),
              SizedBox(height: 24),

              // Activities
              _buildSectionTitle('What activities interest you?'),
              _buildActivitiesGrid(),
              SizedBox(height: 32),

              // Create group button
              _buildCreateGroupButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDestinationField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search destination',
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.location_on_outlined, color: Colors.grey[400]),
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildDateSelectionRow() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _selectDate(true),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.grey[400], size: 20),
                  SizedBox(width: 8),
                  Text(
                    startDate == null
                        ? 'Start date'
                        : DateFormat('MMM d, yyyy').format(startDate!),
                    style: TextStyle(
                      color: startDate == null ? Colors.grey[400] : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => _selectDate(false),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.grey[400], size: 20),
                  SizedBox(width: 8),
                  Text(
                    endDate == null
                        ? 'End date'
                        : DateFormat('MMM d, yyyy').format(endDate!),
                    style: TextStyle(
                      color: endDate == null ? Colors.grey[400] : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(bool isStartDate) async {
    final initialDate = isStartDate
        ? (startDate ?? DateTime.now())
        : (endDate ?? (startDate != null ? startDate!.add(Duration(days: 1)) : DateTime.now().add(Duration(days: 1))));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: isStartDate ? DateTime.now() : (startDate ?? DateTime.now()),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
          // If end date is before the new start date, reset end date
          if (endDate != null && endDate!.isBefore(picked)) {
            endDate = null;
          }
        } else {
          endDate = picked;
        }
      });
    }
  }

  Widget _buildBudgetField() {
    return GestureDetector(
      onTap: _showBudgetDialog,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.account_balance_wallet_outlined, color: Colors.grey[400]),
            SizedBox(width: 8),
            Text(
              budgetRange,
              style: TextStyle(color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  void _showBudgetDialog() {
    final List<String> budgetOptions = [
      'Under \$500',
      '\$500 - \$1000',
      '\$1000 - \$2000',
      '\$2000 - \$5000',
      'Over \$5000',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Budget Range'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: budgetOptions.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(budgetOptions[index]),
                onTap: () {
                  setState(() {
                    budgetRange = budgetOptions[index];
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.25,
      ),
      itemCount: selectedActivities.length,
      itemBuilder: (context, index) {
        final activity = selectedActivities.keys.elementAt(index);
        final isSelected = selectedActivities[activity]!;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedActivities[activity] = !isSelected;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
              color: isSelected ? Colors.blue[50] : Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  activityIcons[activity],
                  color: isSelected ? Colors.blue : Colors.blue[300],
                  size: 28,
                ),
                SizedBox(height: 8),
                Text(
                  activity,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCreateGroupButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        onPressed: () {
          // Show confirmation
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Group created successfully!')),
          );

          // Navigate back or to next screen
          // Navigator.pop(context);
        },
        child: Text(
          'Create Group',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}