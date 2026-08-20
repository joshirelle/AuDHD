import 'package:flutter/material.dart';
import '../../../core/i18n/language_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/kiko_card.dart';
import '../../milestones/screens/milestones_screen.dart';

/// Idinisenyo para sa kalahating hanay ng grid sa home, katabi ng activities card.
class MilestonesCard extends StatelessWidget {
  const MilestonesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return KikoCard(
      backgroundColor: AppColors.butterYellow,
      padding: const EdgeInsets.all(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MilestonesScreen()),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.stairs_rounded,
              color: AppColors.warning,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            tr('MGA MILESTONE\nNG PAGLAKI', 'GROWTH\nMILESTONES'),
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
              'Subaybayan ang paglaki at mga bagong kakayahan ng bata.',
              'Follow your child\'s growth and new skills.',
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
