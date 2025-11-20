import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:rimba_app/data/app_database.dart';

class CategoriesViewModel extends ChangeNotifier {
  final AppDatabase db;

  CategoriesViewModel(this.db);

  Future<List<Category>> get categories => db.getAllCategories();

  Future<void> addCategory(String name) async {
    final c = CategoriesCompanion.insert(name: name);
    await db.insertCategory(c);
    notifyListeners();
  }

  Future<void> updateCategory(int id, String name) async {
    final c = CategoriesCompanion(
      id: Value(id),
      name: Value(name),
    );
    await db.updateCategoryData(c);
    notifyListeners();
  }

  Future<void> deleteCategory(int id) async {
    await db.deleteCategoryById(id);
    notifyListeners();
  }
}
