// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:tripmate/services/auth_service.dart';
//
// class SignUpScreen extends StatefulWidget {
//   const SignUpScreen({super.key});
//
//   @override
//   State<SignUpScreen> createState() => _SignUpScreenState();
// }
//
// class _SignUpScreenState extends State<SignUpScreen> {
//   final _authService = AuthService();
//   final picker = ImagePicker();
//   File? _image;
//
//   final TextEditingController _fullNameController = TextEditingController();
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//
//   final List<String> interests = ["Adventure", "Culture", "Food", "Nature", "Urban"];
//   final Set<String> selectedPreferences = {};
//
//   bool _obscureText = true;
//   bool _isLoading = false;
//
//   Future<void> _pickImage() async {
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//       });
//     }
//   }
//
//   Future<void> _signUp() async {
//     final email = _emailController.text.trim();
//     final password = _passwordController.text.trim();
//     final fullName = _fullNameController.text.trim();
//     final username = _usernameController.text.trim();
//     final phoneNumber = _phoneController.text.trim();
//     final profilePicture = _image?.path ?? '';
//     final bio = ''; // Optional
//     final interests = selectedPreferences.toList();
//
//     if ([email, password, fullName, username, phoneNumber].any((field) => field.isEmpty) || interests.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please fill all fields and select at least one interest.')),
//       );
//       return;
//     }
//
//     setState(() => _isLoading = true);
//
//     try {
//       final result = await _authService.signUp(
//         email: email,
//         password: password,
//         fullName: fullName,
//         username: username,
//         phoneNumber: phoneNumber,
//         profilePicture: profilePicture,
//         bio: bio,
//         selectedPreferences: interests,
//       );
//
//       if (result.user != null) {
//         Navigator.pushReplacementNamed(context, '/verify_identity');
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Sign up failed.')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(leading: BackButton()),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               GestureDetector(
//                 onTap: _pickImage,
//                 child: Stack(
//                   alignment: Alignment.bottomRight,
//                   children: [
//                     CircleAvatar(
//                       radius: 50,
//                       backgroundColor: Colors.grey.shade300,
//                       backgroundImage: _image != null ? FileImage(_image!) : null,
//                       child: _image == null ? const Icon(Icons.camera_alt, size: 40) : null,
//                     ),
//                     const CircleAvatar(
//                       radius: 15,
//                       backgroundColor: Colors.blue,
//                       child: Icon(Icons.camera, color: Colors.white, size: 15),
//                     )
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 10),
//               const Text("Add Photo", style: TextStyle(fontSize: 16, color: Colors.grey)),
//               const SizedBox(height: 20),
//               TextField(
//                 controller: _fullNameController,
//                 decoration: const InputDecoration(labelText: "Full Name", border: OutlineInputBorder()),
//               ),
//               const SizedBox(height: 10),
//               TextField(
//                 controller: _usernameController,
//                 decoration: const InputDecoration(labelText: "Username", border: OutlineInputBorder()),
//               ),
//               const SizedBox(height: 10),
//               TextField(
//                 controller: _phoneController,
//                 decoration: const InputDecoration(labelText: "Phone Number", border: OutlineInputBorder()),
//               ),
//               const SizedBox(height: 10),
//               TextField(
//                 controller: _emailController,
//                 decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
//               ),
//               const SizedBox(height: 10),
//               TextField(
//                 obscureText: _obscureText,
//                 controller: _passwordController,
//                 decoration: InputDecoration(
//                   labelText: "Password",
//                   border: const OutlineInputBorder(),
//                   suffixIcon: IconButton(
//                     icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
//                     onPressed: () => setState(() => _obscureText = !_obscureText),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               const Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text("Interests", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//               ),
//               Wrap(
//                 spacing: 8,
//                 children: interests.map((interest) {
//                   final selected = selectedPreferences.contains(interest);
//                   return ChoiceChip(
//                     label: Text(interest),
//                     selected: selected,
//                     onSelected: (selected) => setState(() {
//                       if (selected) {
//                         selectedPreferences.add(interest);
//                       } else {
//                         selectedPreferences.remove(interest);
//                       }
//                     }),
//                   );
//                 }).toList(),
//               ),
//               const SizedBox(height: 20),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _signUp,
//                   child: _isLoading
//                       ? const CircularProgressIndicator(color: Colors.white)
//                       : const Text("Create Account"),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:tripmate/services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  List<String> selectedPreferences = [];

  final List<String> preferenceOptions = [
    'Adventure',
    'Beach',
    'Nature',
    'Historical',
    'Wildlife',
    'Relaxation',
    'Culture',
    'Mountains',
    'Food & Dining',
    'Photography',
    'Sports',
    'Music & Festivals',
  ];

  Future<void> _handleSignup() async {
    // Prevent multiple submissions
    if (_isLoading) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final fullName = _fullNameController.text.trim();
    final phoneNumber = _phoneController.text.trim();
    final bio = _bioController.text.trim();

    // Additional validations
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (selectedPreferences.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one preference')),
      );
      return;
    }

    // Validate email format
    if (!_authService.isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    // Validate password strength
    final passwordError = _authService.validatePassword(password);
    if (passwordError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(passwordError)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await _authService.signUp(
        context: context,
        email: email,
        password: password,
        username: username,
        fullName: fullName,
        phoneNumber: phoneNumber,
        bio: bio.isNotEmpty ? bio : null, // Pass null if bio is empty
        selectedPreferences: selectedPreferences,
      );

      if (success && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully! Please check your email for verification.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Clear form fields
        _clearForm();

        // Navigate to login screen after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        });
      }
    } catch (e) {
      print('Signup error in UI: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signup failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _clearForm() {
    _usernameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _fullNameController.clear();
    _phoneController.clear();
    _bioController.clear();
    setState(() {
      selectedPreferences.clear();
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.08),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Full Name Field
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your full name';
                  }
                  if (value.trim().length < 2) {
                    return 'Full name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Username Field
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a username';
                  }
                  if (value.trim().length < 3) {
                    return 'Username must be at least 3 characters';
                  }
                  if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value.trim())) {
                    return 'Username can only contain letters, numbers, and underscores';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!_authService.isValidEmail(value.trim())) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Phone Number Field
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (value.trim().length < 10) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  final passwordError = _authService.validatePassword(value);
                  return passwordError;
                },
              ),
              const SizedBox(height: 15),

              // Confirm Password Field
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Bio Field (Optional)
              TextFormField(
                controller: _bioController,
                decoration: InputDecoration(
                  labelText: "Bio (Optional)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                maxLines: 3,
                maxLength: 200,
              ),
              const SizedBox(height: 20),

              // Preferences Section
              const Text(
                "Select Your Travel Preferences:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),

              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: preferenceOptions.map((pref) {
                  final isSelected = selectedPreferences.contains(pref);
                  return FilterChip(
                    label: Text(pref),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          selectedPreferences.add(pref);
                        } else {
                          selectedPreferences.remove(pref);
                        }
                      });
                    },
                    selectedColor: Colors.blue.withValues(alpha: 0.3),
                    checkmarkColor: Colors.blue,
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),

              // Sign Up Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isLoading ? null : _handleSignup,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Create Account",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Already have account link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  TextButton(
                    onPressed: _isLoading ? null : () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text(
                      "Sign In",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}