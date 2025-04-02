import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Make sure this import points to the correct file containing MyBookingsScreen
import 'package:tripmate/screens/bookings_screen.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final String bookingReference;
  final String packageName;
  final DateTime travelDate;

  const BookingConfirmationScreen({
    super.key,
    required this.bookingReference,
    required this.packageName,
    required this.travelDate,
  });

  @override
  Widget build(BuildContext context) {
    // Format the travel date
    final String formattedDate = DateFormat('MMMM dd, yyyy').format(travelDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Confirmation'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            const Text(
              "Booking Confirmed!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Your trip has been successfully booked",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            // Booking Details Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildDetailRow("Booking Reference", bookingReference),
                  _buildDetailRow("Package", packageName),
                  _buildDetailRow("Travel Date", formattedDate),
                ],
              ),
            ),
            const Spacer(),
            // View My Bookings Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MyBookingsScreen(
                        bookings: [
                          {
                            'title': 'Bali Paradise Tour',
                            'imageUrl':
                            'https://images.pexels.com/photos/31182223/pexels-photo-31182223/free-photo-of-bustling-tokyo-street-with-neon-signage.jpeg?auto=compress&cs=tinysrgb&w=600',
                            'date': DateTime(2024, 3, 15),
                            'status': 'Confirmed',
                            'price': 1499,
                          },
                          {
                            'title': 'Swiss Alps Adventure',
                            'imageUrl':
                            'https://images.pexels.com/photos/31161077/pexels-photo-31161077/free-photo-of-sunset-over-alicante-coastline.jpeg?auto=compress&cs=tinysrgb&w=600',
                            'date': DateTime(2024, 4, 20),
                            'status': 'Pending',
                            'price': 1799,
                          },
                        ],
                      ),
                    ),
                  );
                },
                child: const Text("View My Bookings"),
              ),
            ),
            const SizedBox(height: 10),
            // Share Itinerary Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Implement itinerary sharing
                },
                child: const Text("Share Itinerary"),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
