import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  Future<void> loadToken() async {
    _isLoading = true;
    notifyListeners();

    _token = await StorageService.getToken();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(String token, String refreshToken) async {
    _token = token;
    await StorageService.saveToken(token);
    await StorageService.saveRefreshToken(refreshToken);
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    await StorageService.clearTokens();
    notifyListeners();
  }

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }
}
