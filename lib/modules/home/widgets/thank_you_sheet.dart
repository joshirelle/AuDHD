import 'package:flutter/material.dart';

import '../../../core/i18n/language_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/hive_service.dart';

/// Isang beses na pasasalamat sa mga magulang na gumagamit ng AuDHD.
class ThankYouSheet {
  static const String seenKey = 'has_seen_thanks_v5';

  /// Bilang ng magulang na nasa closed testing nang ilabas ang v5.
  static const int testerCount = 220;

  static Future<void> showIfNeeded(BuildContext context) async {
    // Hindi ito ang unang bagay na dapat makita ng bagong user — pasasalamat
    // ito sa matagal nang gumagamit, hindi pagbati sa kadarating pa lang.
    if (!HiveService.hasSeen(HiveService.hasSeenOnboardingKey)) return;
    if (HiveService.hasSeen(seenKey)) return;
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) => const _ThankYouDialog(),
    );
    await HiveService.markSeen(seenKey);
  }
}

class _ThankYouDialog extends StatelessWidget {
  const _ThankYouDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.tintGold,
      contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.starGold.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: AppColors.starGold,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            tr(
              '${ThankYouSheet.testerCount} na magulang na tayo.',
              '${ThankYouSheet.testerCount} parents and counting.',
            ),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
              height: 1.3,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 14),
          Text(
            tr(
              'Mula sa aming puso, maraming salamat sa bawat magulang na '
              'nagbukas ng pinto para sa AuDHD app. Maraming salamat sa tiwala '
              'na gawin kaming katuwang ninyo sa araw-araw na paggabay at '
              'pagmamahal sa inyong mga anak. Ang inyong patuloy na suporta ang '
              'nagbibigay-inspirasyon sa amin na lalo pang pagbutihin ang app '
              'na ito para sa bawat pamilya.',
              'From our hearts, thank you to every parent who opened the door '
              'for the AuDHD app. Thank you for the trust you placed in us to '
              'be your companion in guiding and loving your children every '
              'day. Your continued support is what inspires us to make this '
              'app better for every family.',
            ),
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textDark,
              height: 1.5,
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            tr('Salamat din!', 'Thank you too!'),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.butterInk,
              fontFamily: 'Nunito',
            ),
          ),
        ),
      ],
    );
  }
}
