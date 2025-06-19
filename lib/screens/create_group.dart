// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// class CreateNewGroupScreen extends StatelessWidget {
//   const CreateNewGroupScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return _CreateNewGroupContent();
//   }
// }
//
// class _CreateNewGroupContent extends StatefulWidget {
//   @override
//   _CreateNewGroupContentState createState() => _CreateNewGroupContentState();
// }
//
// class _CreateNewGroupContentState extends State<_CreateNewGroupContent> {
//   // Date controllers
//   DateTime? startDate;
//   DateTime? endDate;
//
//   // Selected activities
//   final Map<String, bool> selectedActivities = {
//     'Hiking': false,
//     'Road Trips': false,
//     'Photography': false,
//     'Food Tours': false,
//     'Sightseeing': false,
//     'Adventure': false,
//     'Cultural': false,
//     'Nightlife': false,
//     'Shopping': false,
//   };
//
//   // Activity icons
//   final Map<String, IconData> activityIcons = {
//     'Hiking': Icons.directions_walk,
//     'Road Trips': Icons.directions_car,
//     'Photography': Icons.camera_alt,
//     'Food Tours': Icons.restaurant,
//     'Sightseeing': Icons.account_balance,
//     'Adventure': Icons.landscape,
//     'Cultural': Icons.emoji_events,
//     'Nightlife': Icons.nightlife,
//     'Shopping': Icons.shopping_bag,
//   };
//
//   // Budget controller
//   String budgetRange = "\$500 - \$1000";
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         title: const Text(
//           'Create New Group',
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.close, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         bottom: PreferredSize(
//           preferredSize: Size.fromHeight(1),
//           child: Container(
//             color: Colors.grey[300],
//             height: 1,
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Destination field
//               _buildSectionTitle('Where are you going?'),
//               _buildDestinationField(),
//               SizedBox(height: 24),
//
//               // Travel dates
//               _buildSectionTitle('When are you traveling?'),
//               _buildDateSelectionRow(),
//               SizedBox(height: 24),
//
//               // Budget range
//               _buildSectionTitle('What\'s your budget range?'),
//               _buildBudgetField(),
//               SizedBox(height: 24),
//
//               // Activities
//               _buildSectionTitle('What activities interest you?'),
//               _buildActivitiesGrid(),
//               SizedBox(height: 32),
//
//               // Create group button
//               _buildCreateGroupButton(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Text(
//         title,
//         style: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.w500,
//           color: Colors.black87,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDestinationField() {
//     return Container(
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey[300]!),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: TextField(
//         decoration: InputDecoration(
//           hintText: 'Search destination',
//           hintStyle: TextStyle(color: Colors.grey[400]),
//           border: InputBorder.none,
//           prefixIcon: Icon(Icons.location_on_outlined, color: Colors.grey[400]),
//           contentPadding: EdgeInsets.symmetric(vertical: 14),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDateSelectionRow() {
//     return Row(
//       children: [
//         Expanded(
//           child: GestureDetector(
//             onTap: () => _selectDate(true),
//             child: Container(
//               padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey[300]!),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.calendar_today, color: Colors.grey[400], size: 20),
//                   SizedBox(width: 8),
//                   Text(
//                     startDate == null
//                         ? 'Start date'
//                         : DateFormat('MMM d, yyyy').format(startDate!),
//                     style: TextStyle(
//                       color: startDate == null ? Colors.grey[400] : Colors.black,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         SizedBox(width: 12),
//         Expanded(
//           child: GestureDetector(
//             onTap: () => _selectDate(false),
//             child: Container(
//               padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey[300]!),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.calendar_today, color: Colors.grey[400], size: 20),
//                   SizedBox(width: 8),
//                   Text(
//                     endDate == null
//                         ? 'End date'
//                         : DateFormat('MMM d, yyyy').format(endDate!),
//                     style: TextStyle(
//                       color: endDate == null ? Colors.grey[400] : Colors.black,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Future<void> _selectDate(bool isStartDate) async {
//     final initialDate = isStartDate
//         ? (startDate ?? DateTime.now())
//         : (endDate ?? (startDate != null ? startDate!.add(Duration(days: 1)) : DateTime.now().add(Duration(days: 1))));
//
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: initialDate,
//       firstDate: isStartDate ? DateTime.now() : (startDate ?? DateTime.now()),
//       lastDate: DateTime.now().add(Duration(days: 365)),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(
//               primary: Colors.blue,
//               onPrimary: Colors.white,
//               onSurface: Colors.black,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//
//     if (picked != null) {
//       setState(() {
//         if (isStartDate) {
//           startDate = picked;
//           // If end date is before the new start date, reset end date
//           if (endDate != null && endDate!.isBefore(picked)) {
//             endDate = null;
//           }
//         } else {
//           endDate = picked;
//         }
//       });
//     }
//   }
//
//   Widget _buildBudgetField() {
//     return GestureDetector(
//       onTap: _showBudgetDialog,
//       child: Container(
//         padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey[300]!),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Row(
//           children: [
//             Icon(Icons.account_balance_wallet_outlined, color: Colors.grey[400]),
//             SizedBox(width: 8),
//             Text(
//               budgetRange,
//               style: TextStyle(color: Colors.black87),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showBudgetDialog() {
//     final List<String> budgetOptions = [
//       'Under \$500',
//       '\$500 - \$1000',
//       '\$1000 - \$2000',
//       '\$2000 - \$5000',
//       'Over \$5000',
//     ];
//
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Select Budget Range'),
//         content: SizedBox(
//           width: double.maxFinite,
//           child: ListView.builder(
//             shrinkWrap: true,
//             itemCount: budgetOptions.length,
//             itemBuilder: (context, index) {
//               return ListTile(
//                 title: Text(budgetOptions[index]),
//                 onTap: () {
//                   setState(() {
//                     budgetRange = budgetOptions[index];
//                   });
//                   Navigator.pop(context);
//                 },
//               );
//             },
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Cancel'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildActivitiesGrid() {
//     return GridView.builder(
//       shrinkWrap: true,
//       physics: NeverScrollableScrollPhysics(),
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         crossAxisSpacing: 10,
//         mainAxisSpacing: 10,
//         childAspectRatio: 1.25,
//       ),
//       itemCount: selectedActivities.length,
//       itemBuilder: (context, index) {
//         final activity = selectedActivities.keys.elementAt(index);
//         final isSelected = selectedActivities[activity]!;
//
//         return GestureDetector(
//           onTap: () {
//             setState(() {
//               selectedActivities[activity] = !isSelected;
//             });
//           },
//           child: Container(
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey[300]!),
//               borderRadius: BorderRadius.circular(8),
//               color: isSelected ? Colors.blue[50] : Colors.white,
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   activityIcons[activity],
//                   color: isSelected ? Colors.blue : Colors.blue[300],
//                   size: 28,
//                 ),
//                 SizedBox(height: 8),
//                 Text(
//                   activity,
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.black87,
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildCreateGroupButton() {
//     return SizedBox(
//       width: double.infinity,
//       height: 50,
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.blue,
//           foregroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//           elevation: 0,
//         ),
//         onPressed: () {
//           // Show confirmation
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Group created successfully!')),
//           );
//
//           // Navigate back or to next screen
//           // Navigator.pop(context);
//         },
//         child: Text(
//           'Create Group',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tripmate/services/travelgroups_service.dart';

class CreateNewGroupScreen extends StatefulWidget {
  const CreateNewGroupScreen({super.key});

  @override
  State<CreateNewGroupScreen> createState() => _CreateNewGroupScreenState();
}

class _CreateNewGroupScreenState extends State<CreateNewGroupScreen> {
  // Add service instance
  final TravelGroupsService _groupsService = TravelGroupsService();

  // Form controllers
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _groupNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Loading state
  bool _isLoading = false;

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

  // Max members
  int maxMembers = 8;

  // Privacy setting
  bool isPrivate = false;

  @override
  void dispose() {
    _destinationController.dispose();
    _groupNameController.dispose();
    super.dispose();
  }

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
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey[300],
            height: 1,
          ),
        ),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Group name field
                  _buildSectionTitle('What\'s your group name?'),
                  _buildGroupNameField(),
                  const SizedBox(height: 24),

                  // Destination field
                  _buildSectionTitle('Where are you going?'),
                  _buildDestinationField(),
                  const SizedBox(height: 24),

                  // Travel dates
                  _buildSectionTitle('When are you traveling?'),
                  _buildDateSelectionRow(),
                  const SizedBox(height: 24),

                  // Max members
                  _buildSectionTitle('Maximum group size'),
                  _buildMaxMembersField(),
                  const SizedBox(height: 24),

                  // Budget range
                  _buildSectionTitle('What\'s your budget range?'),
                  _buildBudgetField(),
                  const SizedBox(height: 24),

                  // Activities
                  _buildSectionTitle('What activities interest you?'),
                  _buildActivitiesGrid(),
                  const SizedBox(height: 24),

                  // Privacy setting
                  _buildPrivacyToggle(),
                  const SizedBox(height: 32),

                  // Create group button
                  _buildCreateGroupButton(),
                  const SizedBox(height: 20), // Bottom padding
                ],
              ),
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildGroupNameField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: _groupNameController,
        textCapitalization: TextCapitalization.words,
        maxLength: 50, // Add character limit
        decoration: InputDecoration(
          hintText: 'Enter group name (e.g., Adventure Seekers)',
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.group_outlined, color: Colors.grey[400]),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          counterText: '', // Hide character counter
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter a group name';
          }
          if (value.trim().length < 3) {
            return 'Group name must be at least 3 characters';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDestinationField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: _destinationController,
        textCapitalization: TextCapitalization.words,
        maxLength: 100, // Add character limit
        decoration: InputDecoration(
          hintText: 'Enter destination (e.g., Paris, France)',
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.location_on_outlined, color: Colors.grey[400]),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          counterText: '', // Hide character counter
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter a destination';
          }
          if (value.trim().length < 2) {
            return 'Destination must be at least 2 characters';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildMaxMembersField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            Icon(Icons.people_outline, color: Colors.grey[400]),
            const SizedBox(width: 8),
            const Text('Max members: '),
            Expanded(
              child: Slider(
                value: maxMembers.toDouble(),
                min: 2,
                max: 20,
                divisions: 18,
                label: maxMembers.toString(),
                activeColor: Colors.blue,
                onChanged: (value) {
                  setState(() {
                    maxMembers = value.round();
                  });
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '$maxMembers',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelectionRow() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _selectDate(true),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: startDate == null ? Colors.grey[300]! : Colors.blue[200]!,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: startDate == null ? Colors.white : Colors.blue[50],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: startDate == null ? Colors.grey[400] : Colors.blue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        startDate == null
                            ? 'Start date'
                            : DateFormat('MMM d, yyyy').format(startDate!),
                        style: TextStyle(
                          color: startDate == null ? Colors.grey[400] : Colors.black,
                          fontWeight: startDate == null ? FontWeight.normal : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => _selectDate(false),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: endDate == null ? Colors.grey[300]! : Colors.blue[200]!,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: endDate == null ? Colors.white : Colors.blue[50],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: endDate == null ? Colors.grey[400] : Colors.blue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        endDate == null
                            ? 'End date'
                            : DateFormat('MMM d, yyyy').format(endDate!),
                        style: TextStyle(
                          color: endDate == null ? Colors.grey[400] : Colors.black,
                          fontWeight: endDate == null ? FontWeight.normal : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        // Date validation message
        if (startDate != null && endDate != null && endDate!.isBefore(startDate!))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red[600], size: 16),
                const SizedBox(width: 4),
                Text(
                  'End date must be after start date',
                  style: TextStyle(
                    color: Colors.red[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _selectDate(bool isStartDate) async {
    final now = DateTime.now();
    final initialDate = isStartDate
        ? (startDate ?? now)
        : (endDate ?? (startDate?.add(const Duration(days: 1)) ?? now.add(const Duration(days: 1))));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: isStartDate ? now : (startDate ?? now),
      lastDate: now.add(const Duration(days: 365 * 2)), // Allow 2 years ahead
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
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
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.account_balance_wallet_outlined, color: Colors.grey[400]),
            const SizedBox(width: 8),
            Text(
              budgetRange,
              style: const TextStyle(color: Colors.black87),
            ),
            const Spacer(),
            Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
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
        title: const Text('Select Budget Range'),
        contentPadding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: budgetOptions.length,
            itemBuilder: (context, index) {
              final option = budgetOptions[index];
              final isSelected = budgetRange == option;

              return ListTile(
                title: Text(option),
                trailing: isSelected
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                selected: isSelected,
                onTap: () {
                  setState(() {
                    budgetRange = option;
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
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesGrid() {
    final selectedCount = selectedActivities.values.where((selected) => selected).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Activity counter
        if (selectedCount > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              '$selectedCount ${selectedCount == 1 ? 'activity' : 'activities'} selected',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
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
                    const SizedBox(height: 8),
                    Text(
                      activity,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        // Activity validation message
        if (selectedCount == 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange[600], size: 16),
                const SizedBox(width: 4),
                Text(
                  'Select at least one activity to help others find your group',
                  style: TextStyle(
                    color: Colors.orange[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPrivacyToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Private Group',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              Text(
                isPrivate
                    ? 'Only invited members can join'
                    : 'Anyone can discover and join',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          Switch(
            value: isPrivate,
            onChanged: (value) {
              setState(() {
                isPrivate = value;
              });
            },
            activeColor: Colors.blue,
          ),
        ],
      ),
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
          disabledBackgroundColor: Colors.grey[300],
        ),
        onPressed: _isLoading ? null : _createGroup,
        child: _isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : const Text(
          'Create Group',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  bool _validateForm() {
    bool isValid = true;
    String errorMessage = '';

    // Validate form fields
    if (!_formKey.currentState!.validate()) {
      isValid = false;
    }

    // Validate dates
    if (startDate == null) {
      errorMessage = 'Please select a start date';
      isValid = false;
    } else if (endDate == null) {
      errorMessage = 'Please select an end date';
      isValid = false;
    } else if (endDate!.isBefore(startDate!)) {
      errorMessage = 'End date must be after start date';
      isValid = false;
    } else if (startDate!.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      errorMessage = 'Start date cannot be in the past';
      isValid = false;
    }

    // Validate activities
    if (!selectedActivities.values.any((selected) => selected)) {
      errorMessage = 'Please select at least one activity';
      isValid = false;
    }

    if (!isValid && errorMessage.isNotEmpty) {
      _showErrorSnackBar(errorMessage);
    }

    return isValid;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showSuccessSnackBar(String groupName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text('Group "$groupName" created successfully!')),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _createGroup() async {
    // Validate form
    if (!_validateForm()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get selected activities
      final List<String> activities = selectedActivities.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      // Parse budget range using the service
      final budgetValues = _groupsService.parseBudgetRange(budgetRange);

      // Create the group using the service
      final result = await _groupsService.createTravelGroup(
        groupName: _groupNameController.text.trim(),
        destination: _destinationController.text.trim(),
        startDate: startDate!,
        endDate: endDate!,
        budgetMin: budgetValues['min']!,
        budgetMax: budgetValues['max']!,
        maxMembers: maxMembers,
        selectedActivities: activities,
        isPrivate: isPrivate,
      );

      if (result != null) {
        // Show success message
        _showSuccessSnackBar(_groupNameController.text.trim());

        // Navigate back with success indication
        Navigator.pop(context, true);
      } else {
        throw Exception('Failed to create group - no response from server');
      }

    } catch (error) {
      // Show error message with better formatting
      String errorMessage = error.toString().replaceAll('Exception: ', '');
      if (errorMessage.toLowerCase().contains('network') ||
          errorMessage.toLowerCase().contains('connection')) {
        errorMessage = 'Network error. Please check your connection and try again.';
      } else if (errorMessage.toLowerCase().contains('unauthorized')) {
        errorMessage = 'Please log in again to create a group.';
      }

      _showErrorSnackBar(errorMessage);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}