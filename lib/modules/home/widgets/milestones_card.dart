import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/kiko_card.dart';
import '../../milestones/screens/milestones_screen.dart';

/// Idinisenyo para sa kalahating hanay ng grid sa home, katabi ng screening card.
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
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.stairs_rounded,
              color: AppColors.warning,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'DEVELOPMENTAL\nMILESTONES',
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
            'Subaybayan ang paglaki at mga bagong kakayahan ng bata.',
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
