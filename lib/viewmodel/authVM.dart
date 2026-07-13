import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthVM extends ChangeNotifier {
  final ApiService _api = ApiService();

  User? _user;
  String? _accessToken;
  bool _isLoading = false;
  String? _error;
  String? _twoStepEmail;

  User? get user => _user;
  String? get accessToken => _accessToken;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _accessToken != null;
  String? get error => _error;
  String? get twoStepEmail => _twoStepEmail;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Enum or status to handle login stages
  // Future<bool> login(String email, String password) async {
  //   _isLoading = true;
  //   _error = null;
  //   notifyListeners();
  //
  //   try {
  //     final result = await _api.login(email: email, password: password);
  //     _user = result.user;
  //     _accessToken = result.accessToken;
  //     return true;
  //   } on ApiException catch (e) {
  //     _error = e.message;
  //     return false;
  //   } catch (e, stack) {
  //     _error = 'Could not connect to server. Check that the backend is running.';
  //     return false;
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }

  /// Returns 'success', 'requires2FA', or 'failure'
  Future<String> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    _twoStepEmail = null;
    notifyListeners();

    try {
      final result = await _api.login(email: email, password: password);
      
      if (result.requires2FA) {
        _twoStepEmail = result.email ?? email;
        return 'requires2FA';
      }

      _user = result.user;
      _accessToken = result.accessToken;
      return 'success';
    } on ApiException catch (e) {
      _error = e.message;
      return 'failure';
    } catch (e) {
      _error = 'Could not connect to server. Check that the backend is running.';
      return 'failure';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOtp(String otp) async {
    if (_twoStepEmail == null) {
      _error = 'Session expired. Please login again.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _api.verifyOtp(email: _twoStepEmail!, otp: otp);
      _user = result.user;
      _accessToken = result.accessToken;
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Verification failed. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resendOtp() async {
    if (_twoStepEmail == null) return false;

    try {
      await _api.resendOtp(email: _twoStepEmail!);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      return false;
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

  // ── Real-time Handlers ───────────────────────────────────────────────────

  List<dynamic> _myOrders = [];
  List<dynamic> get myOrders => _myOrders;

  void updateMyOrders(List<dynamic> orders) {
    _myOrders = orders;
    notifyListeners();
  }

  void onOrderCreated(dynamic order) {
    // If the order belongs to the current user, add it to their history
    if (_user != null && order['customer_id'] == _user!.id) {
      _myOrders.insert(0, order);
      notifyListeners();
    }
  }

  void onOrderStatusUpdated(dynamic order) {
    // Update the status in the local list if it's the user's order
    int index = _myOrders.indexWhere((o) => o['id'] == order['id']);
    if (index != -1) {
      _myOrders[index] = order;
      notifyListeners();
    }
  }
}
