import 'package:flutter/material.dart';

// Book model class
class Book {
  final int? id;
  final String title;
  final String author;
  final String? description;
  final double rating;
  final double price;
  final Color coverColor;
  final String? coverImage;

  const Book({
    this.id,
    required this.title,
    required this.author,
    this.description,
    required this.rating,
    required this.price,
    required this.coverColor,
    this.coverImage,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'] ?? 'Unknown Title',
      author: json['author'] ?? 'Unknown Author',
      description: json['description'],
      rating: (json['rating'] ?? 0.0).toDouble(),
      price: (json['price'] ?? 0.0).toDouble(),
      coverColor: const Color(0xFF6C63FF), // Default color for now
      coverImage: json['cover_image'],
    );
  }
}

// Sameple data for books
// ── Placeholder data ─────────────────────────────────────────────────────────
final List<Book> featuredBooks = [
  Book(title: 'The Great Gatsby',       author: 'F. Scott Fitzgerald', rating: 4.5, price: 12.99, coverColor: const Color(0xFF6C63FF)),
  Book(title: 'To Kill a Mockingbird',  author: 'Harper Lee',           rating: 4.8, price: 10.99, coverColor: const Color(0xFF2196F3)),
  Book(title: '1984',                   author: 'George Orwell',         rating: 4.7, price: 9.99,  coverColor: const Color(0xFFE91E63)),
  Book(title: 'Dune',                   author: 'Frank Herbert',         rating: 4.6, price: 14.99, coverColor: const Color(0xFFFF9800)),
];

final List<Book> popularBooks = [
  Book(title: 'Harry Potter',    author: 'J.K. Rowling',          rating: 4.9, price: 15.99, coverColor: const Color(0xFF9C27B0)),
  Book(title: 'The Hobbit',      author: 'J.R.R. Tolkien',        rating: 4.7, price: 11.99, coverColor: const Color(0xFF4CAF50)),
  Book(title: 'Sherlock Holmes', author: 'Arthur Conan Doyle',    rating: 4.5, price: 8.99,  coverColor: const Color(0xFF795548)),
  Book(title: 'The Alchemist',   author: 'Paulo Coelho',          rating: 4.6, price: 10.99, coverColor: const Color(0xFF009688)),
  Book(title: 'Brave New World', author: 'Aldous Huxley',         rating: 4.3, price: 9.99,  coverColor: const Color(0xFFF44336)),
  Book(title: 'Fahrenheit 451',  author: 'Ray Bradbury',          rating: 4.4, price: 8.99,  coverColor: const Color(0xFF3F51B5)),
];
