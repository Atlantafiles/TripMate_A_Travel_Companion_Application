import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  // Test method to check what data exists in the users table
  Future<void> debugUserData() async {
    try {
      final users = await supabase
          .from('users')
          .select('*')
          .limit(5);

      debugPrint('Current users data: $users');

      // Check which columns have data
      if (users.isNotEmpty) {
        final firstUser = users.first;
        debugPrint('First user keys: ${firstUser.keys.toList()}');
        debugPrint('First user values: ${firstUser.values.toList()}');
      }
    } catch (e) {
      debugPrint('Error fetching debug data: $e');
    }
  }

  Future<bool> signUp({
    required BuildContext context,
    required String email,
    required String password,
    required String username,
    required String fullName,
    required String phoneNumber,
    String? bio,
    List<String>? selectedPreferences,
  }) async {
    try {
      // Debug: Check if username already exists
      debugPrint('Checking username availability: $username');

      try {
        final existingUser = await supabase
            .from('users')
            .select('username')
            .eq('username', username)
            .maybeSingle();

        debugPrint('Username check result: $existingUser');

        if (existingUser != null) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Username already taken. Please choose a different username.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return false;
        }
      } catch (e) {
        debugPrint('Username check failed: $e');
      }

      debugPrint('Starting user registration for email: $email');

      // Sign up with Supabase Auth
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        debugPrint('Auth signup failed - no user returned');
        throw 'Sign-up failed - no user returned';
      }

      debugPrint('Auth user created with ID: ${user.id}');

      // Wait for auth user to be fully created
      await Future.delayed(const Duration(milliseconds: 1000));

      final userId = user.id;

      // Prepare user data - make sure all fields match your table columns exactly
      final userData = {
        'id': userId,
        'username': username,
        'email': email,
        'full_name': fullName,
        'phone_number': phoneNumber,
        'bio': bio ?? '',
        'selected_preferences': selectedPreferences ?? [],
        'is_verified': false,
      };

      debugPrint('Attempting to insert user data: $userData');

      try {
        // Use upsert instead of insert to handle potential conflicts
        final insertResponse = await supabase
            .from('users')
            .upsert(userData)
            .select();

        debugPrint('User profile created successfully: $insertResponse');

        await debugUserData();

      } catch (insertError) {
        debugPrint('Profile creation failed: $insertError');
        debugPrint('Insert error type: ${insertError.runtimeType}');

        // Try to get more detailed error information
        if (insertError is PostgrestException) {
          debugPrint('Postgrest error details: ${insertError.details}');
          debugPrint('Postgrest error message: ${insertError.message}');
          debugPrint('Postgrest error code: ${insertError.code}');
        }

        // Cleanup auth user if profile creation fails
        try {
          await supabase.auth.admin.deleteUser(userId);
          debugPrint('Auth user cleaned up after profile creation failure');
        } catch (deleteError) {
          debugPrint('Failed to cleanup auth user: $deleteError');
        }

        // Handle specific errors
        final errorString = insertError.toString().toLowerCase();
        if (errorString.contains('duplicate key') ||
            errorString.contains('already exists') ||
            errorString.contains('unique constraint')) {
          throw 'Username or email already exists. Please use different credentials.';
        } else if (errorString.contains('column') && errorString.contains('does not exist')) {
          throw 'Database schema error. Please contact support.';
        } else if (errorString.contains('violates not-null constraint')) {
          throw 'Required field is missing. Please fill all required fields.';
        } else {
          throw 'Failed to create user profile: ${insertError.toString()}';
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully! Please check your email for verification.'),
            backgroundColor: Colors.green,
          ),
        );
      }

      return true;

    } catch (e) {
      debugPrint('Signup error: $e');

      String errorMessage = 'Signup failed. Please try again.';

      // Handle specific error cases
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('user already registered') ||
          errorString.contains('already been registered')) {
        errorMessage = 'Email already registered. Please sign in instead.';
      } else if (errorString.contains('duplicate key') ||
          errorString.contains('already exists')) {
        errorMessage = 'Username or email already exists. Please use different credentials.';
      } else if (errorString.contains('password should be at least')) {
        errorMessage = 'Password is too weak. Please use a stronger password.';
      } else if (errorString.contains('invalid email')) {
        errorMessage = 'Please enter a valid email address.';
      } else if (errorString.contains('database schema error')) {
        errorMessage = 'Database configuration issue. Please contact support.';
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }

  // Keep your existing methods...
  Future<bool> signIn({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login successful!'),
              backgroundColor: Colors.green,
            ),
          );
        }
        return true;
      } else {
        throw 'Login failed - no user returned';
      }
    } catch (e) {
      debugPrint('Login error: $e');
      if (context.mounted) {
        String errorMessage = 'Login failed';

        final errorString = e.toString().toLowerCase();
        if (errorString.contains('invalid login credentials') ||
            errorString.contains('invalid credentials')) {
          errorMessage = 'Invalid email or password';
        } else if (errorString.contains('email not confirmed')) {
          errorMessage = 'Please verify your email before logging in';
        } else if (errorString.contains('too many requests')) {
          errorMessage = 'Too many login attempts. Please try again later.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }

  Future<bool> signOut({BuildContext? context}) async {
    try {
      await supabase.auth.signOut();

      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged out successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

      return true;
    } catch (e) {
      debugPrint('Logout error: $e');

      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }

      return false;
    }
  }

  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }

  bool isSignedIn() {
    return supabase.auth.currentUser != null;
  }

  Stream<AuthState> authStateChanges() {
    return supabase.auth.onAuthStateChange;
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await supabase
          .from('users')
          .select('*')
          .eq('id', userId)
          .single();
      return response;
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return null;
    }
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[\w-]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String? validatePassword(String password) {
    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null;
  }
}