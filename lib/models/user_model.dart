class User {
  final int id;
  final String fullName;
  final String email;
  final String role;
  final String? phoneNumber;
  final int? points;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.phoneNumber,
    this.points,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'CUSTOMER',
      phoneNumber: json['phone_number'] as String?,
      points: json['points'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}

class LoginResult {
  final User user;
  final String accessToken;

  const LoginResult({
    required this.user,
    required this.accessToken,
  });

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    return LoginResult(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String,
    );
  }
}
