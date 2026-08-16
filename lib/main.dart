import 'package:flutter/material.dart';
import 'core/services/auth_service.dart';
import 'core/services/child_photo_service.dart';
import 'core/theme/app_theme.dart';
import 'data/services/hive_service.dart';
import 'modules/auth/widgets/auth_gate.dart';
import 'modules/home/home_screen.dart';
import 'modules/onboarding/widgets/onboarding_gate.dart';
import 'widgets/reward_watcher.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive Storage
  await HiveService.init();
  await AuthService.init();
  await ChildPhotoService.init();

  runApp(const AuDHDApp());
}

class AuDHDApp extends StatelessWidget {
  const AuDHDApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AuDHD',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      navigatorKey: RewardWatcher.navigatorKey,
      builder: (context, child) => RewardWatcher(child: child!),
      home: const AuthGate(
        child: OnboardingGate(child: HomeScreen()),
      ),
    );
  }
}