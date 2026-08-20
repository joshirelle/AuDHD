import 'package:flutter/material.dart';
import '../core/i18n/language_controller.dart';
import '../core/theme/app_theme.dart';

/// Bumalik + progress bar + bilang, ginagamit ng screening, checklist, at behavior log.
class StepProgressHeader extends StatelessWidget {
  final int currentIndex;
  final int totalCount;
  final VoidCallback onBack;

  const StepProgressHeader({
    super.key,
    required this.currentIndex,
    required this.totalCount,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: onBack,
          child: Row(
            children: [
              const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: AppColors.accentBlue,
              ),
              const SizedBox(width: 4),
              Text(
                tr('Bumalik', 'Back'),
                style: const TextStyle(
                  color: AppColors.accentBlue,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Nunito',
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (currentIndex + 1) / totalCount,
                minHeight: 12,
                backgroundColor: AppColors.divider,
                // Halos hindi makita ang pastel na palaman sa kulay-abong track.
                color: AppColors.logoGreen,
              ),
            ),
          ),
        ),
        Text(
          '${currentIndex + 1} / $totalCount',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
            fontFamily: 'Nunito',
          ),
        ),
      ],
    );
  }
}
