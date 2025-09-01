import 'package:flutter/material.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;

  final ApiService _apiService = ApiService();

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _apiService.getToken();
      _isAuthenticated = token != null;
    } catch (e) {
      _isAuthenticated = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.login(username, password);
      _user = User.fromJson(response['user']);
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> register(String email, String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _apiService.register(email, username, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    await _apiService.logout();
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
