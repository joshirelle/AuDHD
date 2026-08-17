import 'package:flutter/material.dart';
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
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.sports_esports_rounded,
              color: AppColors.logoGreen,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'MGA GAWAIN\nSA BAHAY',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              fontFamily: 'Nunito',
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Mga larong pansensory na kayang gawin araw-araw sa bahay.',
            style: TextStyle(
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
