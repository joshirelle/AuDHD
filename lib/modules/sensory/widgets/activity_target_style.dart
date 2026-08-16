import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/sensory_activity.dart';

/// Iisang kulay at icon para sa filter chips at sa badge ng card.
class ActivityTargetStyle {
  final IconData icon;
  final Color color;

  const ActivityTargetStyle({required this.icon, required this.color});

  static const Map<ActivityTarget, ActivityTargetStyle> _styles = {
    ActivityTarget.autismSensory: ActivityTargetStyle(
      icon: Icons.extension_rounded,
      color: AppColors.autismPurple,
    ),
    ActivityTarget.adhdFocus: ActivityTargetStyle(
      icon: Icons.bolt_rounded,
      color: AppColors.adhdBlue,
    ),
    ActivityTarget.audhdCombined: ActivityTargetStyle(
      icon: Icons.auto_awesome_rounded,
      color: AppColors.starGold,
    ),
  };

  static ActivityTargetStyle of(ActivityTarget target) => _styles[target]!;

  static Widget badge(ActivityTarget target) {
    final style = of(target);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: style.color,
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 11, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            target.label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
    );
  }
}
