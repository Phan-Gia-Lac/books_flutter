import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthVM extends ChangeNotifier {
  final ApiService _api = ApiService();

  User? _user;
  String? _accessToken;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get accessToken => _accessToken;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _accessToken != null;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _api.login(email: email, password: password);
      _user = result.user;
      _accessToken = result.accessToken;
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (e, stack) {
      _error = 'Could not connect to server. Check that the backend is running.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String fullName, String email, String password) async {
    try {
      final result = await _api.register(fullName: fullName, email: email, password: password);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    }
  }

  void logout() {
    _user = null;
    _accessToken = null;
    _error = null;
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String fullName,
    // String password,
    required String phoneNumber
  }) async {
    try {
      final updatedUser = await _api.updateProfile(fullName: fullName, token: _accessToken ?? '', phone_number: phoneNumber);
      _user = updatedUser;
      return true;
    } catch (e) {
      return false;
    }
  }
}
