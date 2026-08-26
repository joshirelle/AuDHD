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
/// `warning` sa `tintGold` ay 4.32:1 — pasado sa WCAG 1.4.11 para sa icon na
/// may kahulugan.
class MedicalDisclaimerBody extends StatelessWidget {
  const MedicalDisclaimerBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.tintGold,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              size: 30,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            MedicalDisclaimerSheet.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              height: 1.25,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            MedicalDisclaimerSheet.body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textDark,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
            child: Text(
              MedicalDisclaimerSheet.scope,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.45,
                fontWeight: FontWeight.bold,
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
