import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/data_model.dart';
import '../models/user_model.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
// update profile service isnt working
class ApiService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000/api';
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api';
    }
    return 'http://localhost:3000/api';
  }

  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email.trim(),
        'password': password,
      }),
    );

    final Map<String, dynamic> body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return LoginResult.fromJson(body);
    }

    throw ApiException(
      body['message'] as String? ?? 'Login failed (${response.statusCode})',
    );
  }

  Future<bool> register({
  required String fullName,
  required String email,
  required String password,
}) async {
  // 1. Rename to 'response' for clarity (http.post returns a Response object)
  final response = await http.post(
    Uri.parse('$baseUrl/auth/register'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email.trim(),
      'password': password.trim(),
      'full_name': fullName.trim(),
    }),
  );

  // 2. If backend says success, return true
  if (response.statusCode == 201 || response.statusCode == 200) {
    return true;
  } else {
    // 3. Instead of a generic message, extract the REAL error message from your backend body
    try {
      final Map<String, dynamic> body = jsonDecode(response.body);
      
      // Throws your custom ApiException containing the backend's precise reason
      throw ApiException(body['message'] as String? ?? 'Failed to register account (${response.statusCode})');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to register account (${response.statusCode})');
    }
  }
}

  Future<User> updateProfile({required String fullName, required String token ,required String phone_number}) async {
    try {
      final data = await http.put(
        Uri.parse('$baseUrl/users/me'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token',},
        body: jsonEncode({
          'fullName': fullName.trim(),
          // 'password': password.trim()
          'phone_number': phone_number.trim()
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(data.body);
      return User.fromJson(responseData['user'] ?? responseData);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error occured');
    }
  }

  Future<List<Book>> fetchComics() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/comics'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true) {
          final List<dynamic> data = body['data'];
          return data.map((json) => Book.fromJson(json)).toList();
        } else {
          throw ApiException(body['message'] as String? ?? 'Failed to load comics');
        }
      } else {
        throw ApiException('Failed to connect to backend: ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Error fetching comics: $e');
    }
  }
}
