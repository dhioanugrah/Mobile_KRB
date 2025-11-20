import 'package:rimba_app/data/app_database.dart'; // pastikan path-nya sesuai

Future<void> main() async {
  final db = AppDatabase(); // inisialisasi database

  print('=== ISI TABEL USERS ===');
  final users = await db.select(db.users).get();

  if (users.isEmpty) {
    print('Belum ada data di tabel users.');
  } else {
    for (final u in users) {
      print('''
ID        : ${u.id}
Username  : ${u.username}
Email     : ${u.email}
Password  : ${u.password}
Role      : ${u.role}
CreatedAt : ${u.createdAt}
--------------------------
''');
    }
  }

  await db.close(); // pastikan ditutup setelah selesai
}
