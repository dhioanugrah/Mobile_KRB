import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:rimba_app/data/app_database.dart';

class FloraViewModel extends ChangeNotifier {
  final AppDatabase db;
  final ImagePicker _picker = ImagePicker();

  FloraViewModel(this.db);

  int? selectedCategoryId;

  void setCategory(int? categoryId) {
    selectedCategoryId = categoryId;
    notifyListeners();
  }

  Stream<List<FloraTableData>> get floraStream {
    if (selectedCategoryId == null) return Stream.value([]);
    return db.watchFloraByCategory(selectedCategoryId!);
  }

  Future<List<Category>> get categories => db.getAllCategories();

  Future<void> addFlora({
    required String name,
    String? description,
    XFile? imageFile,
  }) async {
    if (selectedCategoryId == null) return;
    String? imagePath;
    if (imageFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = p.basename(imageFile.path);
      final savedFile = await File(imageFile.path).copy('${appDir.path}/$fileName');
      imagePath = savedFile.path;
    }

    final f = FloraTableCompanion.insert(
      name: name,
      description: description == null ? const Value.absent() : Value(description),
      imageUrl: imagePath == null ? const Value.absent() : Value(imagePath),
      categoryId: selectedCategoryId!,
    );

    await db.insertFlora(f);
  }

  Future<void> updateFlora(FloraTableData flora, {
    required String name,
    String? description,
    XFile? imageFile,
  }) async {
    String? imagePath = flora.imageUrl;
    if (imageFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = p.basename(imageFile.path);
      final savedFile = await File(imageFile.path).copy('${appDir.path}/$fileName');
      imagePath = savedFile.path;
    }

    final f = FloraTableCompanion(
      name: Value(name),
      description: description == null ? const Value.absent() : Value(description),
      imageUrl: imagePath == null ? const Value.absent() : Value(imagePath),
      categoryId: Value(selectedCategoryId!),
    );

    await db.updateFloraData(f.copyWith(id: Value(flora.id)));
  }

  Future<void> deleteFlora(int floraId) async {
    await db.deleteFloraById(floraId);
  }

  Future<XFile?> pickImage() async {
    return await _picker.pickImage(source: ImageSource.gallery);
  }
}
