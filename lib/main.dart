import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'data/services/hive_service.dart';
import 'modules/home/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive Storage
  await HiveService.init();

  runApp(const AuDHDApp());
}

class AuDHDApp extends StatelessWidget {
  const AuDHDApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AuDHD',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Nunito',
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}