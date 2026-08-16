import 'package:flutter/material.dart';
import '../../../data/services/hive_service.dart';
import '../screens/onboarding_screen.dart';

/// Ipinapakita ang onboarding sa unang buksan lamang.
class OnboardingGate extends StatefulWidget {
  final Widget child;

  const OnboardingGate({super.key, required this.child});

  @override
  State<OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends State<OnboardingGate> {
  late bool _hasSeen;

  @override
  void initState() {
    super.initState();
    _hasSeen = HiveService.hasSeen(HiveService.hasSeenOnboardingKey);
  }

  @override
  Widget build(BuildContext context) {
    if (_hasSeen) return widget.child;

    return OnboardingScreen(
      onFinished: () => setState(() => _hasSeen = true),
    );
  }
}
