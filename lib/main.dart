import 'package:flutter/material.dart';
import 'core/i18n/language_controller.dart';
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

class AuDHDApp extends StatefulWidget {
  const AuDHDApp({super.key});

  @override
  State<AuDHDApp> createState() => _AuDHDAppState();
}

class _AuDHDAppState extends State<AuDHDApp> {
  @override
  void initState() {
    super.initState();
    LanguageController.notifier.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    LanguageController.notifier.removeListener(_onLanguageChanged);
    super.dispose();
  }

  /// Hindi dumadaan sa `context` ang `tr()`, at iniimbak ng `Navigator` ang
  /// mga naitayong ruta — kaya hindi sapat ang `setState`. Minamarkahan ang
  /// buong puno para tiyak na muling iguguhit ang lahat nang hindi nawawala
  /// ang pinagkakatayuan at ang naka-unlock na estado.
  void _onLanguageChanged() {
    setState(() {});

    void markDirty(Element element) {
      element.markNeedsBuild();
      element.visitChildren(markDirty);
    }

    (context as Element).visitChildren(markDirty);
  }

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