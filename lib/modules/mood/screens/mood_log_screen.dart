import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/i18n/language_controller.dart';
import '../../../core/models/mood_type.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/hive_service.dart';
import '../widgets/daily_mood_selector.dart';

class MoodLogScreen extends StatefulWidget {
  const MoodLogScreen({super.key});

  @override
  State<MoodLogScreen> createState() => _MoodLogScreenState();
}

class _MoodLogScreenState extends State<MoodLogScreen> {
  late final DateTime _today;
  late final TextEditingController _noteController;
  MoodType? _selected;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    _selected = MoodType.fromName(HiveService.getMood(_today));
    _noteController = TextEditingController(
      text: HiveService.getMoodNote(_today) ?? '',
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final mood = _selected;
    if (mood == null) return;

    await HiveService.saveMood(_today, mood.name);
    await HiveService.saveMoodNote(_today, _noteController.text);

    if (!mounted) return;
    // Walang bituin sa pagtatala ng mood, kaya hindi bagay ang "+N" burst.
    unawaited(HapticFeedback.lightImpact());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          tr('Naitala: ${mood.label}', 'Logged: ${mood.label}'),
        ),
        backgroundColor: AppColors.logoGreen,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final child = HiveService.getChildProfile()?.displayName.trim();
    final hasName = child != null && child.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('Mood Ngayong Araw', 'Mood Today')),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Text(
            hasName
                ? tr(
                    'Kumusta ang pakiramdam ni $child ngayon?',
                    'How is $child feeling today?',
                  )
                : tr(
                    'Kumusta ang pakiramdam ng iyong anak ngayon?',
                    'How is your child feeling today?',
                  ),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            tr(
              'Pumili ng isa. Mababago mo ito anumang oras ngayong araw.',
              'Pick one. You can change it anytime today.',
            ),
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),

          DailyMoodSelector(
            selected: _selected,
            onSelected: (mood) => setState(() => _selected = mood),
          ),
          const SizedBox(height: 24),

          Text(
            tr('Karagdagang Tala (Opsyonal)', 'Extra Note (Optional)'),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _noteController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: tr(
                'Halimbawa: Maaga siyang nagising at maganda ang umaga.',
                'Example: Woke up early and had a good morning.',
              ),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _selected == null ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.logoGreen,
                disabledBackgroundColor: AppColors.divider,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
              ),
              child: Text(
                tr('I-tala ang Mood', 'Log the Mood'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _selected == null
                      ? AppColors.textMuted
                      : AppColors.surface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
