import 'package:flutter/material.dart';
import '../../../core/services/star_service.dart';
import '../../../core/theme/app_theme.dart';
import 'star_reward_dialog.dart';

class StarBadgeWidget extends StatelessWidget {
  const StarBadgeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      // Nakikinig sa completion, milestone, at schedule box nang sabay.
      listenable: StarService.listenable,
      builder: (context, _) {
        return GestureDetector(
          onTap: () => StarRewardDialog.show(context),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.butterYellow,
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 20,
                  color: AppColors.starGold,
                ),
                const SizedBox(width: 6),
                Text(
                  '${StarService.totalStars()}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
