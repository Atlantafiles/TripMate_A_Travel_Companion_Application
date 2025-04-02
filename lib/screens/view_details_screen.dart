import 'package:flutter/material.dart';
import 'package:tripmate/routes/on_generate_route.dart';

class PackageDetailsScreen extends StatelessWidget {
  PackageDetailsScreen({super.key});

  final Map<String, dynamic> package = {
    'title': 'Bali Paradise Tour',
    'image': 'https://images.pexels.com/photos/31182223/pexels-photo-31182223/free-photo-of-bustling-tokyo-street-with-neon-signage.jpeg?auto=compress&cs=tinysrgb&w=600',
    'rating': 4.8,
    'reviews': 128,
    'overview': 'Experience the beauty of Bali with our carefully curated 7-day tour package. Visit ancient temples, pristine beaches, and immerse yourself in the local culture.',
    'itinerary': [
      'Day 1: Arrival & Welcome Dinner',
      'Day 2: Ubud Temple Tour',
      'Day 3: Rice Terraces & Coffee Plantation',
      'Day 4: Beach Day at Nusa Dua',
      'Day 5: Mount Batur Sunrise Trek',
      'Day 6: Spa Day & Cultural Show',
      'Day 7: Departure',
    ],
    'basePrice': 1299,
    'taxes': 199,
  };

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isTablet = screenWidth > 600;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // **Banner Image with Back Button**
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                  child: Image.network(
                    package['image']!,
                    width: double.infinity,
                    height: screenHeight * 0.35,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.05,
                  left: 15,
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.7),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),

            // **Package Details**
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenHeight * 0.02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // **Title**
                  Text(
                    package['title']!,
                    style: TextStyle(fontSize: isTablet ? 26 : 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),

                  // **Rating & Reviews**
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.orange, size: 18),
                      SizedBox(width: 5),
                      Text(
                        "${package['rating']} ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text("(${package['reviews']} reviews)", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // **Overview**
                  Text("Overview", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  SizedBox(height: 5),
                  Text(package['overview']!, style: TextStyle(color: Colors.grey[700])),
                  SizedBox(height: screenHeight * 0.03),

                  // **Itinerary**
                  Text("Itinerary", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  SizedBox(height: 5),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: package['itinerary'].map<Widget>((item) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 6),
                              child: Icon(Icons.circle, size: 8, color: Colors.blue),
                            ),
                            SizedBox(width: 8),
                            Expanded(child: Text(item, style: TextStyle(fontSize: 16))),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: screenHeight * 0.03),

                  // **Price Details**
                  Text("Price Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        _buildPriceRow("Base Price", "₹${package['basePrice']}"),
                        _buildPriceRow("Taxes & Fees", "₹${package['taxes']}"),
                        _buildPriceRow(
                        "Total",
                        "₹${package['basePrice'] + package['taxes']}",
                        isTotal: true,
                        ),
                        SizedBox(height: 15), // Spacing before the button
                        SizedBox(
                          width: double.infinity, // Full-width button
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.bookingDetails,
                                arguments: {
                                  'basePrice': 1299,
                                  'taxes': 199,
                                  // Add any other package data needed
                                },
                              );

                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue, // Primary color
                              padding: EdgeInsets.symmetric(vertical: 14), // Button height
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8), // Rounded corners
                              ),
                            ),
                            child: Text(
                              "Book Now",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildPriceRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(
            amount,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: isTotal ? Colors.blue : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
