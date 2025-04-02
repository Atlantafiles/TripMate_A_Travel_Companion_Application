import 'package:flutter/material.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  int selectedCategory = 0;
  final List<String> categories = ["All", "Beach", "Mountain", "City", "Cultural"];

  final List<Map<String, String>> packages = [
    {
      'title': 'Bali Paradise Tour',
      'location': 'Bali, Indonesia',
      'image': 'https://images.pexels.com/photos/31182223/pexels-photo-31182223/free-photo-of-bustling-tokyo-street-with-neon-signage.jpeg?auto=compress&cs=tinysrgb&w=600',
      'price': '\₹1,299',
      'rating': '4.8',
      'duration': '7 Days',
    },
    {
      'title': 'Swiss Alps Adventure',
      'location': 'Switzerland',
      'image': 'https://images.pexels.com/photos/31161077/pexels-photo-31161077/free-photo-of-sunset-over-alicante-coastline.jpeg?auto=compress&cs=tinysrgb&w=600',
      'price': '\₹1,599',
      'rating': '4.9',
      'duration': '5 Days',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.02),

              // **Title**
              Text(
                "Explore Packages",
                style: TextStyle(fontSize: isTablet ? 28 : 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: screenHeight * 0.02),

              // **Search Bar**
              TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  hintText: "Search destinations",
                  hintStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              // **Category Filters**
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(categories.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(
                          categories[index],
                          style: TextStyle(
                            color: selectedCategory == index ? Colors.white : Colors.black,
                          ),
                        ),
                        selected: selectedCategory == index,
                        selectedColor: Colors.blue,
                        backgroundColor: Colors.grey[200],
                        onSelected: (bool selected) {
                          setState(() {
                            selectedCategory = index;
                          });
                        },
                      ),
                    );
                  }),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              // **Featured Packages**
              Text(
                "Featured Packages",
                style: TextStyle(fontSize: isTablet ? 22 : 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: screenHeight * 0.02),

              // **Package List**
              Expanded(
                child: ListView.builder(
                  itemCount: packages.length,
                  itemBuilder: (context, index) {
                    final package = packages[index];
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // **Image**
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                            child: Image.network(
                              package['image']!,
                              height: isTablet ? 250 : 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.all(screenWidth * 0.04),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // **Title**
                                Text(
                                  package['title']!,
                                  style: TextStyle(
                                      fontSize: isTablet ? 20 : 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 5),

                                // **Location**
                                Row(
                                  children: [
                                    Icon(Icons.location_on, size: 16, color: Colors.grey),
                                    SizedBox(width: 5),
                                    Text(package['location']!,
                                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                                  ],
                                ),
                                SizedBox(height: 8),

                                // **Duration & Rating**
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.access_time, size: 16, color: Colors.grey),
                                        SizedBox(width: 5),
                                        Text(package['duration']!,
                                            style: TextStyle(fontSize: 14, color: Colors.grey)),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.star, color: Colors.orange, size: 18),
                                        SizedBox(width: 5),
                                        Text(package['rating']!,
                                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),

                                // **Price & Button**
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      package['price']!,
                                      style: TextStyle(
                                          fontSize: isTablet ? 22 : 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue),
                                    ),
                                    ElevatedButton(
                                      onPressed: ()
                                          { Navigator.pushNamed(context, '/view_details');
                                            },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10))),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: isTablet ? 16 : 10, vertical: 8),
                                        child: Text(
                                          'View Details',
                                          style: TextStyle(color: Colors.white, fontSize: isTablet ? 16 : 14),
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
