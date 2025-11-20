// lib/ui/viewmodels/login_viewmodel.dart
import 'package:flutter/material.dart';
import '../../data/app_database.dart';
import '../../core/services/auth_service.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService authService;
  User? _user;
  bool loading = false;
  String? error;

  User? get user => _user;

  LoginViewModel({required this.authService});

  Future<bool> login(String email, String password) async {
    loading = true; error = null; notifyListeners();
    final u = await authService.login(email, password);
    loading = false;
    if (u == null) {
      error = 'Email atau password salah';
      notifyListeners();
      return false;
    }
    _user = u;
    notifyListeners();
    return true;
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}
