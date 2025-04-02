class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class LoginResponse {
  final String token;
  final String refreshToken;
  final UserData user;

  LoginResponse({
    required this.token,
    required this.refreshToken,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      refreshToken: json['refreshToken'],
      user: UserData.fromJson(json['user']),
    );
  }
}

class UserData {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;

  UserData({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profileImageUrl: json['profileImageUrl'],
    );
  }
} 