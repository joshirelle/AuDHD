import 'package:flutter/material.dart';
import '../../../core/i18n/language_controller.dart';
import '../../../core/models/schedule_task.dart';
import '../../../core/theme/app_theme.dart';

/// Pangkat ng icon sa picker.
///
/// Ang kulay ay sa pangkat at hindi sa bawat icon: dalawampung magkakaibang
/// kulay ay ingay, at ang dalawampung itim ay pader. Ang kulay dito ang
/// nagsasabi kung anong uri ito, kaya nahahanap ito nang hindi binabasa ang
/// bawat label.
enum ScheduleIconGroup {
  food(AppColors.butterInk),
  selfCare(AppColors.skyInk),
  learning(AppColors.mintInk),
  play(AppColors.coralInk),
  rest(AppColors.autismPurple);

  const ScheduleIconGroup(this.ink);

  /// Sapat ang kaibahan nito sa `surface` para sa mata ng magulang.
  final Color ink;

  String get label => switch (this) {
    ScheduleIconGroup.food => tr('Pagkain', 'Food'),
    ScheduleIconGroup.selfCare => tr('Sarili at Kalinisan', 'Self-care'),
    ScheduleIconGroup.learning => tr('Pag-aaral', 'Learning'),
    ScheduleIconGroup.play => tr('Laro at Galaw', 'Play and Movement'),
    ScheduleIconGroup.rest => tr('Pahinga', 'Rest'),
  };
}

/// Nakatalang `const IconData` na naka-index sa pangalan.
///
/// Ang `--tree-shake-icons` (naka-on sa release build) ay nag-aalis ng mga icon
/// na walang const na sanggunian sa code. Kaya hindi puwedeng i-save ang
/// `codePoint` sa Hive at buuin muli ang `IconData` — gagana iyon sa debug at
/// mababakante sa release. Susi ang iniimbak, ang icon ay nananatiling const.
class ScheduleIcons {
  static const IconData fallback = Icons.check_circle_rounded;

  /// Ang unang icon ng bagong gawain. Nakasulat at hindi kinukuha sa unang
  /// susi ng `all`: mababago ang pagkakasunod, at hindi dapat sumabay dito
  /// ang default.
  static const String defaultKey = 'breakfast';

  static const Map<String, IconData> all = {
    'breakfast': Icons.free_breakfast_rounded,
    'toothbrush': Icons.brush_rounded,
    'school': Icons.school_rounded,
    'lunch': Icons.ramen_dining_rounded,
    'toy': Icons.smart_toy_rounded,
    'pencil': Icons.edit_rounded,
    'run': Icons.directions_run_rounded,
    'dinner': Icons.dinner_dining_rounded,
    'bath': Icons.bathtub_rounded,
    'sleep': Icons.bedtime_rounded,
    'drink': Icons.local_drink_rounded,
    'book': Icons.menu_book_rounded,
    'music': Icons.music_note_rounded,
    'pets': Icons.pets_rounded,
    'clean': Icons.cleaning_services_rounded,
    'clothes': Icons.checkroom_rounded,
    'medicine': Icons.medication_rounded,
    'walk': Icons.directions_walk_rounded,
    'game': Icons.sports_esports_rounded,
    'hug': Icons.favorite_rounded,
  };

  /// Ang pagkakahati sa picker. Bawat susi sa `all` ay minsan lang dapat
  /// lumitaw dito — may test na nagbabantay nito.
  static const Map<ScheduleIconGroup, List<String>> grouped = {
    ScheduleIconGroup.food: ['breakfast', 'lunch', 'dinner', 'drink'],
    ScheduleIconGroup.selfCare: [
      'toothbrush',
      'bath',
      'clothes',
      'medicine',
      'clean',
    ],
    ScheduleIconGroup.learning: ['school', 'pencil', 'book'],
    ScheduleIconGroup.play: ['toy', 'run', 'walk', 'game', 'music', 'pets'],
    ScheduleIconGroup.rest: ['sleep', 'hug'],
  };

  static IconData of(String key) => all[key] ?? fallback;

  /// Kulay ng icon sa picker. `textDark` kapag walang pangkat — hindi dapat
  /// maglaho ang bagong icon na nakalimutang isama sa `grouped`.
  static Color inkOf(String key) {
    for (final entry in grouped.entries) {
      if (entry.value.contains(key)) return entry.key.ink;
    }
    return AppColors.textDark;
  }

  static List<String> get pickerKeys => all.keys.toList();
}

/// Kulay at icon kada bahagi ng araw — hiwalay sa model para manatiling
/// walang kaalaman ang `ScheduleTask` sa Flutter, gaya ng `ActivityTargetStyle`.
class ScheduleTimeStyle {
  final IconData icon;
  final Color accent;
  final Color fill;

  const ScheduleTimeStyle({
    required this.icon,
    required this.accent,
    required this.fill,
  });

  static const Map<ScheduleTimeOfDay, ScheduleTimeStyle> _styles = {
    ScheduleTimeOfDay.morning: ScheduleTimeStyle(
      icon: Icons.wb_sunny_rounded,
      accent: AppColors.starGold,
      fill: AppColors.butterYellow,
    ),
    ScheduleTimeOfDay.afternoon: ScheduleTimeStyle(
      icon: Icons.wb_cloudy_rounded,
      accent: AppColors.adhdBlue,
      fill: AppColors.skyBlueLight,
    ),
    ScheduleTimeOfDay.evening: ScheduleTimeStyle(
      icon: Icons.bedtime_rounded,
      accent: AppColors.autismPurple,
      fill: AppColors.lavender,
    ),
  };

  static ScheduleTimeStyle of(ScheduleTimeOfDay time) => _styles[time]!;
}
