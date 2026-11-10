import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();
  bool loading = false;
  String? error;

  AuthService get service => _service;

  Future<bool> register(String name, String email, String password) async {
    loading = true; error = null; notifyListeners();
    try {
      await _service.register(name, email, password);
      loading = false; notifyListeners();
      return true;
    } catch (e) {
      error = e.toString(); loading = false; notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    loading = true; error = null; notifyListeners();
    try {
      await _service.login(email, password);
      loading = false; notifyListeners();
      return true;
    } catch (e) {
      error = e.toString(); loading = false; notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _service.logout();
    notifyListeners();
  }
}
