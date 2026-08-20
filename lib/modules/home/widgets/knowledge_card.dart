import 'package:flutter/material.dart';
import '../../../core/i18n/language_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/kiko_card.dart';
import '../../knowledge/screens/knowledge_hub_screen.dart';

/// Buong lapad, sa ilalim ng grid. Ang tatlong-hanay na grid ay sumisikip
/// nang husto sa 360dp na telepono.
class KnowledgeCard extends StatelessWidget {
  const KnowledgeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return KikoCard(
      backgroundColor: AppColors.lavender,
      padding: const EdgeInsets.all(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const KnowledgeHubScreen()),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.autismPurple.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: AppColors.autismPurple,
              size: 32,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('GABAY SA PAG-UNAWA', 'UNDERSTANDING GUIDE'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    fontFamily: 'Nunito',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tr(
                    'Mga maikling paliwanag para mas maunawaan ang bata.',
                    'Short notes to help you understand your child.',
                  ),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textDark,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textDark),
        ],
      ),
    );
  }
}
