import 'package:flutter/material.dart';

import '../../../core/i18n/language_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/kiko_card.dart';
import '../../consultation/consultation_screen.dart';

/// Pasukan sa Gabay sa Konsultasyon.
class ConsultationCard extends StatelessWidget {
  const ConsultationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return KikoCard(
      backgroundColor: AppColors.tintSuccess,
      padding: const EdgeInsets.all(18),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ConsultationScreen()),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.mintInk.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.local_hospital_rounded,
              color: AppColors.mintInk,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('Gabay sa Konsultasyon', 'Consultation Guide'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    fontFamily: 'Nunito',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tr(
                    'Ano ang dadalhin, ano ang aasahan, at ano ang magagawa mo '
                        'habang naghihintay ng slot.',
                    'What to bring, what to expect, and what you can do while '
                        'waiting for a slot.',
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: AppColors.textDark,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textDark),
        ],
      ),
    );
  }
}
