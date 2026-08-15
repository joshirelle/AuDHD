import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../screens/lock_screen.dart';

/// Hinaharangan ang app hangga't hindi naipapasok ang PIN, at muling nagsasara
/// kapag umalis ang app sa foreground.
class AuthGate extends StatefulWidget {
  final Widget child;

  const AuthGate({super.key, required this.child});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> with WidgetsBindingObserver {
  bool _isUnlocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _isUnlocked = !AuthService.isPinSet();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Walang saysay ang lock kung mananatiling bukas habang naka-background.
    final leftForeground =
        state == AppLifecycleState.paused || state == AppLifecycleState.hidden;

    if (leftForeground && AuthService.isPinSet() && _isUnlocked) {
      setState(() => _isUnlocked = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isUnlocked) return widget.child;

    return LockScreen(
      onUnlocked: () => setState(() => _isUnlocked = true),
    );
  }
}
