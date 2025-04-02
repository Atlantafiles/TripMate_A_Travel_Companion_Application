import 'package:flutter/material.dart';

class RateExperienceScreen extends StatefulWidget {
  const RateExperienceScreen ({super.key});
  @override
  State<RateExperienceScreen> createState() => _RateExperienceScreenState();
}

class _RateExperienceScreenState extends State<RateExperienceScreen> {
  int _rating = 5; // Default 5 stars
  final TextEditingController _reviewController = TextEditingController();
  int _characterCount = 0;
  final int _maxCharacters = 500;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Rate Your Experience',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 20),

              // Trip information with avatar
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.grey[400],
                      backgroundImage: AssetImage('assets/avatar.jpg'), // Replace with your asset or use NetworkImage
                      // If you don't have the image, use a placeholder:
                      child: Icon(Icons.person, size: 30, color: Colors.white),
                    ),
                    SizedBox(width: 12),
                    // Trip details
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trip with Alex Morgan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Dec 15, 2023',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Rating label
              Text(
                'Rate your experience',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),

              SizedBox(height: 12),

              // Star rating
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                    child: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: index < _rating ? Colors.amber : Colors.grey,
                      size: 40,
                    ),
                  );
                }),
              ),

              SizedBox(height: 24),

              // Review text field
              Expanded(
                child: TextField(
                  controller: _reviewController,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'Write your review here...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    contentPadding: EdgeInsets.all(16),
                  ),
                  onChanged: (text) {
                    setState(() {
                      _characterCount = text.length;
                    });
                  },
                ),
              ),

              SizedBox(height: 16),

              // Add photos button and character count
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Add photos button
                  TextButton.icon(
                    onPressed: () {
                      // Implement photo upload functionality
                    },
                    icon: Icon(Icons.add_photo_alternate, color: Colors.blue),
                    label: Text(
                      'Add Photos',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 0),
                    ),
                  ),

                  // Character count
                  Text(
                    '$_characterCount/$_maxCharacters',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    // Implement submit functionality
                  },
                  child: Text(
                    'Submit Review',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}