import 'package:flutter/material.dart';
import '../../../core/i18n/language_controller.dart';
import '../../../core/theme/app_theme.dart';

/// Biswal na angkla kada tanong. Sinadyang neutral: hindi dapat mahulaan ng
/// magulang mula rito kung alin ang at-risk na sagot.
class ScreeningCategory {
  final IconData icon;
  final Color color;
  final String _label;
  final String _labelEnglish;

  const ScreeningCategory({
    required this.icon,
    required this.color,
    required String label,
    required String labelEnglish,
  }) : _label = label,
       _labelEnglish = labelEnglish;

  String get label => tr(_label, _labelEnglish);

  static const ScreeningCategory fallback = ScreeningCategory(
    icon: Icons.help_outline_rounded,
    color: AppColors.skyBlueLight,
    label: 'Tanong',
    labelEnglish: 'Question',
  );

  static const Map<String, ScreeningCategory> _mchat = {
    'jointAttention': ScreeningCategory(
      icon: Icons.touch_app_rounded,
      color: AppColors.skyBlue,
      label: 'Pagtuturo at Pagtingin',
      labelEnglish: 'Pointing and Looking',
    ),
    'socialResponse': ScreeningCategory(
      icon: Icons.face_rounded,
      color: AppColors.mintGreen,
      label: 'Panlipunang Tugon',
      labelEnglish: 'Social Response',
    ),
    'playImitation': ScreeningCategory(
      icon: Icons.toys_rounded,
      color: AppColors.butterYellow,
      label: 'Laro at Panggagaya',
      labelEnglish: 'Play and Copying',
    ),
    'movement': ScreeningCategory(
      icon: Icons.directions_run_rounded,
      color: AppColors.coralPeach,
      label: 'Galaw ng Katawan',
      labelEnglish: 'Body Movement',
    ),
    'sensory': ScreeningCategory(
      icon: Icons.hearing_rounded,
      color: AppColors.skyBlueLight,
      label: 'Pandama',
      labelEnglish: 'Senses',
    ),
  };

  static const Map<String, ScreeningCategory> _vanderbilt = {
    'Inattention': ScreeningCategory(
      icon: Icons.psychology_rounded,
      color: AppColors.skyBlueLight,
      label: 'Atensyon',
      labelEnglish: 'Attention',
    ),
    'Hyperactivity': ScreeningCategory(
      icon: Icons.bolt_rounded,
      color: AppColors.butterYellow,
      label: 'Sobrang Galaw',
      labelEnglish: 'Very Active',
    ),
  };

  /// Tugma sa kulay na ginagamit ng sensory activity cards.
  static const Map<String, ScreeningCategory> _sensory = {
    'Auditory': ScreeningCategory(
      icon: Icons.hearing_rounded,
      color: AppColors.coralPeach,
      label: 'Pandinig',
      labelEnglish: 'Hearing',
    ),
    'Visual': ScreeningCategory(
      icon: Icons.visibility_rounded,
      color: AppColors.skyBlueLight,
      label: 'Paningin',
      labelEnglish: 'Sight',
    ),
    'Tactile': ScreeningCategory(
      icon: Icons.back_hand_rounded,
      color: AppColors.butterYellow,
      label: 'Hipo at Tekstura',
      labelEnglish: 'Touch and Texture',
    ),
    'Vestibular': ScreeningCategory(
      icon: Icons.rotate_right_rounded,
      color: AppColors.skyBlue,
      label: 'Balanse at Ugoy',
      labelEnglish: 'Balance and Swaying',
    ),
    'Proprioceptive': ScreeningCategory(
      icon: Icons.fitness_center_rounded,
      color: AppColors.mintGreen,
      label: 'Puwersa at Presyon',
      labelEnglish: 'Force and Pressure',
    ),
  };

  static ScreeningCategory forMChat(String key) => _mchat[key] ?? fallback;

  static ScreeningCategory forVanderbilt(String key) =>
      _vanderbilt[key] ?? fallback;

  static ScreeningCategory forSensory(String key) => _sensory[key] ?? fallback;
}
