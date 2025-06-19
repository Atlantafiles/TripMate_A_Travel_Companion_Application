import 'package:flutter/material.dart';

class BookingManagementScreen extends StatefulWidget {
  const BookingManagementScreen({super.key});

  @override
  State<BookingManagementScreen> createState() =>
      _BookingManagementScreenState();
}

class _BookingManagementScreenState extends State<BookingManagementScreen> {
  final List<String> tripTypes = ['Beach Paradise', 'Mountain Trek', 'City Tour'];
  final Map<String, int> bookingCounts = {
    'Beach Paradise': 12,
    'Mountain Trek': 8,
    'City Tour': 5,
  };
  String selectedTrip = 'Beach Paradise';

  final List<Map<String, dynamic>> bookings = [
    {
      'id': 'BK001',
      'name': 'John Smith',
      'phone': '+1 234 567 890',
      'nid': '123456789',
      'date': '2024-02-15',
      'status': 'Pending'
    },
    {
      'id': 'BK002',
      'name': 'Emma Wilson',
      'phone': '+1 234 567 891',
      'nid': '987654321',
      'date': '2024-02-14',
      'status': 'Confirmed'
    },
    {
      'id': 'BK003',
      'name': 'Michael Brown',
      'phone': '+1 234 567 892',
      'nid': '456789123',
      'date': '2024-02-16',
      'status': 'Pending'
    }
  ];

  Color getStatusColor(String status) {
    return status == 'Confirmed' ? Colors.green : Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking Management"),
        leading: const BackButton(),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          _buildCategoryFilter(),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: bookings.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return _buildBookingCard(booking);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: tripTypes.length,
        itemBuilder: (context, index) {
          final trip = tripTypes[index];
          final isSelected = trip == selectedTrip;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(trip),
                  const SizedBox(width: 6),
                  CircleAvatar(
                    radius: 10,
                    backgroundColor:
                    isSelected ? Colors.white : Colors.grey.shade200,
                    child: Text(
                      "${bookingCounts[trip]}",
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.blue : Colors.black,
                      ),
                    ),
                  )
                ],
              ),
              selected: isSelected,
              selectedColor: Colors.blue.shade100,
              onSelected: (_) {
                setState(() => selectedTrip = trip);
              },
              backgroundColor: Colors.grey.shade200,
              labelStyle: TextStyle(
                  color: isSelected ? Colors.blue : Colors.black,
                  fontWeight: FontWeight.w500),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text("Booking ID: ${booking['id']}",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: getStatusColor(booking['status']).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    booking['status'],
                    style: TextStyle(
                      fontSize: 12,
                      color: getStatusColor(booking['status']),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.person_outline, size: 18),
              const SizedBox(width: 8),
              Text(booking['name']),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.phone_outlined, size: 18),
              const SizedBox(width: 8),
              Text(booking['phone']),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.credit_card, size: 18),
              const SizedBox(width: 8),
              Text("ID: ${booking['nid']}"),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.calendar_today_outlined, size: 18),
              const SizedBox(width: 8),
              Text(booking['date']),
            ]),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      setState(() {
                        booking['status'] = booking['status'] == 'Pending'
                            ? 'Confirmed'
                            : 'Pending';
                      });
                    },
                    child: const Text("Update Status"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                    label: const Text("Delete",
                        style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      setState(() {
                        bookings.remove(booking);
                      });
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
