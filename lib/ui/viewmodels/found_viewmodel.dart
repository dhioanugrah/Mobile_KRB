import 'package:flutter/foundation.dart';
import 'package:rimba_app/data/app_database.dart';

class FoundViewModel extends ChangeNotifier {
  final AppDatabase db;

  bool isLoading = false;
  List<FloraTableData> foundList = [];

  FoundViewModel(this.db) {
    loadFound();
  }

  void loadFound() {
    isLoading = true;
    notifyListeners();

    db.watchFoundFlora().listen((data) {
      foundList = data;
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> add(int floraId) async {
    await db.addFoundFlora(floraId);
  }

  Future<void> remove(int floraId) async {
    await db.removeFoundFlora(floraId);
  }

  Future<bool> check(int floraId) async {
    return db.isFloraFound(floraId);
  }
}
