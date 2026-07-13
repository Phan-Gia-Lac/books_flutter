import 'package:flutter/foundation.dart';
import '../models/data_model.dart';
import '../services/api_service.dart';


// ── AdminVM ─────────────────────────────────────────────────────────────────
class AdminVM extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Book> _books = [];
  List<dynamic> _pendingOrders = [];

  bool _isLoading = false;
  String? _error;

  List<Book> get books => _books;
  List<dynamic> get pendingOrders => _pendingOrders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ── Comics: fetch / add / update / delete ──────────────────────────────

  Future<void> fetchBooks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _books = await _api.fetchComics();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Could not connect to server. Check that the backend is running.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addBook({
    required String title,
    required double price,
    required String description,
    required int categoryId,
    required int authorId,
    required String token,
  }) async {
    _error = null;
    try {
      final book = await _api.createComic(
        title: title,
        price: price,
        description: description,
        categoryId: categoryId,
        authorId: authorId,
        token: token,
      );
      _books.insert(0, book);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to add comic. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBook({
    required int id,
    required String title,
    required double price,
    required String description,
    required String token,
  }) async {
    _error = null;
    try {
      final updated = await _api.updateComic(
        id: id,
        title: title,
        price: price,
        description: description,
        token: token,
      );
      final index = _books.indexWhere((b) => b.id == id);
      if (index != -1) _books[index] = updated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to update comic. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBook(int id, String token) async {
    _error = null;
    try {
      await _api.deleteComic(id: id, token: token);
      _books.removeWhere((b) => b.id == id);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to delete comic. Please try again.';
      notifyListeners();
      return false;
    }
  }

  // ── Orders: fetch pending / approve ─────────────────────────────────────

  Future<void> fetchPendingOrders(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pendingOrders = await _api.fetchPendingOrders(token);
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Could not connect to server. Check that the backend is running.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> approveOrder(int orderId, String token) async {
    _error = null;
    try {
      await _api.approveOrder(orderId: orderId, token: token);
      _pendingOrders.removeWhere((o) => o['id'] == orderId);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to approve order. Please try again.';
      notifyListeners();
      return false;
    }
  }
}