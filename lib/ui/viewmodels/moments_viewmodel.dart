import 'package:flutter/foundation.dart';
import 'package:rimba_app/data/app_database.dart';
import 'package:drift/drift.dart' show Value;

class MomentsViewModel extends ChangeNotifier {
  final AppDatabase db;

  MomentsViewModel(this.db);

  bool isLoading = false;
  String? errorMessage;
  List<Moment> moments = [];

  Future<void> loadMoments() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      moments = await db.getAllMoments();

      // optional: urutkan terbaru dulu
      moments.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> addMoment({
    required String tempat,
    required String deskripsi,
  }) async {
    try {
      final momentCompanion = MomentsCompanion.insert(
        tempat: tempat,
        deskripsi: Value(deskripsi),
        photoUrl: const Value(null),    // kita abaikan kolom ini
        updatedAt: const Value(null),
      );

      await db.insertMoment(momentCompanion);
      await loadMoments();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteMoment(int id) async {
    await db.deleteMomentById(id);
    await loadMoments();
  }
}
