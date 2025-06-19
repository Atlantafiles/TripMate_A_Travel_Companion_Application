import 'package:flutter/material.dart';
import 'package:tripmate/services/travelpackages_service.dart';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddTravelPackageScreen extends StatefulWidget {
  final Map<String, dynamic>? existingPackage; // For editing

  const AddTravelPackageScreen({
    super.key,
    this.existingPackage,
  });

  @override
  State<AddTravelPackageScreen> createState() => _AddTravelPackageScreenState();
}

class _AddTravelPackageScreenState extends State<AddTravelPackageScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _travelerController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  List<String> inclusions = [];
  List<String> exclusions = [];
  List<Map<String, String>> itinerary = [];

  final _formKey = GlobalKey<FormState>();
  final TravelPackagesService _service = TravelPackagesService();
  bool _isLoading = false;
  bool _isEditing = false;
  String? _packageId;
  String? _agencyId;
  bool _isInitialized = false;

  List<XFile> selectedImages = [];
  List<String> existingImageUrls = [];
  bool _isUploadingImages = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Fetch current agency ID from Supabase auth with multiple fallback methods
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        _showErrorAndNavigateToLogin('No user found. Please login again.');
        return;
      }

      print('User ID: ${user.id}'); // Debug log
      print('User Email: ${user.email}'); // Debug log
      print('User Metadata: ${user.userMetadata}'); // Debug log
      print('App Metadata: ${user.appMetadata}'); // Debug log

      // Method 1: Check user metadata
      _agencyId = user.userMetadata?['agency_id']?.toString();
      print('Agency ID from userMetadata: $_agencyId'); // Debug log

      // Method 2: Check app metadata
      if (_agencyId == null) {
        _agencyId = user.appMetadata['agency_id']?.toString();
        print('Agency ID from appMetadata: $_agencyId'); // Debug log
      }

      if (_agencyId == null) {
        // Method 3: Query the travelagencies table using user's email
        try {
          final response = await Supabase.instance.client
              .from('travelagencies')
              .select('agency_id')
              .eq('email', user.email!)
              .maybeSingle();

          print('Response from email query: $response'); // Debug log
          if (response != null && response['agency_id'] != null) {
            _agencyId = response['agency_id'].toString();
            print('Agency ID from email query: $_agencyId'); // Debug log
          }
        } catch (e) {
          print('Error querying agency by email: $e');
        }
      }

      // Set initialized flag regardless of whether agency_id was found
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }

      if (_agencyId == null) {
        _showErrorAndNavigateToLogin('Agency ID not found. Please contact support or login again.');
        return;
      }

      print('Final agency ID: $_agencyId'); // Debug log

      // Initialize package data if editing
      _initializePackageData();

    } catch (e) {
      print('Error fetching agency ID: $e');
      if (mounted) {
        setState(() {
          _isInitialized = true; // Set initialized even on error
        });
      }
      _showErrorAndNavigateToLogin('Error: Unable to identify agency. Please login again.');
    }
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          selectedImages.addAll(images);
        });
      }
    } catch (e) {
      _showSnackBar('Error picking images: ${e.toString()}', Colors.red);
    }
  }

  Future<void> _pickSingleImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          selectedImages.add(image);
        });
      }
    } catch (e) {
      _showSnackBar('Error picking image: ${e.toString()}', Colors.red);
    }
  }

  void _removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });
  }

  void _removeExistingImage(int index) {
    setState(() {
      existingImageUrls.removeAt(index);
    });
  }

  void _showErrorAndNavigateToLogin(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );

      // Navigate back to login after a delay
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/agency_signin');
        }
      });
    }
  }

  void _initializePackageData() {
    if (widget.existingPackage != null) {
      _isEditing = true;
      final package = widget.existingPackage!;
      _packageId = package['package_id']?.toString();

      _titleController.text = package['title']?.toString() ?? '';
      _destinationController.text = package['destination']?.toString() ?? '';
      _durationController.text = package['duration_days']?.toString() ?? '';
      _priceController.text = package['price_per_person']?.toString() ?? '';
      _travelerController.text = package['max_travelers']?.toString() ?? '';
      _tagsController.text = package['tags']?.toString() ?? '';

      // Handle existing images
      if (package['images'] is List) {
        existingImageUrls = List<String>.from(package['images'].map((e) => e.toString()));
      } else if (package['images'] is String) {
        try {
          final decoded = json.decode(package['images']);
          if (decoded is List) {
            existingImageUrls = List<String>.from(decoded.map((e) => e.toString()));
          }
        } catch (e) {
          existingImageUrls = [];
        }
      }

      // Parse JSON arrays
      if (package['inclusions'] is List) {
        inclusions = List<String>.from(package['inclusions'].map((e) => e.toString()));
      } else if (package['inclusions'] is String) {
        try {
          final decoded = json.decode(package['inclusions']);
          if (decoded is List) {
            inclusions = List<String>.from(decoded.map((e) => e.toString()));
          }
        } catch (e) {
          inclusions = [];
        }
      }

      if (package['exclusions'] is List) {
        exclusions = List<String>.from(package['exclusions'].map((e) => e.toString()));
      } else if (package['exclusions'] is String) {
        try {
          final decoded = json.decode(package['exclusions']);
          if (decoded is List) {
            exclusions = List<String>.from(decoded.map((e) => e.toString()));
          }
        } catch (e) {
          exclusions = [];
        }
      }

      if (package['itinerary'] is List) {
        itinerary = List<Map<String, String>>.from(
            package['itinerary'].map((item) {
              if (item is Map) {
                return Map<String, String>.from(
                    item.map((key, value) => MapEntry(key.toString(), value.toString()))
                );
              }
              return <String, String>{};
            })
        );
      } else if (package['itinerary'] is String) {
        try {
          final decoded = json.decode(package['itinerary']);
          if (decoded is List) {
            itinerary = List<Map<String, String>>.from(
                decoded.map((item) {
                  if (item is Map) {
                    return Map<String, String>.from(
                        item.map((key, value) => MapEntry(key.toString(), value.toString()))
                    );
                  }
                  return <String, String>{};
                })
            );
          }
        } catch (e) {
          itinerary = [];
        }
      }
    } else {
      // Default values for new package
      inclusions = ['meals', 'hotel', 'sightseeing'];
      exclusions = ['airfare', 'personal expenses'];
      itinerary = [
        {'day': 'Day 1', 'desc': 'Arrive and rest'},
        {'day': 'Day 2', 'desc': 'Visit local attractions'}
      ];
      _tagsController.text = 'adventure, beach, trekking';
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _addInclusion() {
    _showAddItemDialog('Add Inclusion', (value) {
      setState(() {
        inclusions.add(value);
      });
    });
  }

  void _addExclusion() {
    _showAddItemDialog('Add Exclusion', (value) {
      setState(() {
        exclusions.add(value);
      });
    });
  }

  void _addDay() {
    setState(() {
      itinerary.add({'day': 'Day ${itinerary.length + 1}', 'desc': ''});
    });
  }

  void _showAddItemDialog(String title, Function(String) onAdd) {
    String input = '';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(
          onChanged: (value) => input = value,
          decoration: const InputDecoration(hintText: "Enter text"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
              onPressed: () {
                if (input.isNotEmpty) {
                  onAdd(input);
                  Navigator.pop(context);
                }
              },
              child: const Text("Add"))
        ],
      ),
    );
  }

  Future<void> _submitPackage() async {
    if (!_formKey.currentState!.validate()) return;

    if (_agencyId == null) {
      _showSnackBar('Error: Agency ID not found. Please try refreshing or login again.', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Parse numeric values with null safety
      final durationDays = int.tryParse(_durationController.text.trim()) ?? 0;
      final pricePerPerson = double.tryParse(_priceController.text.trim()) ?? 0.0;
      final maxTravelers = int.tryParse(_travelerController.text.trim()) ?? 0;

      // Validate parsed values
      if (durationDays <= 0) {
        throw Exception('Duration must be greater than 0');
      }
      if (pricePerPerson <= 0) {
        throw Exception('Price must be greater than 0');
      }
      if (maxTravelers <= 0) {
        throw Exception('Maximum travelers must be greater than 0');
      }

      List<String> finalImageUrls = [];

      if (_isEditing && _packageId != null) {
        // Update existing package
        await _service.updateTravelPackage(
          packageId: _packageId!,
          agencyId: _agencyId!,
          title: _titleController.text.trim(),
          destination: _destinationController.text.trim(),
          durationDays: durationDays,
          pricePerPerson: pricePerPerson,
          maxTravelers: maxTravelers,
          inclusions: inclusions,
          exclusions: exclusions,
          itinerary: itinerary,
          tags: _tagsController.text.trim(),
        );

        // Upload new images if any
        if (selectedImages.isNotEmpty) {
          setState(() {
            _isUploadingImages = true;
          });

          final newImageUrls = await _service.uploadPackageImages(_packageId!, selectedImages);
          finalImageUrls = [...existingImageUrls, ...newImageUrls];

          // Update package with image URLs - FIXED: Use Supabase.instance.client instead of supabase
          await Supabase.instance.client
              .from('trippackages')
              .update({'images': finalImageUrls})
              .eq('package_id', _packageId!);
        } else {
          finalImageUrls = existingImageUrls;
        }

        _showSnackBar('Package updated successfully!', Colors.green);
      } else {
        // Create new package
        final response = await _service.createTravelPackage(
          agencyId: _agencyId!,
          title: _titleController.text.trim(),
          destination: _destinationController.text.trim(),
          durationDays: durationDays,
          pricePerPerson: pricePerPerson,
          maxTravelers: maxTravelers,
          inclusions: inclusions,
          exclusions: exclusions,
          itinerary: itinerary,
          tags: _tagsController.text.trim(),
        );

        final newPackageId = response['package_id'];

        // Upload images if any
        if (selectedImages.isNotEmpty) {
          setState(() {
            _isUploadingImages = true;
          });

          finalImageUrls = await _service.uploadPackageImages(newPackageId, selectedImages);

          // Update package with image URLs - FIXED: Use Supabase.instance.client instead of supabase
          await Supabase.instance.client
              .from('trippackages')
              .update({'images': finalImageUrls})
              .eq('package_id', newPackageId);
        }

        _showSnackBar('Package created successfully!', Colors.green);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      String errorMessage = e.toString();

      // Make error messages more user-friendly
      if (errorMessage.contains('Bucket not found')) {
        errorMessage = 'Image storage is not properly configured. Package saved without images.';
      } else if (errorMessage.contains('StorageException')) {
        errorMessage = 'Failed to upload images. Package saved without images.';
      } else if (errorMessage.contains('invalid input syntax for type uuid')) {
        errorMessage = 'Invalid agency ID format. Please logout and login again.';
      }

      _showSnackBar('Error: $errorMessage', Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isUploadingImages = false;
        });
      }
    }
  }

  Future<void> _deletePackage() async {
    if (!_isEditing || _packageId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Package'),
        content: const Text('Are you sure you want to delete this package? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _service.deleteTravelPackage(_packageId!);

      _showSnackBar('Package deleted successfully!', Colors.green);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showSnackBar('Error deleting package: ${e.toString()}', Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while initializing
    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? "Edit Travel Package" : "Add Travel Package"),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading agency information...'),
            ],
          ),
        ),
      );
    }

    // Show error state if initialized but no agency ID found
    if (_agencyId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? "Edit Travel Package" : "Add Travel Package"),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Agency ID not found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Please contact support or try logging in again.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? "Edit Travel Package" : "Add Travel Package"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: _isEditing ? [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _isLoading ? null : _deletePackage,
          ),
        ] : null,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("Package Title"),
              _buildTextField(_titleController, "Enter package title", isRequired: true),

              _buildLabel("Destination"),
              _buildTextField(_destinationController, "Enter destination",
                  suffixIcon: const Icon(Icons.search), isRequired: true),

              _buildLabel("Duration (Days)"),
              _buildTextField(_durationController, "Enter duration",
                  keyboardType: TextInputType.number, isRequired: true),

              _buildLabel("Price per Person (₹)"),
              _buildTextField(_priceController, "0.00",
                  keyboardType: const TextInputType.numberWithOptions(decimal: true), isRequired: true),

              _buildLabel("Maximum Travelers"),
              _buildTextField(_travelerController, "Enter maximum travelers",
                  keyboardType: TextInputType.number, isRequired: true),

              _buildLabel("Tags (comma separated)"),
              _buildTextField(_tagsController, "e.g., adventure, beach, trekking"),

              _buildImageSection(),

              _buildLabel("Inclusions"),
              _buildChips(inclusions, onAdd: _addInclusion),

              _buildLabel("Exclusions"),
              _buildChips(exclusions, onAdd: _addExclusion),

              _buildLabel("Itinerary"),
              ...itinerary.map((item) => _buildItineraryItem(item)).toList(),
              TextButton.icon(
                onPressed: _addDay,
                icon: const Icon(Icons.add, size: 18),
                label: const Text("Add Day"),
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onPressed: (_isLoading || _isUploadingImages) ? null : _submitPackage,
                  child: (_isLoading || _isUploadingImages)
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                        _isEditing ? "Update Package" : "Add Package",
                        style: const TextStyle(fontSize: 16, color: Colors.white)
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String hintText, {
        TextInputType keyboardType = TextInputType.text,
        Widget? suffixIcon,
        bool isRequired = false,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.deepPurple),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: isRequired
          ? (value) {
        if (value == null || value.trim().isEmpty) {
          return 'This field is required';
        }
        return null;
      }
          : null,
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Package Images"),

        // Existing images (for editing)
        if (existingImageUrls.isNotEmpty) ...[
          const Text('Current Images:', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: existingImageUrls.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          existingImageUrls[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey[300],
                              child: const Icon(Icons.error),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeExistingImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],

        // New images to upload
        if (selectedImages.isNotEmpty) ...[
          const Text('New Images to Upload:', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: selectedImages.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(selectedImages[index].path),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Add image buttons
        Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickSingleImage,
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text('Add Single Image'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Add Multiple Images'),
                ),
              ),
            ],
        ),

            if (_isUploadingImages) ...[
              const SizedBox(height: 8),
              const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Uploading images...'),
                ],
              ),
            ],
      ],
    );
  }

  Widget _buildChips(List<String> items, {required VoidCallback onAdd}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            ...items.map((item) => Chip(
              label: Text(item),
              onDeleted: () {
                setState(() {
                  items.remove(item);
                });
              },
              deleteIcon: const Icon(Icons.close, size: 18),
            )),
            ActionChip(
              label: const Text("+ Add"),
              onPressed: onAdd,
              backgroundColor: Colors.deepPurple.shade50,
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildItineraryItem(Map<String, String> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: "Day",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    controller: TextEditingController(text: item['day']),
                    onChanged: (value) {
                      item['day'] = value;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    setState(() {
                      itinerary.remove(item);
                    });
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              controller: TextEditingController(text: item['desc']),
              onChanged: (value) {
                item['desc'] = value;
              },
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _destinationController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    _travelerController.dispose();
    _tagsController.dispose();
    super.dispose();
  }
}