import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyBookingsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> bookings;

  const MyBookingsScreen({super.key, required this.bookings});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          // Same horizontal padding as in ExploreScreen
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Same vertical spacing as ExploreScreen
              SizedBox(height: screenHeight * 0.02),

              // Title styled similarly to ExploreScreen
              Text(
                "My Bookings",
                style: TextStyle(
                  fontSize: isTablet ? 28 : 24, // Similar to Explore
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Same vertical spacing as ExploreScreen
              SizedBox(height: screenHeight * 0.02),

              // Expanded List
              Expanded(
                child: ListView.builder(
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    final DateTime travelDate = booking['date'] as DateTime;
                    final String formattedDate = DateFormat.yMMMEd().format(travelDate);
                    final String status = booking['status'] as String;
                    final dynamic price = booking['price'];
                    final Color statusColor = (status.toLowerCase() == 'confirmed')
                        ? Colors.green
                        : Colors.orange;

                    return Container(
                      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 4,
                            color: Colors.black12,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Booking Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              booking['imageUrl'],
                              width: double.infinity,
                              height: screenHeight * 0.2,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: screenHeight * 0.2,
                                  color: Colors.grey[300],
                                  child: const Center(child: CircularProgressIndicator()),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: screenHeight * 0.2,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Title & Status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  booking['title'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Travel Date
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 5),
                              Text(
                                formattedDate,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Price
                          Text(
                            "₹$price",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // View Details Button
                          Align(
                            alignment: Alignment.centerRight,
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text("View Details"),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
