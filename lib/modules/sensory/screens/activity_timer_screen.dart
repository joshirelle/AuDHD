import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/star_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/hive_service.dart';
import '../../../widgets/star_burst_overlay.dart';
import '../models/sensory_activity.dart';

class ActivityTimerScreen extends StatefulWidget {
  final SensoryActivity activity;

  const ActivityTimerScreen({super.key, required this.activity});

  @override
  State<ActivityTimerScreen> createState() => _ActivityTimerScreenState();
}

class _ActivityTimerScreenState extends State<ActivityTimerScreen> {
  late Duration _total;
  late Duration _remaining;
  DateTime? _endsAt;
  Timer? _ticker;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _total = Duration(minutes: widget.activity.estimatedMinutes);
    _remaining = _total;
    // Pinindot na ang Simulan sa activity sheet; hindi na dapat pindutin ulit.
    _beginCountdown();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  bool get _isRunning => _ticker?.isActive ?? false;

  void _beginCountdown() {
    // Nakabatay sa dulong oras, hindi sa pagbabawas kada tick, para hindi lumihis.
    _endsAt = DateTime.now().add(_remaining);
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 200), (_) => _tick());
  }

  void _resume() => setState(_beginCountdown);

  void _pause() {
    _ticker?.cancel();
    setState(() => _endsAt = null);
  }

  void _tick() {
    final endsAt = _endsAt;
    if (endsAt == null) return;

    final left = endsAt.difference(DateTime.now());
    if (left <= Duration.zero) {
      _finish();
      return;
    }
    setState(() => _remaining = left);
  }

  Future<void> _finish() async {
    _ticker?.cancel();
    setState(() {
      _remaining = Duration.zero;
      _endsAt = null;
      _isFinished = true;
    });

    // Tunog lang ang hindi maaasahan sa Android, kaya may vibration din.
    unawaited(HapticFeedback.heavyImpact());
    unawaited(SystemSound.play(SystemSoundType.alert));

    await HiveService.setActivityCompleted(
      DateTime.now(),
      widget.activity.id,
      true,
    );

    if (!mounted) return;
    StarBurstOverlay.show(context, StarService.starsPerSensoryActivity);
  }

  String get _timeLabel {
    final minutes = _remaining.inMinutes.toString().padLeft(2, '0');
    final seconds = (_remaining.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oras ng Gawain'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.activity.titleTagalog,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  height: 1.3,
                  fontFamily: 'Nunito',
                ),
              ),
              const Spacer(),
              Center(child: _buildDial()),
              const SizedBox(height: 24),
              Text(
                _statusText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontFamily: 'Nunito',
                ),
              ),
              const Spacer(),
              _buildActions(),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  String get _statusText {
    if (_isFinished) return 'Tapos na! Nakakuha ng bituin si bata.';
    if (_isRunning) return 'Kasalukuyang ginagawa...';
    return 'Naka-pause';
  }

  Widget _buildDial() {
    final progress = _total.inSeconds == 0
        ? 0.0
        : _remaining.inSeconds / _total.inSeconds;

    return SizedBox(
      width: 250,
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: _isFinished ? 1 : progress,
              strokeWidth: 14,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                _isFinished ? AppColors.logoGreen : AppColors.starGold,
              ),
            ),
          ),
          if (_isFinished)
            const Icon(
              Icons.check_circle_rounded,
              size: 96,
              color: AppColors.logoGreen,
            )
          else
            Text(
              _timeLabel,
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
                fontFeatures: [FontFeature.tabularFigures()],
                fontFamily: 'Nunito',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    if (_isFinished) {
      return _buildPrimaryButton(
        label: 'Tapos na',
        color: AppColors.logoGreen,
        onPressed: () => Navigator.pop(context),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildPrimaryButton(
          label: _isRunning ? 'I-pause' : 'Ipagpatuloy',
          color: _isRunning ? AppColors.skyBlue : AppColors.logoGreen,
          textColor: _isRunning ? const Color(0xFF16537E) : Colors.white,
          onPressed: _isRunning ? _pause : _resume,
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: _finish,
          child: Text(
            'Tapusin na agad',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
              fontFamily: 'Nunito',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
    Color textColor = Colors.white,
  }) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: textColor,
            fontFamily: 'Nunito',
          ),
        ),
      ),
    );
  }
}
