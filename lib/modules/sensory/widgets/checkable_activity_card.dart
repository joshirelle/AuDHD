import 'package:flutter/material.dart';
import '../../../core/services/star_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/hive_service.dart';
import '../../../widgets/kiko_card.dart';
import '../../../widgets/star_burst_overlay.dart';
import '../models/sensory_activity.dart';
import 'activity_detail_sheet.dart';
import 'activity_target_style.dart';

class CheckableActivityCard extends StatelessWidget {
  final SensoryActivity activity;
  final DateTime date;
  final bool isCompleted;
  final VoidCallback onToggled;

  const CheckableActivityCard({
    super.key,
    required this.activity,
    required this.date,
    required this.isCompleted,
    required this.onToggled,
  });

  static const Color _completedTint = AppColors.tintSuccess;
  static const Color _completedGreen = AppColors.logoGreen;

  static const Map<String, IconData> _domainIcons = {
    'proprioceptive': Icons.fitness_center_rounded,
    'vestibular': Icons.rotate_right_rounded,
    'tactile': Icons.back_hand_rounded,
    'visual': Icons.visibility_rounded,
    'auditory': Icons.hearing_rounded,
  };

  static const Map<String, Color> _domainColors = {
    'proprioceptive': AppColors.mintGreen,
    'vestibular': AppColors.skyBlue,
    'tactile': AppColors.butterYellow,
    'visual': AppColors.skyBlueLight,
    'auditory': AppColors.coralPeach,
  };

  Future<void> _toggle(BuildContext tapContext) async {
    await HiveService.setActivityCompleted(date, activity.id, !isCompleted);
    if (!isCompleted && tapContext.mounted) {
      // Pabuya lang sa pagtapos; walang animation kapag inaalis ang tsek.
      StarBurstOverlay.show(tapContext, StarService.starsPerSensoryActivity);
    }
    onToggled();
  }

  @override
  Widget build(BuildContext context) {
    final domainColor = _domainColors[activity.domain] ?? AppColors.skyBlueLight;

    return KikoCard(
      backgroundColor: isCompleted ? _completedTint : Colors.white,
      borderColor: isCompleted ? _completedGreen : Colors.grey.shade200,
      padding: const EdgeInsets.all(14),
      onTap: () => ActivityDetailSheet.show(context, activity),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildCheckbox(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.titleTagalog,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    fontFamily: 'Nunito',
                    decoration: isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 6),
                ActivityTargetStyle.badge(activity.target),
                const SizedBox(height: 6),
                Text(
                  '${activity.estimatedMinutes} mins - ${activity.domainLabel}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textDark,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: domainColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _domainIcons[activity.domain] ?? Icons.auto_awesome_rounded,
              size: 20,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox() {
    return Semantics(
      checked: isCompleted,
      label: activity.titleTagalog,
      // Sariling context para tumapat ang burst sa mismong checkbox.
      child: Builder(
        builder: (context) => InkWell(
          onTap: () => _toggle(context),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted ? _completedGreen : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isCompleted ? _completedGreen : Colors.grey.shade400,
                width: 2,
              ),
            ),
            child: isCompleted
                ? const Icon(Icons.check_rounded, size: 20, color: Colors.white)
                : null,
          ),
        ),
      ),
    );
  }
}
