import 'package:flutter/material.dart';
import 'package:tripmate/routes/on_generate_route.dart';
import 'package:tripmate/services/travelpackages_service.dart';

class PackageDetailsScreen extends StatefulWidget {
  final String packageId;

  const PackageDetailsScreen({
    super.key,
    required this.packageId,
  });

  @override
  State<PackageDetailsScreen> createState() => _PackageDetailsScreenState();
}

class _PackageDetailsScreenState extends State<PackageDetailsScreen>
    with TickerProviderStateMixin {
  final TravelPackagesService _packageService = TravelPackagesService();
  Map<String, dynamic>? package;
  bool isLoading = true;
  String? error;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: const Offset(0, 0),
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _loadPackageDetails();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading package details',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadPackageDetails,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : package == null
          ? const Center(child: Text('No package data available'))
          : FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildHeaderImage(),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.3),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAnimatedTitle(isTablet),
                        const SizedBox(height: 16),
                        _buildRatingSection(),
                        const SizedBox(height: 24),
                        _buildOverviewSection(),
                        const SizedBox(height: 32),
                        _buildItinerarySection(),
                        const SizedBox(height: 32),
                        _buildPriceSection(context),
                        const SizedBox(height: 20),
                      ],
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

  Future<void> _loadPackageDetails() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final packageData = await _packageService.getPackageDetails(
          widget.packageId);

      setState(() {
        package = packageData;
        isLoading = false;
      });

      // Start animations after data is loaded
      _fadeController.forward();
      _slideController.forward();
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Widget _buildHeaderImage() {
    final imageUrl = _getImageUrl();

    if (_isValidImageUrl(imageUrl)) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[300],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('Image loading error: $error'); // Debug log
          return _buildDefaultImage();
        },
      );
    } else {
      return _buildDefaultImage();
    }
  }

  Widget _buildDefaultImage() {
    final defaultImageUrl = _getDefaultImageUrl();

    return Image.network(
      defaultImageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey[300],
          child: const Center(child: CircularProgressIndicator()),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        // Final fallback - use a colored container with icon
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue[400]!,
                Colors.blue[600]!,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getDefaultIcon(),
                  size: 80,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                const SizedBox(height: 16),
                Text(
                  package!['title'] ?? 'Travel Package',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getDefaultIcon() {
    final destination = package!['destination']?.toString().toLowerCase() ?? '';
    final tags = package!['tags']?.toString().toLowerCase() ?? '';

    if (destination.contains('hill') || tags.contains('trekking') || tags.contains('adventure')) {
      return Icons.landscape;
    } else if (destination.contains('beach') || tags.contains('beach')) {
      return Icons.beach_access;
    } else if (tags.contains('cultural') || tags.contains('heritage')) {
      return Icons.account_balance;
    } else if (tags.contains('family') || tags.contains('leisure')) {
      return Icons.family_restroom;
    } else {
      return Icons.flight_takeoff;
    }
  }

  bool _isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;

    // Check if it's a valid URL format
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  String _getImageUrl() {
    // Check for the 'images' column first (your Supabase column)
    final imageData = package!['images'];

    if (imageData != null) {
      String imageString = imageData.toString().trim();

      if (imageString.isNotEmpty) {
        // Handle JSON array format like ["url1", "url2", "url3"]
        if (imageString.startsWith('[') && imageString.endsWith(']')) {
          try {
            // Remove brackets and quotes, split by comma
            String cleanString = imageString.substring(1, imageString.length - 1);
            List<String> urls = cleanString.split(',');

            if (urls.isNotEmpty) {
              String firstUrl = urls[0].trim().replaceAll('"', '');
              if (firstUrl.isNotEmpty) {
                return _validateImageUrl(firstUrl);
              }
            }
          } catch (e) {
            print('Error parsing image array: $e');
          }
        }
        // Handle comma-separated URLs
        else if (imageString.contains(',')) {
          List<String> urls = imageString.split(',');
          String firstUrl = urls[0].trim();
          if (firstUrl.isNotEmpty) {
            return _validateImageUrl(firstUrl);
          }
        }
        // Handle single URL
        else {
          return _validateImageUrl(imageString);
        }
      }
    }

    // Fallback: check other possible column names
    final fallbackImageUrl = package!['image_urls'] ??
        package!['image'] ??
        package!['banner_image'] ??
        package!['photo'] ??
        package!['picture'];

    if (fallbackImageUrl != null) {
      String urlString = fallbackImageUrl.toString().trim();
      if (urlString.isNotEmpty) {
        return _validateImageUrl(urlString);
      }
    }

    return '';
  }

  String _validateImageUrl(String url) {
    if (url.isEmpty) return url;

    // Remove any extra quotes that might be present
    url = url.replaceAll('"', '').replaceAll("'", '').trim();

    // Check if it's a valid URL format
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    } else if (url.startsWith('//')) {
      return 'https:$url';
    } else if (url.startsWith('/')) {
      // If you have a base URL for your API, replace this with your actual base URL
      return 'https://your-api-base-url.com$url';
    }

    // If it doesn't start with http/https, assume it might need https://
    if (!url.contains('://')) {
      return 'https://$url';
    }

    return url;
  }

  String _getDefaultImageUrl() {
    final destination = package!['destination']?.toString().toLowerCase() ?? '';
    final tags = package!['tags']?.toString().toLowerCase() ?? '';

    // Return appropriate default image based on destination or tags
    if (destination.contains('hill') || tags.contains('trekking') || tags.contains('adventure')) {
      return 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80';
    } else if (destination.contains('beach') || tags.contains('beach')) {
      return 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80';
    } else if (tags.contains('cultural') || tags.contains('heritage')) {
      return 'https://images.unsplash.com/photo-1539650116574-75c0c6d73f6b?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80';
    } else if (tags.contains('family') || tags.contains('leisure')) {
      return 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80';
    } else if (destination.contains('temple') || destination.contains('pilgrimage') || tags.contains('religious')) {
      return 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80';
    } else {
      return 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80';
    }
  }

  Widget _buildAnimatedTitle(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          package!['title'] ?? 'No Title',
          style: TextStyle(
            fontSize: isTablet ? 32 : 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        if (package!['destination'] != null)
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: Colors.grey[600],
                size: 18,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  package!['destination'],
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildRatingSection() {
    // Mock rating data - replace with actual data from your package
    final rating = package!['rating']?.toDouble() ?? 4.8;
    final reviewCount = package!['review_count'] ?? 128;

    return Row(
      children: [
        Icon(
          Icons.star,
          color: Colors.amber[600],
          size: 20,
        ),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '($reviewCount reviews)',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          package!['description'] ?? 'Experience an amazing journey with carefully curated activities and destinations.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildItinerarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Itinerary',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildItinerary(),
      ],
    );
  }

  Widget _buildItinerary() {
    List<Map<String, String>> itineraryItems = _parseItinerary();

    return Column(
      children: itineraryItems.asMap().entries.map((entry) {
        int index = entry.key;
        Map<String, String> item = entry.value;
        bool isLast = index == itineraryItems.length - 1;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day indicator with line
              Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.blue[600],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 50,
                      color: Colors.grey[300],
                      margin: const EdgeInsets.only(top: 8, bottom: 8),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      if (item['description']?.isNotEmpty == true) ...[
                        const SizedBox(height: 8),
                        Text(
                          item['description'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<Map<String, String>> _parseItinerary() {
    final itinerary = package!['itinerary']?.toString() ?? '';
    final duration = package!['duration_days'] ?? 7;

    List<Map<String, String>> items = [];

    if (itinerary.isNotEmpty) {
      try {
        // Handle the format: [{day: Day 1, desc: Arrive and rest}, {day: Day 2, desc: Visit local attractions}]
        if (itinerary.contains('{day:')) {
          // Parse the specific format from your data
          RegExp dayRegex = RegExp(r'\{day:\s*([^,]+),\s*desc:\s*([^}]+)\}');
          Iterable<RegExpMatch> matches = dayRegex.allMatches(itinerary);

          for (RegExpMatch match in matches) {
            String day = match.group(1)?.trim() ?? '';
            String description = match.group(2)?.trim() ?? '';

            items.add({
              'title': day,
              'description': description,
            });
          }
        }
        // Handle other formats if needed
        else if (itinerary.contains('Day')) {
          List<String> lines = itinerary.split('\n').where((line) => line.trim().isNotEmpty).toList();

          for (int i = 0; i < lines.length; i++) {
            String line = lines[i].trim();
            if (line.toLowerCase().contains('day')) {
              items.add({
                'title': line,
                'description': i + 1 < lines.length ? lines[i + 1].trim() : '',
              });
            }
          }
        }
      } catch (e) {
        print('Error parsing itinerary: $e');
      }
    }

    // If no structured itinerary found, create default based on package type
    if (items.isEmpty) {
      items = _generateDefaultItinerary(duration);
    }

    return items;
  }

  List<Map<String, String>> _generateDefaultItinerary(int duration) {
    final destination = package!['destination']?.toString().toLowerCase() ?? '';
    final tags = package!['tags']?.toString().toLowerCase() ?? '';

    List<Map<String, String>> defaultItinerary = [];

    // Generate based on destination and duration
    if (destination.contains('bali') || tags.contains('beach')) {
      defaultItinerary = [
        {'title': 'Day 1: Arrival & Welcome Dinner', 'description': 'Airport pickup and check-in to hotel'},
        {'title': 'Day 2: Ubud Temple Tour', 'description': 'Visit ancient temples and local markets'},
        {'title': 'Day 3: Rice Terraces & Coffee Plantation', 'description': 'Explore stunning landscapes'},
        {'title': 'Day 4: Beach Day at Nusa Dua', 'description': 'Relax at pristine beaches'},
        {'title': 'Day 5: Mount Batur Sunrise Trek', 'description': 'Early morning adventure trek'},
        {'title': 'Day 6: Spa Day & Cultural Show', 'description': 'Wellness and entertainment'},
        {'title': 'Day 7: Departure', 'description': 'Check-out and airport transfer'},
      ];
    } else {
      // Generic itinerary
      for (int i = 1; i <= duration; i++) {
        if (i == 1) {
          defaultItinerary.add({
            'title': 'Day 1: Arrival & Welcome',
            'description': 'Airport pickup and hotel check-in'
          });
        } else if (i == duration) {
          defaultItinerary.add({
            'title': 'Day $i: Departure',
            'description': 'Check-out and airport transfer'
          });
        } else {
          defaultItinerary.add({
            'title': 'Day $i: Exploration',
            'description': 'Guided tours and activities'
          });
        }
      }
    }

    return defaultItinerary.take(duration).toList();
  }

  Widget _buildPriceSection(BuildContext context) {
    final basePrice = package!['price_per_person']?.toDouble() ?? 0;
    final taxesAndFees = (basePrice * 0.15).round(); // Assuming 15% taxes and fees
    final totalPrice = (basePrice + taxesAndFees).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Price Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildPriceRow('Base Price', '₹${basePrice.toStringAsFixed(0)}'),
              const SizedBox(height: 12),
              _buildPriceRow('Taxes & Fees', '₹$taxesAndFees'),
              const SizedBox(height: 16),
              Container(
                height: 1,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              _buildPriceRow(
                'Total',
                '₹$totalPrice',
                isTotal: true,
                color: Colors.blue[600]!,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.bookingDetails,
                      arguments: {
                        'package': package,
                        'packageId': widget.packageId,
                        'basePrice': basePrice,
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Book Now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String amount, {bool isTotal = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: color ?? Colors.black87,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}