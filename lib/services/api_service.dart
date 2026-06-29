import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' hide Category;
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

  Future<List<Book>> fetchComics({
    String? search,
    int? categoryId,
    int? authorId,
    int? publisherId,
    String? sortBy,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    int? limit,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (categoryId != null) queryParams['category'] = categoryId.toString();
      if (authorId != null) queryParams['author'] = authorId.toString();
      if (publisherId != null) queryParams['publisher'] = publisherId.toString();
      if (sortBy != null) queryParams['sort_by'] = sortBy;
      if (minPrice != null) queryParams['min_price'] = minPrice.toString();
      if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();
      if (minRating != null) queryParams['min_rating'] = minRating.toString();
      if (limit != null) queryParams['limit'] = limit.toString();

      final uri =
          Uri.parse('$baseUrl/comics').replace(queryParameters: queryParams);
      final response = await http.get(uri);

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

  Future<List<Category>> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/categories'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true) {
          final List<dynamic> data = body['data'];
          return data.map((json) => Category.fromJson(json)).toList();
        } else {
          throw ApiException(body['message'] as String? ?? 'Failed to load categories');
        }
      } else {
        throw ApiException('Failed to connect to backend: ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Error fetching categories: $e');
    }
  }

  Future<List<Author>> fetchAuthors() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/authors'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true) {
          final List<dynamic> data = body['data'];
          return data.map((json) => Author.fromJson(json)).toList();
        } else {
          throw ApiException(body['message'] as String? ?? 'Failed to load authors');
        }
      } else {
        throw ApiException('Failed to connect to backend: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Error fetching authors: $e');
    }
  }

  Future<List<Publisher>> fetchPublishers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/publishers'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true) {
          final List<dynamic> data = body['data'];
          return data.map((json) => Publisher.fromJson(json)).toList();
        } else {
          throw ApiException(body['message'] as String? ?? 'Failed to load publishers');
        }
      } else {
        throw ApiException('Failed to connect to backend: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Error fetching publishers: $e');
    }
  }

  Future<List<dynamic>> fetchMyOrders(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/me'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true) {
          return body['data'];
        } else {
          throw ApiException(body['message'] as String? ?? 'Failed to load orders');
        }
      } else {
        throw ApiException('Failed to connect to backend: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Error fetching orders: $e');
    }
  }

  Future<void> placeOrder({
    required List<Map<String, dynamic>> items,
    required String address,
    required String paymentMethod,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'items': items,
        'shipping_address': address,
        'payment_method': paymentMethod,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      throw ApiException(body['message'] as String? ?? 'Failed to place order');
    }
  }

  Future<List<Review>> fetchComicReviews(int comicId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/comics/$comicId/reviews'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true) {
          final List<dynamic> data = body['data'];
          return data.map((json) => Review.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching reviews: $e');
      return [];
    }
  }

  Future<void> submitReview({
    required int comicId,
    required int rating,
    required String comment,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/comics/$comicId/reviews'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'rating': rating,
        'comment': comment,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      throw ApiException(body['message'] as String? ?? 'Failed to submit review');
    }
  }
}
