import 'package:flutter/material.dart';
import '../models/data_model.dart';
import '../models/cart_item.dart';
import '../services/api_service.dart';

class ProductsVM extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Book> _featuredBooks = [];
  List<Book> _popularBooks = [];
  List<Book> _searchResults = [];
  List<Category> _categories = [];
  List<Author> _authors = [];
  List<Publisher> _publishers = [];
  final List<CartItem> _cart = [];
  
  bool _isLoading = false;
  bool _isSearching = false;
  String? _error;

  List<Book> get featuredBooks => _featuredBooks;
  List<Book> get popularBooks => _popularBooks;
  List<Book> get searchResults => _searchResults;
  List<Category> get categories => _categories;
  List<Author> get authors => _authors;
  List<Publisher> get publishers => _publishers;
  List<CartItem> get cartItems => List.unmodifiable(_cart);
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get error => _error;

  int get itemCount => _cart.fold(0, (sum, item) => sum + item.quantity);

  double get total =>
      _cart.fold(0, (sum, item) => sum + item.totalPrice);

  Future<void> fetchBooks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Fetch everything in parallel
      final results = await Future.wait([
        _apiService.fetchComics(sortBy: 'newest', limit: 10),
        _apiService.fetchComics(sortBy: 'rating_desc', limit: 10),
        _apiService.fetchCategories(),
      ]);

      _featuredBooks = results[0] as List<Book>;
      _popularBooks = results[1] as List<Book>;
      _categories = results[2] as List<Category>;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchCategories() async {
    try {
      _categories = await _apiService.fetchCategories();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }
  }

  Future<void> fetchAuthors() async {
    try {
      _authors = await _apiService.fetchAuthors();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching authors: $e');
    }
  }

  Future<void> fetchPublishers() async {
    try {
      _publishers = await _apiService.fetchPublishers();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching publishers: $e');
    }
  }

  Future<void> searchBooks({
    String? query,
    int? categoryId,
    int? authorId,
    int? publisherId,
    String? sortBy,
    double? minPrice,
    double? maxPrice,
    double? minRating,
  }) async {
    _isSearching = true;
    notifyListeners();

    try {
      _searchResults = await _apiService.fetchComics(
        search: query,
        categoryId: categoryId,
        authorId: authorId,
        publisherId: publisherId,
        sortBy: sortBy,
        minPrice: minPrice,
        maxPrice: maxPrice,
        minRating: minRating,
      );
      _isSearching = false;
      notifyListeners();
    } catch (e) {
      _isSearching = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  bool contains(Book book) =>
      _cart.any((item) => item.book.id == book.id || (item.book.title == book.title && item.book.author == book.author));

  void addToCart(Book book) {
    final index = _cart.indexWhere((item) => item.book.id == book.id);
    if (index != -1) {
      _cart[index].quantity++;
    } else {
      _cart.add(CartItem(book: book));
    }
    notifyListeners();
  }

  void incrementQuantity(int bookId) {
    final index = _cart.indexWhere((item) => item.book.id == bookId);
    if (index != -1) {
      _cart[index].quantity++;
      notifyListeners();
    }
  }

  void decrementQuantity(int bookId) {
    final index = _cart.indexWhere((item) => item.book.id == bookId);
    if (index != -1) {
      if (_cart[index].quantity > 1) {
        _cart[index].quantity--;
      } else {
        _cart.removeAt(index);
      }
      notifyListeners();
    }
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
