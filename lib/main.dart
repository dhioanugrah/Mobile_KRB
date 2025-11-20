import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rimba_app/core/router/app_router.dart';
import 'package:rimba_app/core/services/auth_service.dart';
import 'package:rimba_app/data/app_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = await AppDatabase.create();
  
  final authService = AuthService(db);
  final router = AppRouter(authService, db);
  
  runApp(MyApp(authService: authService, router: router, db: db)); // <--- kirim db juga
}


class MyApp extends StatelessWidget {
  final AuthService authService;
  final AppRouter router;
  final AppDatabase db; // tambahkan db

  const MyApp({super.key, required this.authService, required this.router, required this.db}); // tambahkan db

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: db), // <--- ini penting
        ChangeNotifierProvider.value(value: authService),
      ],
      child: MaterialApp.router(
        title: 'Rimba App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        routerConfig: router.router,
      ),
    );
  }
}

