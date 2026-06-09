import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/data_model.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  Future<List<Book>> fetchComics() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/comics'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true) {
          final List<dynamic> data = body['data'];
          return data.map((json) => Book.fromJson(json)).toList();
        } else {
          throw Exception(body['message'] ?? 'Failed to load comics');
        }
      } else {
        throw Exception('Failed to connect to backend: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching comics: $e');
    }
  }
}
