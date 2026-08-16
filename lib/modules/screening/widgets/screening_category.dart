import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Biswal na angkla kada tanong. Sinadyang neutral: hindi dapat mahulaan ng
/// magulang mula rito kung alin ang at-risk na sagot.
class ScreeningCategory {
  final IconData icon;
  final Color color;
  final String label;

  const ScreeningCategory({
    required this.icon,
    required this.color,
    required this.label,
  });

  static const ScreeningCategory fallback = ScreeningCategory(
    icon: Icons.help_outline_rounded,
    color: AppColors.skyBlueLight,
    label: 'Tanong',
  );

  static const Map<String, ScreeningCategory> _mchat = {
    'jointAttention': ScreeningCategory(
      icon: Icons.touch_app_rounded,
      color: AppColors.skyBlue,
      label: 'Pagtuturo at Pagtingin',
    ),
    'socialResponse': ScreeningCategory(
      icon: Icons.face_rounded,
      color: AppColors.mintGreen,
      label: 'Panlipunang Tugon',
    ),
    'playImitation': ScreeningCategory(
      icon: Icons.toys_rounded,
      color: AppColors.butterYellow,
      label: 'Laro at Panggagaya',
    ),
    'movement': ScreeningCategory(
      icon: Icons.directions_run_rounded,
      color: AppColors.coralPeach,
      label: 'Galaw ng Katawan',
    ),
    'sensory': ScreeningCategory(
      icon: Icons.hearing_rounded,
      color: AppColors.skyBlueLight,
      label: 'Pandama',
    ),
  };

  static const Map<String, ScreeningCategory> _vanderbilt = {
    'Inattention': ScreeningCategory(
      icon: Icons.psychology_rounded,
      color: AppColors.skyBlueLight,
      label: 'Atensyon',
    ),
    'Hyperactivity': ScreeningCategory(
      icon: Icons.bolt_rounded,
      color: AppColors.butterYellow,
      label: 'Sobrang Galaw',
    ),
  };

  /// Tugma sa kulay na ginagamit ng sensory activity cards.
  static const Map<String, ScreeningCategory> _sensory = {
    'Auditory': ScreeningCategory(
      icon: Icons.hearing_rounded,
      color: AppColors.coralPeach,
      label: 'Pandinig',
    ),
    'Visual': ScreeningCategory(
      icon: Icons.visibility_rounded,
      color: AppColors.skyBlueLight,
      label: 'Paningin',
    ),
    'Tactile': ScreeningCategory(
      icon: Icons.back_hand_rounded,
      color: AppColors.butterYellow,
      label: 'Hipo at Tekstura',
    ),
    'Vestibular': ScreeningCategory(
      icon: Icons.rotate_right_rounded,
      color: AppColors.skyBlue,
      label: 'Balanse at Ugoy',
    ),
    'Proprioceptive': ScreeningCategory(
      icon: Icons.fitness_center_rounded,
      color: AppColors.mintGreen,
      label: 'Puwersa at Presyon',
    ),
  };

  static ScreeningCategory forMChat(String key) => _mchat[key] ?? fallback;

  static ScreeningCategory forVanderbilt(String key) =>
      _vanderbilt[key] ?? fallback;

  static ScreeningCategory forSensory(String key) => _sensory[key] ?? fallback;
}
