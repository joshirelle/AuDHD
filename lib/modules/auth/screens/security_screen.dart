import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/kiko_card.dart';
import 'lock_screen.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final available = await AuthService.canCheckBiometrics();
    if (!mounted) return;
    setState(() => _biometricAvailable = available);
  }

  Future<bool> _runLockScreen({required bool isCreatingPin}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => LockScreen(
          isCreatingPin: isCreatingPin,
          onUnlocked: () => Navigator.pop(context, true),
        ),
      ),
    );
    return result == true;
  }

  Future<void> _setOrChangePin() async {
    // Kailangan munang mapatunayan ang dating PIN bago ito mapalitan.
    if (AuthService.isPinSet() && !await _runLockScreen(isCreatingPin: false)) {
      return;
    }
    if (!mounted) return;

    if (await _runLockScreen(isCreatingPin: true)) {
      if (!mounted) return;
      setState(() {});
      _notify('Naitakda na ang PIN.');
    }
  }

  Future<void> _removePin() async {
    if (!await _runLockScreen(isCreatingPin: false)) return;

    await AuthService.clearPin();
    if (!mounted) return;
    setState(() {});
    _notify('Inalis na ang PIN.');
  }

  void _notify(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.logoGreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPinSet = AuthService.isPinSet();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seguridad'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          KikoCard(
            backgroundColor: isPinSet
                ? AppColors.mintGreen
                : AppColors.butterYellow,
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isPinSet
                      ? Icons.lock_rounded
                      : Icons.lock_open_rounded,
                  color: isPinSet
                      ? AppColors.mintInk
                      : AppColors.butterInk,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isPinSet ? 'Naka-lock ang app' : 'Bukas ang app',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                          fontFamily: 'Nunito',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isPinSet
                            ? 'Hihingi ng PIN tuwing bubuksan o babalikan ang app.'
                            : 'Walang PIN. Sinumang makakuha ng telepono ay makakabasa ng datos ng bata.',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textDark,
                          height: 1.35,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.logoGreen,
              minimumSize: const Size.fromHeight(52),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
            ),
            onPressed: _setOrChangePin,
            icon: const Icon(Icons.pin_rounded, color: Colors.white),
            label: Text(
              isPinSet ? 'Palitan ang PIN' : 'Gumawa ng PIN',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Nunito',
              ),
            ),
          ),

          if (isPinSet) ...[
            const SizedBox(height: 16),
            SwitchListTile(
              value: AuthService.isBiometricEnabled(),
              onChanged: _biometricAvailable
                  ? (value) async {
                      await AuthService.setBiometricEnabled(value);
                      if (!mounted) return;
                      setState(() {});
                    }
                  : null,
              activeThumbColor: AppColors.logoGreen,
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Gamitin ang fingerprint o Face ID',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  fontFamily: 'Nunito',
                ),
              ),
              subtitle: Text(
                _biometricAvailable
                    ? 'Ang PIN pa rin ang pamalit kapag nabigo ito.'
                    : 'Walang naka-set up na biometrics sa device na ito.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontFamily: 'Nunito',
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: _removePin,
              icon: const Icon(
                Icons.lock_open_rounded,
                color: AppColors.danger,
              ),
              label: const Text(
                'Alisin ang PIN',
                style: TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Nunito',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
