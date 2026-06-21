// Add register model

class User {
  final int id;
  final String fullName;
  final String email;
  final String password;
  final String role;
  final String? phoneNumber;
  final int? points;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.password,
    required this.role,
    this.phoneNumber,
    this.points,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      // Safely parse int even if the backend returns it as a string
      id: int.tryParse(json['id'].toString()) ?? 0,
      
      // Fallback handles both database columns (full_name) and model formats (fullName)
      fullName: (json['fullName'] ?? json['full_name'] ?? '') as String,
      
      email: (json['email'] ?? '') as String,

      password: (json['password'] ?? '') as String,

      role: (json['role'] ?? 'CUSTOMER') as String,
      
      // Fallback handles both phone field variations safely
      phoneNumber: (json['phone_number'] ?? json['phoneNumber'])?.toString(),
      
      points: json['points'] != null ? int.tryParse(json['points'].toString()) : null,
      
      createdAt: json['created_at'] != null || json['createdAt'] != null
          ? DateTime.tryParse((json['created_at'] ?? json['createdAt']).toString())
          : null,
    );
  }

  // Helper method to convert a User instance back to a Map JSON structure
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'password': password,
      'role': role,
      'phone_number': phoneNumber,
      'points': points,
      'created_at': createdAt?.toIso8601String(),
    };
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
    // Some Express architectures wrap the inner payload inside a 'data' block.
    // This dynamically tracks and grabs the correct root object structure.
    final userData = (json['user'] ?? json['data']?['user'] ?? json['data'] ?? json) as Map<String, dynamic>;

    return LoginResult(
      user: User.fromJson(userData),
      
      // Catches camelCase, snake_case, and nested API structures seamlessly
      accessToken: (json['accessToken'] ?? 
                    json['access_token'] ?? 
                    json['data']?['accessToken'] ?? 
                    json['data']?['access_token'] ?? '') as String,
    );
  }
}