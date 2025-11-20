// lib/core/services/auth_service.dart
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import '../../data/app_database.dart';

class AuthService extends ChangeNotifier {
  final AppDatabase db;
  User? _currentUser;

  AuthService(this.db);
  
  // Expose database untuk digunakan di ViewModel
  AppDatabase get database => db;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<User?> login(String email, String password) async {
    final user = await db.getUserByEmail(email);
    if (user == null) return null;
    
    // NOTE: plaintext check for demo. Ganti dengan hash check di production.
    if (user.password == password) {
      _currentUser = user;
      notifyListeners();
      return user;
    }
    return null;
  }

  Future<User?> register(String username, String email, String password, {String role = 'user'}) async {
    // check existing
    final exists = await db.getUserByEmail(email);
    if (exists != null) return null;
    
    final id = await db.insertUser(UsersCompanion.insert(
      username: username,
      email: email,
      password: password,
      role: Value(role),
    ));
    
    final user = await (db.select(db.users)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (user != null) {
      _currentUser = user;
      notifyListeners();
    }
    return user;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}