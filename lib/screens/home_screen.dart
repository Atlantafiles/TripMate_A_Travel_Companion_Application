import 'package:flutter/material.dart';
import 'package:tripmate/screens/profile_screen.dart';

void main() {
  runApp(const TripMateApp());
}

class TripMateApp extends StatelessWidget {
  const TripMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Icon(Icons.location_on, color: Colors.black),
        title: Text("New York", style: TextStyle(color: Colors.black)),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen(userProfile: sampleProfile,)),
              );
            },
            child: const CircleAvatar(
              backgroundImage: NetworkImage(
                  "https://images.pexels.com/photos/943084/pexels-photo-943084.jpeg?auto=compress&cs=tinysrgb&w=800"),
            ),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SearchBar(),
              SizedBox(height: 20),
              SectionTitle("Featured Groups"),
              FeaturedGroups(),
              SizedBox(height: 20),
              SectionTitle("Recommended for You"),
              RecommendedForYou(),
              SizedBox(height: 20),
              SectionTitle("Popular Destinations"),
              PopularDestinations(),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  const SearchBar({super.key});
  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: "Where do you want to go?",
        prefixIcon: Icon(Icons.search, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}

class FeaturedGroups extends StatelessWidget {

  final List<Map<String, String>> groups = [
    {
      "title": "Mountain Explorers",
      "location": "Swiss Alps",
      "image":
      "https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0",
      "rating": "4.8",
      "members": "24"
    },
    {
      "title": "Beach Lovers",
      "location": "Maldives",
      "image":
      "https://images.unsplash.com/photo-1507525428034-b723cf961d3e",
      "rating": "4.7",
      "members": "18"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: groups
          .map((group) => Expanded(
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(10)),
                child: Image.network(group["image"]!, height: 100, width: double.infinity, fit: BoxFit.cover),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(group["title"]!, style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(group["location"]!, style: TextStyle(color: Colors.grey)),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(group["rating"]!)
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ))
          .toList(),
    );
  }
}

class RecommendedForYou extends StatelessWidget {
  const RecommendedForYou({super.key});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            child: Image.network(
              "https://images.unsplash.com/photo-1502602898657-3e91760cbb34",
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Paris Explorer", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("7 days", style: TextStyle(color: Colors.grey)),
                Row(
                  children: [
                    Text("\₹1,299", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                    Spacer(),
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    Text("4.9")
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class PopularDestinations extends StatelessWidget {
  final List<Map<String, String>> destinations = [
    {
      "city": "Rome",
      "country": "Italy",
      "trips": "248",
      "image": "https://images.pexels.com/photos/2827374/pexels-photo-2827374.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2"
    },
    {
      "city": "Bangkok",
      "country": "Thailand",
      "trips": "186",
      "image": "https://images.pexels.com/photos/2678418/pexels-photo-2678418.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2"
    },
    {
      "city": "Barcelona",
      "country": "Spain",
      "trips": "167",
      "image": "https://images.pexels.com/photos/31140605/pexels-photo-31140605/free-photo-of-stunning-wooden-church-in-karelia-russia.jpeg?auto=compress&cs=tinysrgb&w=800"
    },
    {
      "city": "Amsterdam",
      "country": "Netherlands",
      "trips": "159",
      "image": "https://images.pexels.com/photos/31160557/pexels-photo-31160557/free-photo-of-golden-pavilion-reflected-in-tranquil-pond-kyoto.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: destinations.length,
      itemBuilder: (context, index) {
        final destination = destinations[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(destination["image"]!, width: double.infinity, height: double.infinity, fit: BoxFit.cover),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(destination["city"]!, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(destination["country"]!, style: TextStyle(color: Colors.white)),
                    Text("${destination["trips"]} trips", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
