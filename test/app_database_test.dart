import 'package:flutter_test/flutter_test.dart';
import 'package:rimba_app/data/app_database.dart';
import 'package:drift/drift.dart' hide isNotNull;

void main() {
  late AppDatabase db;

  setUp(() {
    // Dipanggil sebelum setiap test → selalu mulai dari DB kosong
    db = AppDatabase.createInMemory();
  });

  tearDown(() async {
    // Dipanggil setelah setiap test → nutup DB
    await db.close();
  });

  test('insertUser dan getUserByEmail harus mengembalikan user yang sama',
      () async {
    const email = 'tester@rimba.com';
    const username = 'tester';
    const password = 'rahasia';

    final userCompanion = UsersCompanion.insert(
      username: username,
      email: email,
      password: password,
      // role tidak diisi → pakai default 'user'
    );

    final id = await db.insertUser(userCompanion);
    final user = await db.getUserByEmail(email);

    expect(user, isNotNull);
    expect(user!.id, id);
    expect(user.username, username);
    expect(user.email, email);
    expect(user.password, password);
  });

  test('insertUser tanpa role harus memiliki role default user', () async {
    final userCompanion = UsersCompanion.insert(
      username: 'no_role',
      email: 'no_role@rimba.com',
      password: '123456',
    );

    await db.insertUser(userCompanion);
    final user = await db.getUserByEmail('no_role@rimba.com');

    expect(user, isNotNull);
    expect(user!.role, 'user'); // sesuai default di tabel Users
  });

  test(
      'insertCategory dan getAllCategories harus berisi kategori yang dimasukkan',
      () async {
    final catCompanion = CategoriesCompanion.insert(
      name: 'Endemik Langka',
    );

    final id = await db.insertCategory(catCompanion);
    final all = await db.getAllCategories();

    expect(all.length, 1);
    expect(all.first.id, id);
    expect(all.first.name, 'Endemik Langka');
  });

  test('insertMoment harus menambah data di getAllMoments', () async {
    final momentCompanion = MomentsCompanion.insert(
      tempat: 'Titik 0 Kebun Raya',
      deskripsi: const Value('Melihat flora langka'),
      updatedAt: const Value(null),
    );

    await db.insertMoment(momentCompanion);
    final moments = await db.getAllMoments();

    expect(moments.length, 1);
    expect(moments.first.tempat, 'Titik 0 Kebun Raya');
    expect(moments.first.deskripsi, 'Melihat flora langka');
  });

  test('addFoundFlora setelah insert flora harus membuat isFloraFound true',
      () async {
    // 1. Insert category dulu, karena flora butuh categoryId
    final catId = await db.insertCategory(
      CategoriesCompanion.insert(name: 'Kategori Uji'),
    );

    // 2. Insert flora
    final floraCompanion = FloraTableCompanion.insert(
      name: 'Flora Uji',
      description: const Value('Deskripsi uji'),
      imageUrl: const Value(null),
      categoryId: catId,
    );

    final floraId = await db.insertFlora(floraCompanion);

    // 3. Pastikan awalnya belum ditemukan
    final before = await db.isFloraFound(floraId);
    expect(before, isFalse);

    // 4. Tambah ke found flora
    await db.addFoundFlora(floraId);

    // 5. Sekarang harus true
    final after = await db.isFloraFound(floraId);
    expect(after, isTrue);
  });
}
