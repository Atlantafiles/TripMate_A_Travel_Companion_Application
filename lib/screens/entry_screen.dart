import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:tripmate/screens/bookings_screen.dart';
import 'package:tripmate/screens/explore_screen.dart';
import 'package:tripmate/screens/groups_screen.dart';
import 'package:tripmate/screens/profile_screen.dart';



import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    JoinGroupsScreen(),
    ExploreScreen(),
    MyBookingsScreen(bookings: [
      {
        'title': 'Bali Paradise Tour',
        'imageUrl': 'https://images.pexels.com/photos/31160967/pexels-photo-31160967/free-photo-of-row-of-gondolas-at-sunrise-in-venice-italy.jpeg?auto=compress&cs=tinysrgb&w=600',
        'date': DateTime(2024, 3, 15),
        'status': 'Confirmed',
        'price': 1499,
      },
      {
        'title': 'Swiss Alps Adventure',
        'imageUrl': 'https://images.pexels.com/photos/31196465/pexels-photo-31196465/free-photo-of-busy-train-station-platform-with-passengers.jpeg?auto=compress&cs=tinysrgb&w=600',
        'date': DateTime(2024, 4, 20),
        'status': 'Pending',
        'price': 1799,
      },
    ]),
    ProfileScreen(userProfile: sampleProfile),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        color: Colors.blue,
        buttonBackgroundColor: Colors.white,
        height: 60,
        index: _currentIndex,
        animationDuration: Duration(milliseconds: 300),
        items: <Widget>[
          Icon(Icons.home, size: 30, color: Colors.black),
          Icon(Icons.group_add, size: 30, color: Colors.black),
          Icon(Icons.explore, size: 30, color: Colors.black),
          Icon(Icons.book, size: 30, color: Colors.black),
          Icon(Icons.person, size: 30, color: Colors.black),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      body: _pages[_currentIndex],
    );
  }
}
