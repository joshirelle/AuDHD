import 'package:flutter/material.dart';

import '../core/i18n/language_controller.dart';
import '../core/theme/app_theme.dart';
import '../data/services/hive_service.dart';

/// Paalalang pangkalusugan mula sa payo ng mga propesyonal sa kalusugan.
///
/// Iisang teksto lang, ginagamit sa onboarding at sa Profile, para hindi
/// magkaiba ang sinasabi ng app sa dalawang lugar.
class MedicalDisclaimerSheet {
  const MedicalDisclaimerSheet._();

  /// Kinikilala sa dulo ng onboarding. Nasa `app_settings` box gaya ng ibang
  /// seen key.
  static const String seenKey = 'has_seen_medical_v6';

  static String get title =>
      tr('Mahalagang Paalala sa Kalusugan', 'An Important Health Note');

  /// Ang buong mensahe sa isang sulyap, para sa hindi magbabasa ng talata.
  static String get headline => tr(
    'Hindi ito pamalit sa diagnosis.',
    'This is not a replacement for a diagnosis.',
  );

  static String get body => tr(
    'Ang AuDHD app ay gabay sa pagsuporta sa tahanan at HINDI pamalit sa '
        'opisyal na diagnosis ng Developmental Pediatrician. Maaaring may '
        'palatandaang katulad nito ang isang bata nang hindi naman iyon ang '
        'kondisyon niya — o walang kondisyon man lang. Kumonsulta sa '
        'propesyonal para sa tamang pagsusuri.',
    'The AuDHD app is a guide for support at home and is NOT a replacement for '
        'a formal diagnosis by a Developmental Pediatrician. A child can show '
        'signs like these without having that condition — or without having any '
        'condition at all. Please consult a professional for a proper '
        'assessment.',
  );

  /// Binasa ng isang nurse ang pangalang AuDHD bilang "autism AT ADHD". Kung
  /// ganoon ang naintindihan niya, ganoon din ang magulang.
  static String get scope => tr(
    'Para ito sa sinumang magulang na may anak na may natatanging '
        'pangangailangan — autism, ADHD, speech delay, o wala pang sagot sa '
        'ngayon.',
    'This is for any parent raising a child with special needs — autism, ADHD, '
        'speech delay, or no answer yet.',
  );

  static String get acknowledgeLabel => tr('Naiintindihan Ko', 'I Understand');

  static bool get hasAcknowledged => HiveService.hasSeen(seenKey);

  static Future<void> acknowledge() => HiveService.markSeen(seenKey);

  /// Para sa magulang na may naka-install na bago pa ito naidagdag — sa
  /// onboarding kinikilala ito ng bagong user, at doon lang.
  ///
  /// Minamarkahan kahit paano isinara. Ang paalalang umuulit tuwing bubuksan
  /// ang app ay hindi na paalala kundi istorbo, at ang katapusan niyon ay
  /// hindi na ito binabasa.
  static Future<void> showIfNeeded(BuildContext context) async {
    if (!HiveService.hasSeen(HiveService.hasSeenOnboardingKey)) return;
    if (hasAcknowledged) return;
    await show(context);
    await acknowledge();
  }

  /// Mababasa anumang oras mula sa Profile. Ang paalalang minsan lang nakita
  /// ay hindi paalala.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(sheetContext).size.height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: const MedicalDisclaimerBody(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.logoGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.button),
                    ),
                  ),
                  child: Text(
                    acknowledgeLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.surface,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ang mismong laman ng paalala, walang pindutan.
///
/// Hiwalay para magamit ng onboarding slide nang hindi bumubukas ng sheet.
///
/// Lahat ng teksto ay `textDark`: ang `warning` sa `tintGold` ay 4.32:1, sapat
/// para sa icon pero bagsak para sa titik. Sukat at bigat ang hierarchy, hindi
/// kulay — maliban sa banda, kung saan puti sa `warning` ay 5.01:1.
class MedicalDisclaimerBody extends StatelessWidget {
  const MedicalDisclaimerBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Para masundan ng solidong banda ang kurba ng kard.
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.tintGold,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBanner(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  MedicalDisclaimerSheet.headline,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    height: 1.3,
                    fontFamily: 'Nunito',
                  ),
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: AppColors.divider),
                const SizedBox(height: 14),
                Text(
                  MedicalDisclaimerSheet.body,
                  style: const TextStyle(
                    fontSize: 14.5,
                    height: 1.55,
                    color: AppColors.textDark,
                    fontFamily: 'Nunito',
                  ),
                ),
                const SizedBox(height: 16),
                _buildScope(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      color: AppColors.warning,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(
            Icons.priority_high_rounded,
            size: 18,
            color: AppColors.surface,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              MedicalDisclaimerSheet.title.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.6,
                color: AppColors.surface,
                fontFamily: 'Nunito',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScope() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.favorite_rounded,
            size: 16,
            color: AppColors.warning,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              MedicalDisclaimerSheet.scope,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.45,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
                fontFamily: 'Nunito',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
