import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:rimba_app/data/app_database.dart';

class UsersViewModel extends ChangeNotifier {
  final AppDatabase db;

  UsersViewModel(this.db);

  List<User> _users = [];
  bool _isLoading = false;
  String? errorMessage;

  List<User> get users => _users;
  bool get isLoading => _isLoading;

  Future<void> loadUsers() async {
    _isLoading = true;
    notifyListeners();
    await _refreshUsers();
    _isLoading = false;
    notifyListeners();
  }

  Future<String?> addUser({
    required String username,
    required String email,
    required String password,
    String role = 'user',
  }) async {
    try {
      await db.insertUser(
        UsersCompanion.insert(
          username: username,
          email: email,
          password: password,
          role: Value(role),
        ),
      );
      await _refreshUsers();
      notifyListeners();
      return null;
    } catch (error) {
      final message = error.toString().toLowerCase();
      if (message.contains('unique')) {
        return 'Email sudah terdaftar.';
      }
      return 'Terjadi kesalahan saat menambah pengguna.';
    }
  }

  Future<String?> deleteUser(int userId) async {
    try {
      await db.deleteUserById(userId);
      await _refreshUsers();
      notifyListeners();
      return null;
    } catch (_) {
      return 'Gagal menghapus pengguna.';
    }
  }

  Future<String?> updateRole(int userId, String role) async {
    try {
      await db.updateUserRole(userId, role);
      await _refreshUsers();
      notifyListeners();
      return null;
    } catch (_) {
      return 'Gagal memperbarui peran pengguna.';
    }
  }

  Future<void> _refreshUsers() async {
    try {
      errorMessage = null;
      _users = await db.getAllUsers();
    } catch (_) {
      errorMessage = 'Tidak dapat memuat data pengguna.';
      _users = [];
    }
  }
}
