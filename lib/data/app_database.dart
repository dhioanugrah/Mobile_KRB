// lib/data/app_database.dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:meta/meta.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
part 'app_database.g.dart';

// --- Tables ---
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get username => text()();
  TextColumn get email => text().unique()();
  TextColumn get password => text()(); // NOTE: plaintext for demo; hash in prod
  TextColumn get role =>
      text().withDefault(const Constant('user'))(); // 'admin' or 'user'
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}

class FloraTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get imageUrl => text().nullable()(); // path or url
  IntColumn get categoryId => integer().references(Categories, #id)();
}

class Moments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tempat => text()();
  TextColumn get deskripsi => text().nullable()();
  // photoUrl DIHAPUS
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}

class FoundFlora extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get floraId => integer().references(FloraTable, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
// --- Database ---

@DriftDatabase(tables: [Users, Categories, FloraTable, Moments, FoundFlora])
class AppDatabase extends _$AppDatabase {
  AppDatabase._(super.e);

  static AppDatabase? _instance;
  factory AppDatabase() => throw UnimplementedError('Use create()');

  static Future<AppDatabase> create() async {
    if (_instance != null) return _instance!;
    final executor = _openConnection();
    final db = AppDatabase._(executor);
    _instance = db;
    await _seedIfNeeded(db);
    return _instance!;
  }

  @visibleForTesting
  static AppDatabase createInMemory() {
    final executor = NativeDatabase.memory();
    return AppDatabase._(executor);
  }

  @override
  int get schemaVersion => 1;

  // === Users CRUD ===
  Future<int> insertUser(UsersCompanion u) => into(users).insert(u);
  Future<User?> getUserByEmail(String email) =>
      (select(users)..where((t) => t.email.equals(email))).getSingleOrNull();
  Future<List<User>> getAllUsers() => select(users).get();
  Future<int> updateUserRole(int userId, String role) =>
      (update(users)..where((t) => t.id.equals(userId))).write(
        UsersCompanion(role: Value(role)),
      );
  Future<int> deleteUserById(int id) =>
      (delete(users)..where((t) => t.id.equals(id))).go();

  // === Categories ===
  Future<int> insertCategory(CategoriesCompanion c) =>
      into(categories).insert(c);

  Future<List<Category>> getAllCategories() => select(categories).get();

  Future<bool> updateCategoryData(CategoriesCompanion c) =>
      update(categories).replace(c);

  Future<int> deleteCategoryById(int id) =>
      (delete(categories)..where((t) => t.id.equals(id))).go();

  // === Flora ===
  Future<int> insertFlora(FloraTableCompanion f) => into(floraTable).insert(f);

  Future<List<FloraTableData>> getAllFlora() => select(floraTable).get();

  Future<FloraTableData?> getFloraById(int id) =>
      (select(floraTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<FloraTableData>> getFloraByCategory(int categoryId) =>
      (select(floraTable)..where((t) => t.categoryId.equals(categoryId))).get();

  Future<bool> updateFloraData(FloraTableCompanion f) =>
      update(floraTable).replace(f);

  Future<int> deleteFloraById(int id) =>
      (delete(floraTable)..where((t) => t.id.equals(id))).go();

  Stream<List<FloraTableData>> watchFloraByCategory(int categoryId) =>
      (select(floraTable)..where((t) => t.categoryId.equals(categoryId)))
          .watch();

// === Found Flora ===
  Future<int> addFoundFlora(int floraId) async {
    final entry = FoundFloraCompanion(
      floraId: Value(floraId),
    );
    return into(foundFlora).insert(entry);
  }

  Future<int> removeFoundFlora(int floraId) =>
      (delete(foundFlora)..where((t) => t.floraId.equals(floraId))).go();

  Future<List<FoundFloraData>> getAllFoundFlora() => select(foundFlora).get();

  Stream<List<FloraTableData>> watchFoundFlora() {
    final query = select(floraTable).join([
      innerJoin(
          this.foundFlora, this.foundFlora.floraId.equalsExp(floraTable.id)),
    ]);

    return query
        .watch()
        .map((rows) => rows.map((r) => r.readTable(floraTable)).toList());
  }

  Future<bool> isFloraFound(int floraId) async {
    final result = await (select(this.foundFlora)
          ..where((t) => t.floraId.equals(floraId)))
        .getSingleOrNull();
    return result != null;
  }

  // === Moments ===
  Future<int> insertMoment(MomentsCompanion m) => into(moments).insert(m);
  Future<List<Moment>> getAllMoments() => select(moments).get();
  Future<Moment?> getMomentById(int id) =>
      (select(moments)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<bool> updateMomentData(MomentsCompanion m) =>
      update(moments).replace(m);
  Future<int> deleteMomentById(int id) =>
      (delete(moments)..where((t) => t.id.equals(id))).go();
}

// Helper: open connection
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'rimba_app.sqlite'));
    return NativeDatabase(file);
  });
}

// Seed admin user + sample categories/flora if DB empty
Future<void> _seedIfNeeded(AppDatabase db) async {
  final usersCount = await db.select(db.users).get();
  if (usersCount.isEmpty) {
    await db.into(db.users).insert(
          UsersCompanion.insert(
            username: 'admin',
            email: 'admin@rimba.com',
            password: 'admin123',
            role: Value('admin'),
          ),
        );
  }
}
