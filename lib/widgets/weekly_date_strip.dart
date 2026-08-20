import 'package:flutter/material.dart';

import '../core/i18n/language_controller.dart';
import '../core/theme/app_theme.dart';

/// Limang araw na nakasentro sa ngayon, may bituin sa mga araw na may natapos.
///
/// Iba ang pinagmumulan ng bituin sa bawat screen — gawain sa bahay o iskedyul
/// — kaya ipinapasa ito imbes na nakakabit sa iisang box.
class WeeklyDateStrip extends StatelessWidget {
  const WeeklyDateStrip({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.progressSource,
    required this.hasProgress,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  /// Ang box na binabantayan para agad magbago ang bituin.
  final Listenable progressSource;

  final bool Function(DateTime date) hasProgress;

  /// Pantawag lang sa mata, hindi susi — walang naitatago na naka-index dito,
  /// kaya ligtas itong isalin. Getter para masundan ang piniling wika.
  static List<String> get _dayNames => [
    tr('Lun', 'Mon'),
    tr('Mar', 'Tue'),
    tr('Miy', 'Wed'),
    tr('Huw', 'Thu'),
    tr('Bye', 'Fri'),
    tr('Sab', 'Sat'),
    tr('Lin', 'Sun'),
  ];

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = List<DateTime>.generate(
      5,
      (index) => today.add(Duration(days: index - 2)),
    );

    return ListenableBuilder(
      listenable: progressSource,
      builder: (context, _) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final day in days)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: _buildDayTile(
                    day: day,
                    isToday: _isSameDay(day, today),
                    isSelected: _isSameDay(day, selectedDate),
                    hasStar: hasProgress(day),
                    isFuture: day.isAfter(today),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDayTile({
    required DateTime day,
    required bool isToday,
    required bool isSelected,
    required bool hasStar,
    required bool isFuture,
  }) {
    final Color background = isSelected
        ? AppColors.skyBlue
        : isToday
        ? AppColors.skyBlueLight
        : AppColors.surface;

    return InkWell(
      onTap: isFuture ? null : () => onDateSelected(day),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isToday ? AppColors.logoGreen : AppColors.divider,
            width: isToday ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _dayNames[day.weekday - 1],
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isFuture ? AppColors.textMuted : AppColors.textDark,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${day.day}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isFuture ? AppColors.textMuted : AppColors.textDark,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 4),
            // Laging may nakalaang puwang para hindi tumalon ang taas ng tile.
            SizedBox(
              height: 14,
              child: hasStar
                  ? const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: AppColors.starGoldDeep,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
