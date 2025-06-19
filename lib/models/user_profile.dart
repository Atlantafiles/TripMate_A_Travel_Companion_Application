// Model for Trip
class Trip {
  final String name;
  final String dates;
  final double rating;
  final String imageUrl;

  Trip({
    required this.name,
    required this.dates,
    required this.rating,
    required this.imageUrl,
  });
}

// Model for User Profile
class UserProfile {
  final String name;
  final String bio;
  final String location;
  final String joinDate;
  final String profileImageUrl;
  final List<Trip> pastTrips;
  final bool isVerified; // New property

  UserProfile({
    required this.name,
    required this.bio,
    required this.location,
    required this.joinDate,
    required this.profileImageUrl,
    required this.pastTrips,
    this.isVerified = false, // Default to false
  });
}

