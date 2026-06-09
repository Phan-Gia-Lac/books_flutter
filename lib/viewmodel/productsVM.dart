import 'package:flutter/material.dart';
import '../models/data_model.dart';
import '../services/api_service.dart';

class ProductsVM extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Book> _featuredBooks = [];
  List<Book> _popularBooks = [];
  final List<Book> _cart = [];
  
  bool _isLoading = false;
  String? _error;

  List<Book> get featuredBooks => _featuredBooks;
  List<Book> get popularBooks => _popularBooks;
  List<Book> get cartItems => List.unmodifiable(_cart);
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get itemCount => _cart.length;

  double get total =>
      _cart.fold(0, (sum, book) => sum + book.price);

  Future<void> fetchBooks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final books = await _apiService.fetchComics();
      // For now, let's just split them or use the same list for both sections
      _featuredBooks = books.take(4).toList();
      _popularBooks = books;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  bool contains(Book book) =>
      _cart.any((b) => b.title == book.title && b.author == book.author);

  void addToCart(Book book) {
    _cart.add(book);
    notifyListeners();
  }

  void removeAt(int index) {
    if (index < 0 || index >= _cart.length) return;
    _cart.removeAt(index);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }
}
