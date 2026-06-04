import 'package:flutter/material.dart';
import '../models/data_model.dart';

class ProductsVM extends ChangeNotifier {
  final List<Book> _cart = [];

  List<Book> get cartItems => List.unmodifiable(_cart);

  int get itemCount => _cart.length;

  double get total =>
      _cart.fold(0, (sum, book) => sum + book.price);

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
