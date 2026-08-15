import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/hive_service.dart';

/// Limang araw na nakasentro sa ngayon, may bituin sa mga araw na may natapos.
class WeeklyDateStripWidget extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const WeeklyDateStripWidget({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  static const List<String> _dayNames = [
    'Lun',
    'Mar',
    'Miy',
    'Huw',
    'Bye',
    'Sab',
    'Lin',
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

    return ValueListenableBuilder<Box<bool>>(
      valueListenable: HiveService.getCompletionBox().listenable(),
      builder: (context, box, child) {
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
                    hasStar: HiveService.hasAnyCompletionOn(day),
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
            : Colors.white;

    return InkWell(
      onTap: isFuture ? null : () => onDateSelected(day),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isToday ? AppColors.logoGreen : Colors.grey.shade200,
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
                color: isFuture ? Colors.grey.shade400 : AppColors.textDark,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${day.day}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isFuture ? Colors.grey.shade400 : AppColors.textDark,
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
                      color: Color(0xFFF2B705),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
