import 'package:flutter/material.dart';
import '../../../core/i18n/language_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/kiko_card.dart';
import '../../behavior/screens/behavior_history_screen.dart';

class BehaviorLogCard extends StatelessWidget {
  const BehaviorLogCard({super.key});

  @override
  Widget build(BuildContext context) {
    return KikoCard(
      backgroundColor: AppColors.tintWarm,
      padding: const EdgeInsets.all(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const BehaviorHistoryScreen(),
          ),
        );
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.butterYellow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.edit_note_rounded,
              color: AppColors.butterInk,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('Tala ng Ugali', 'Behavior Log'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tr(
                    'Itala ang nangyari bago, ang ginawa ng bata, at ang nangyari pagkatapos.',
                    'Note what happened before, what your child did, and what happened after.',
                  ),
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.butterInk,
          ),
        ],
      ),
    );
  }
}
