// lib/ui/viewmodels/register_viewmodel.dart
import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthService authService;
  bool loading = false;
  String? error;

  RegisterViewModel({required this.authService});

  Future<bool> register(String username, String email, String password) async {
    loading = true; error = null; notifyListeners();
    final u = await authService.register(username, email, password);
    loading = false;
    if (u == null) {
      error = 'Gagal register (email mungkin sudah terpakai)';
      notifyListeners();
      return false;
    }
    return true;
  }
}
