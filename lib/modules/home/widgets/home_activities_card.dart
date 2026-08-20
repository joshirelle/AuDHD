import 'package:flutter/material.dart';
import '../../../core/i18n/language_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/kiko_card.dart';
import '../../sensory/screens/home_activities_screen.dart';

/// Idinisenyo para sa kalahating hanay ng grid sa home, katabi ng milestones card.
class HomeActivitiesCard extends StatelessWidget {
  const HomeActivitiesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return KikoCard(
      backgroundColor: AppColors.mintGreen,
      padding: const EdgeInsets.all(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomeActivitiesScreen()),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.logoGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.sports_esports_rounded,
              color: AppColors.logoGreen,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            tr('MGA GAWAIN\nSA BAHAY', 'HOME\nACTIVITIES'),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              fontFamily: 'Nunito',
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tr(
              'Mga larong pansensory na kayang gawin araw-araw sa bahay.',
              'Sensory play you can do at home every day.',
            ),
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textDark,
              fontFamily: 'Nunito',
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
