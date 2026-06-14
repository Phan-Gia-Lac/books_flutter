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

    if (response.statusCode == 200 && body['success'] == true) {
      return LoginResult.fromJson(body['data'] as Map<String, dynamic>);
    }

    throw ApiException(
      body['message'] as String? ?? 'Login failed (${response.statusCode})',
    );
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
