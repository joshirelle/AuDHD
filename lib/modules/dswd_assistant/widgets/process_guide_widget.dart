import 'package:flutter/material.dart';

import '../../../core/i18n/language_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/link_launcher.dart';
import '../../../widgets/kiko_card.dart';
import '../data/dswd_guide.dart';
import '../models/dswd_office.dart';

/// Ano ang mangyayari sa loob ng opisina, mula pila hanggang ospital.
class ProcessGuideWidget extends StatelessWidget {
  const ProcessGuideWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = DswdGuide.process;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          _buildStep(i + 1, steps[i]),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 4),
        _buildSourceButton(context),
        const SizedBox(height: 12),
        _buildSourceNote(),
      ],
    );
  }

  Widget _buildStep(int number, DswdStep step) {
    return KikoCard(
      backgroundColor: AppColors.surface,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.skyBlue,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.skyInk,
                fontFamily: 'Nunito',
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(step.icon, size: 18, color: AppColors.accentBlue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        step.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  step.body,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.5,
                    color: AppColors.textMuted,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceButton(BuildContext context) {
    return GestureDetector(
      onTap: () => LinkLauncher.open(
        context,
        DswdOfficial.aicsProgram,
        tr(
          'Walang nakabukas na browser para dito.',
          'There is no browser here to open this.',
        ),
      ),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.logoGreen,
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.open_in_new_rounded,
              size: 18,
              color: AppColors.surface,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                tr(
                  'Alituntunin sa DSWD website',
                  'The rules on the DSWD website',
                ),
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.surface,
                  fontFamily: 'Nunito',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceNote() {
    return Text(
      tr(
        'Bubuksan nito ang aics.dswd.gov.ph sa browser mo. Ito lang ang bahagi '
            'ng app na kailangan ng internet.',
        'This opens aics.dswd.gov.ph in your browser. It is the only part of '
            'the app that needs the internet.',
      ),
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 11.5,
        height: 1.45,
        color: AppColors.textMuted,
        fontFamily: 'Nunito',
      ),
    );
  }
}
