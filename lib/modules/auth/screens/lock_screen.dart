import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_theme.dart';

class LockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;
  final bool isCreatingPin;

  const LockScreen({
    super.key,
    required this.onUnlocked,
    this.isCreatingPin = false,
  });

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String _enteredPin = '';
  String _firstPin = '';
  bool _isConfirming = false;
  bool _isChecking = false;
  String _errorMessage = '';
  Duration? _cooldownLeft;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    if (!widget.isCreatingPin) {
      _refreshCooldown();
      _triggerBiometrics();
    }
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshCooldown() async {
    final left = await AuthService.remainingCooldown();
    if (!mounted) return;
    setState(() => _cooldownLeft = left);

    _cooldownTimer?.cancel();
    if (left == null) return;

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final remaining = await AuthService.remainingCooldown();
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _cooldownLeft = remaining);
      if (remaining == null) {
        timer.cancel();
        setState(() => _errorMessage = '');
      }
    });
  }

  Future<void> _triggerBiometrics() async {
    if (_cooldownLeft != null) return;
    final success = await AuthService.authenticateWithBiometrics();
    if (success && mounted) widget.onUnlocked();
  }

  void _onKeyPress(String value) {
    if (_isChecking || _cooldownLeft != null) return;
    if (_enteredPin.length >= AuthService.pinLength) return;

    setState(() {
      _enteredPin += value;
      _errorMessage = '';
    });

    if (_enteredPin.length == AuthService.pinLength) {
      _handlePinComplete();
    }
  }

  void _onBackspace() {
    if (_enteredPin.isEmpty || _isChecking) return;
    setState(() {
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      _errorMessage = '';
    });
  }

  Future<void> _handlePinComplete() async {
    setState(() => _isChecking = true);

    if (widget.isCreatingPin) {
      await _handleCreateFlow();
    } else {
      await _handleUnlockFlow();
    }

    if (mounted) setState(() => _isChecking = false);
  }

  Future<void> _handleCreateFlow() async {
    if (!_isConfirming) {
      setState(() {
        _firstPin = _enteredPin;
        _enteredPin = '';
        _isConfirming = true;
      });
      return;
    }

    if (_enteredPin != _firstPin) {
      setState(() {
        _errorMessage = 'Hindi magkatugma ang PIN. Ulitin muli.';
        _enteredPin = '';
        _firstPin = '';
        _isConfirming = false;
      });
      return;
    }

    await AuthService.setPin(_enteredPin);
    if (mounted) widget.onUnlocked();
  }

  Future<void> _handleUnlockFlow() async {
    final isCorrect = await AuthService.verifyPin(_enteredPin);
    if (!mounted) return;

    if (isCorrect) {
      widget.onUnlocked();
      return;
    }

    setState(() {
      _enteredPin = '';
      _errorMessage = 'Maling PIN. Subukang muli.';
    });
    await _refreshCooldown();
  }

  String get _title {
    if (!widget.isCreatingPin) return 'Ipasok ang PIN';
    return _isConfirming ? 'I-confirm ang Bagong PIN' : 'Gumawa ng 4-Digit PIN';
  }

  @override
  Widget build(BuildContext context) {
    final cooldown = _cooldownLeft;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Center(child: _buildPrompt(cooldown)),
              const Spacer(),
              _buildKeypad(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrompt(Duration? cooldown) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.logoGreen.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.lock_outline_rounded,
            size: 40,
            color: AppColors.logoGreen,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
            fontFamily: 'Nunito',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Upang mapanatiling ligtas ang datos ng bata',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontFamily: 'Nunito',
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(AuthService.pinLength, (index) {
            final isFilled = index < _enteredPin.length;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isFilled ? AppColors.logoGreen : Colors.grey.shade300,
              ),
            );
          }),
        ),
        if (cooldown != null) ...[
          const SizedBox(height: 16),
          Text(
            'Masyadong maraming maling subok. Maghintay ng ${cooldown.inSeconds + 1}s.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.danger,
              fontWeight: FontWeight.bold,
              fontFamily: 'Nunito',
            ),
          ),
        ] else if (_errorMessage.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.danger,
              fontWeight: FontWeight.bold,
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildKeypad() {
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
    ];

    return Column(
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map(_buildKeyButton).toList(),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: 64,
              child: widget.isCreatingPin
                  ? null
                  : IconButton(
                      iconSize: 32,
                      icon: const Icon(
                        Icons.fingerprint,
                        color: AppColors.logoGreen,
                      ),
                      onPressed: _triggerBiometrics,
                    ),
            ),
            _buildKeyButton('0'),
            SizedBox(
              width: 64,
              child: IconButton(
                iconSize: 28,
                icon: const Icon(
                  Icons.backspace_outlined,
                  color: Colors.grey,
                ),
                onPressed: _onBackspace,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKeyButton(String number) {
    final isDisabled = _cooldownLeft != null || _isChecking;

    return InkWell(
      onTap: isDisabled ? null : () => _onKeyPress(number),
      borderRadius: BorderRadius.circular(32),
      child: Container(
        width: 64,
        height: 64,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDisabled ? Colors.grey.shade100 : Colors.white,
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Text(
          number,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDisabled ? Colors.grey.shade400 : AppColors.textDark,
            fontFamily: 'Nunito',
          ),
        ),
      ),
    );
  }
}
