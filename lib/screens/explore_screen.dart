import 'package:flutter/material.dart';
import 'package:tripmate/services/travelpackages_service.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> with TickerProviderStateMixin {
  int selectedCategory = 0;
  final List<String> categories = ["All", "Beach", "Mountain", "City", "Cultural"];
  final List<String> categoryTypes = ["all", "beach", "mountain", "city", "cultural"];

  final TravelPackagesService _packageService = TravelPackagesService();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> packages = [];
  List<Map<String, dynamic>> featuredPackages = [];
  bool isLoading = true;
  bool isSearching = false;
  String? errorMessage;

  // Pagination
  int currentPage = 1;
  final int packagesPerPage = 10;
  bool hasMorePackages = true;
  bool isLoadingMore = false;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadInitialData();
    _searchController.addListener(_onSearchChanged);
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadPackages(),
      _loadFeaturedPackages(),
    ]);
  }

  Future<void> _loadPackages({bool loadMore = false}) async {
    if (loadMore && !hasMorePackages) return;

    setState(() {
      if (loadMore) {
        isLoadingMore = true;
      } else {
        isLoading = true;
        currentPage = 1;
        errorMessage = null;
      }
    });

    try {
      final String? packageType = selectedCategory == 0 ? null : categoryTypes[selectedCategory];

      final newPackages = await _packageService.getTravelPackages(
        packageType: packageType,
        page: currentPage,
        limit: packagesPerPage,
        sortBy: 'created_at',
        sortOrder: 'desc',
      );

      setState(() {
        if (loadMore) {
          packages.addAll(newPackages);
          isLoadingMore = false;
        } else {
          packages = newPackages;
          isLoading = false;
        }

        hasMorePackages = newPackages.length == packagesPerPage;
        if (loadMore) currentPage++;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  Future<void> _loadFeaturedPackages() async {
    try {
      final featured = await _packageService.getFeaturedPackages(limit: 5);
      setState(() {
        featuredPackages = featured;
      });
    } catch (e) {
      print('Error loading featured packages: $e');
    }
  }

  void _onSearchChanged() {
    if (_searchController.text.isNotEmpty) {
      _performSearch(_searchController.text);
    } else {
      _loadPackages();
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      isSearching = true;
      errorMessage = null;
    });

    try {
      final searchResults = await _packageService.searchPackages(query.trim());
      setState(() {
        packages = searchResults;
        isSearching = false;
        hasMorePackages = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isSearching = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadInitialData();
  }

  void _loadMorePackages() {
    if (!isLoadingMore && hasMorePackages && _searchController.text.isEmpty) {
      currentPage++;
      _loadPackages(loadMore: true);
    }
  }

  String _formatPrice(dynamic price) {
    if (price is num) {
      return '₹${price.toStringAsFixed(0)}';
    }
    return '₹$price';
  }

  String _getImageUrl(Map<String, dynamic> package) {
    // Enhanced image URL handling with multiple fallbacks
    List<String> possibleImageKeys = [
      'image_urls',    // Array of images
      'images',        // Array of images
      'image_url',     // Single image URL
      'main_image',    // Main image
      'photo',         // Photo field
      'picture'        // Picture field
    ];

    for (String key in possibleImageKeys) {
      if (package.containsKey(key) && package[key] != null) {
        var imageData = package[key];

        // Handle array of images
        if (imageData is List && imageData.isNotEmpty) {
          for (var img in imageData) {
            if (img is String && img.isNotEmpty) {
              return _validateImageUrl(img);
            }
            if (img is Map && img.containsKey('url')) {
              return _validateImageUrl(img['url']);
            }
          }
        }

        // Handle single image URL
        if (imageData is String && imageData.isNotEmpty) {
          return _validateImageUrl(imageData);
        }
      }
    }

    // Category-specific fallback images
    String destination = (package['destination'] ?? '').toLowerCase();
    String packageType = (package['package_type'] ?? '').toLowerCase();

    if (destination.contains('bali') || destination.contains('beach')) {
      return 'https://images.pexels.com/photos/1032650/pexels-photo-1032650.jpeg?auto=compress&cs=tinysrgb&w=600';
    } else if (destination.contains('mountain') || packageType.contains('mountain')) {
      return 'https://images.pexels.com/photos/618833/pexels-photo-618833.jpeg?auto=compress&cs=tinysrgb&w=600';
    } else if (destination.contains('city') || packageType.contains('city')) {
      return 'https://images.pexels.com/photos/374870/pexels-photo-374870.jpeg?auto=compress&cs=tinysrgb&w=600';
    } else {
      return 'https://images.pexels.com/photos/1024993/pexels-photo-1024993.jpeg?auto=compress&cs=tinysrgb&w=600';
    }
  }

  String _validateImageUrl(String url) {
    // Ensure URL is properly formatted
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    } else if (url.startsWith('//')) {
      return 'https:$url';
    } else if (url.startsWith('/')) {
      // Relative URL - you might need to prepend your base URL
      return 'https://your-api-base-url.com$url';
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: Colors.blue,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight * 0.02),

                    // **Animated Title**
                    Hero(
                      tag: 'explore_title',
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          "Explore Packages",
                          style: TextStyle(
                            fontSize: isTablet ? 28 : 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // **Enhanced Search Bar**
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          prefixIcon: AnimatedSwitcher(
                            duration: Duration(milliseconds: 300),
                            child: isSearching
                                ? Padding(
                              key: ValueKey('loading'),
                              padding: const EdgeInsets.all(12.0),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                ),
                              ),
                            )
                                : Icon(
                                key: ValueKey('search'),
                                Icons.search,
                                color: Colors.grey[600]
                            ),
                          ),
                          hintText: "Search destinations, packages...",
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: AnimatedOpacity(
                            opacity: _searchController.text.isNotEmpty ? 1.0 : 0.0,
                            duration: Duration(milliseconds: 200),
                            child: IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey[600]),
                              onPressed: () => _searchController.clear(),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // **Category Filters**
                    if (_searchController.text.isEmpty) ...[
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(categories.length, (index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                child: ChoiceChip(
                                  label: Text(
                                    categories[index],
                                    style: TextStyle(
                                      color: selectedCategory == index ? Colors.white : Colors.grey[700],
                                      fontWeight: selectedCategory == index ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                  selected: selectedCategory == index,
                                  selectedColor: Colors.blue,
                                  backgroundColor: Colors.white,
                                  elevation: selectedCategory == index ? 4 : 1,
                                  shadowColor: Colors.blue.withValues(alpha: 0.3),
                                  onSelected: (bool selected) {
                                    setState(() {
                                      selectedCategory = index;
                                    });
                                    _loadPackages();
                                  },
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                    ],

                    // **Featured Packages**
                    if (featuredPackages.isNotEmpty && _searchController.text.isEmpty) ...[
                      Text(
                        "✨ Featured Packages",
                        style: TextStyle(
                          fontSize: isTablet ? 22 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      SizedBox(
                        height: 140,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: featuredPackages.length,
                          itemBuilder: (context, index) {
                            final package = featuredPackages[index];
                            return Container(
                              width: 220,
                              margin: EdgeInsets.only(right: 12),
                              child: Hero(
                                tag: 'featured_${package['package_id']}',
                                child: Card(
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(15),
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/view_details',
                                        arguments: {'packageId': package['package_id']},
                                      );
                                    },
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(15),
                                          child: Image.network(
                                            _getImageUrl(package),
                                            width: double.infinity,
                                            height: double.infinity,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return Container(
                                                color: Colors.grey[200],
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
                                              return Container(
                                                color: Colors.grey[300],
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.image_not_supported,
                                                        color: Colors.grey[600], size: 30),
                                                    SizedBox(height: 5),
                                                    Text('Image not available',
                                                        style: TextStyle(color: Colors.grey[600], fontSize: 10)),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(15),
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.black.withValues(alpha: 0.7),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 12,
                                          left: 12,
                                          right: 12,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                package['title'] ?? 'Package',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 4),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    _formatPrice(package['price_per_person']),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.orange,
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child: Text(
                                                      'Featured',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
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
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                    ],

                    // **Section Title**
                    Text(
                      _searchController.text.isNotEmpty
                          ? "🔍 Search Results (${packages.length})"
                          : selectedCategory == 0
                          ? "🎯 All Packages"
                          : "${categories[selectedCategory]} Packages",
                      style: TextStyle(
                        fontSize: isTablet ? 22 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // **Package List**
                    Expanded(
                      child: _buildPackagesList(screenWidth, screenHeight, isTablet),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPackagesList(double screenWidth, double screenHeight, bool isTablet) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            SizedBox(height: 16),
            Text(
              'Loading amazing packages...',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              errorMessage!,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadPackages,
              icon: Icon(Icons.refresh),
              label: Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (packages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
                _searchController.text.isNotEmpty ? Icons.search_off : Icons.explore_off,
                size: 64,
                color: Colors.grey[400]
            ),
            SizedBox(height: 16),
            Text(
              _searchController.text.isNotEmpty
                  ? 'No packages found'
                  : 'No packages available',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _searchController.text.isNotEmpty
                  ? 'Try searching with different keywords'
                  : 'Please check back later',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
            hasMorePackages &&
            !isLoadingMore &&
            _searchController.text.isEmpty) {
          _loadMorePackages();
        }
        return false;
      },
      child: ListView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: packages.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == packages.length) {
            return Container(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Loading more packages...',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          }

          final package = packages[index];
          return _buildPackageCard(package, screenWidth, screenHeight, isTablet, index);
        },
      ),
    );
  }

  Widget _buildPackageCard(Map<String, dynamic> package, double screenWidth, double screenHeight, bool isTablet, int index) {
    return Hero(
      tag: 'package_${package['package_id']}_$index',
      child: Card(
        elevation: 8,
        shadowColor: Colors.blue.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.only(bottom: screenHeight * 0.02),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/view_details',
              arguments: {'packageId': package['package_id']},
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // **Enhanced Image with Loading State**
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    child: SizedBox(
                      height: isTablet ? 250 : 200,
                      width: double.infinity,
                      child: Image.network(
                        _getImageUrl(package),
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: isTablet ? 250 : 200,
                            color: Colors.grey[200],
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                        : null,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Loading image...',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: isTablet ? 250 : 200,
                            color: Colors.grey[300],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image_not_supported,
                                    color: Colors.grey[600], size: 40),
                                SizedBox(height: 8),
                                Text(
                                  'Image not available',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                                Text(
                                  'Tap to view details',
                                  style: TextStyle(color: Colors.grey[500], fontSize: 10),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Gradient overlay for better text readability
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Text(
                        '${package['duration_days'] ?? 0} Days',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // **Title**
                    Text(
                      package['title'] ?? 'Travel Package',
                      style: TextStyle(
                        fontSize: isTablet ? 20 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 8),

                    // **Location**
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.red[400]),
                        SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            package['destination'] ?? 'Unknown Destination',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),

                    // **Package Details Row - FIXED ALIGNMENT**
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: [
                        _buildInfoChip(
                          Icons.people,
                          'Max ${package['max_travelers'] ?? 0}',
                          Colors.green,
                        ),
                        _buildInfoChip(
                          Icons.calendar_today,
                          '${package['duration_days'] ?? 0}D',
                          Colors.orange,
                        ),
                        if (package['package_type'] != null)
                          _buildInfoChip(
                            Icons.category,
                            package['package_type'].toString().toUpperCase(),
                            Colors.purple,
                          ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // **Price & Button**
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatPrice(package['price_per_person']),
                              style: TextStyle(
                                fontSize: isTablet ? 24 : 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                            Text(
                              'per person',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: LinearGradient(
                              colors: [Colors.blue, Colors.blue[700]!],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/view_details',
                                arguments: {'packageId': package['package_id']},
                              );
                            },
                            icon: Icon(Icons.visibility, size: 16),
                            label: Text('View Details'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: isTablet ? 20 : 16,
                                vertical: 12,
                              ),
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
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

