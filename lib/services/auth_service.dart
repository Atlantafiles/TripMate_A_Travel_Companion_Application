// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences.dart';
// import '../models/auth_models.dart';
//
// class AuthService {
//   static const String baseUrl = 'YOUR_API_BASE_URL'; // Replace with your actual API URL
//   static const String tokenKey = 'auth_token';
//   static const String refreshTokenKey = 'refresh_token';
//   static const String userDataKey = 'user_data';
//
//   Future<LoginResponse> login(String email, String password) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/auth/login'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(LoginRequest(
//           email: email,
//           password: password,
//         ).toJson()),
//       );
//
//       if (response.statusCode == 200) {
//         final loginResponse = LoginResponse.fromJson(jsonDecode(response.body));
//         await _saveAuthData(loginResponse);
//         return loginResponse;
//       } else {
//         throw Exception('Failed to login: ${response.body}');
//       }
//     } catch (e) {
//       throw Exception('Login error: $e');
//     }
//   }
//
//   Future<void> _saveAuthData(LoginResponse response) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(tokenKey, response.token);
//     await prefs.setString(refreshTokenKey, response.refreshToken);
//     await prefs.setString(userDataKey, jsonEncode(response.user));
//   }
//
//   Future<void> logout() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(tokenKey);
//     await prefs.remove(refreshTokenKey);
//     await prefs.remove(userDataKey);
//   }
//
//   Future<String?> getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(tokenKey);
//   }
//
//   Future<String?> getRefreshToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(refreshTokenKey);
//   }
//
//   Future<UserData?> getUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//     final userDataString = prefs.getString(userDataKey);
//     if (userDataString != null) {
//       return UserData.fromJson(jsonDecode(userDataString));
//     }
//     return null;
//   }
// }