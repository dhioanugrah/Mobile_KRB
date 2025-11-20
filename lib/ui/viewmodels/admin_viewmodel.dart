// lib/ui/viewmodels/admin_viewmodel.dart
import 'package:flutter/material.dart';
import '../../data/app_database.dart';
import 'package:drift/drift.dart';

class AdminViewModel extends ChangeNotifier {
  final AppDatabase db;
  List<Category> categories = [];
  Map<int, List<FloraTableData>> floraByCategory = {};

  AdminViewModel({required this.db});

  Future<void> loadCategories() async {
    categories = await db.getAllCategories();
    notifyListeners();
  }

  Future<void> addCategory(String name) async {
    await db.insertCategory(CategoriesCompanion.insert(name: name));
    await loadCategories();
  }

  Future<void> deleteCategory(int id) async {
    await db.deleteCategoryById(id);
    await loadCategories();
  }

  Future<void> loadFloraFor(int categoryId) async {
    floraByCategory[categoryId] = await db.getFloraByCategory(categoryId);
    notifyListeners();
  }

  Future<void> addFlora({required int categoryId, required String name, String? desc, String? imageUrl}) async {
    await db.insertFlora(FloraTableCompanion.insert(
      name: name,
      description: Value(desc),
      imageUrl: Value(imageUrl),
      categoryId: categoryId,
    ));
    await loadFloraFor(categoryId);
  }

  Future<void> deleteFlora(int categoryId, int floraId) async {
    await db.deleteFloraById(floraId);
    await loadFloraFor(categoryId);
  }
}
