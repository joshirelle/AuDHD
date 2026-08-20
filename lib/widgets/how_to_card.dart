import 'package:flutter/material.dart';
import '../core/i18n/language_controller.dart';
import '../core/theme/app_theme.dart';
import 'kiko_card.dart';

/// Karamihan sa gagamit ng app ay walang pagsasanay sa therapy, kaya nauuna ang
/// paliwanag bago ang mismong gawain.
class HowToCard extends StatelessWidget {
  const HowToCard({super.key, required this.steps, this.footnote});

  final List<String> steps;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    return KikoCard(
      backgroundColor: AppColors.skyBlueLight,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('PAANO ITO GAMITIN', 'HOW TO USE THIS'),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: AppColors.skyInk,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < steps.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _HowToStep(number: '${i + 1}', text: steps[i]),
          ],
          if (footnote != null) ...[
            const SizedBox(height: 12),
            Text(
              footnote!,
              style: const TextStyle(
                fontSize: 12,
                height: 1.35,
                color: AppColors.textDark,
                fontFamily: 'Nunito',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HowToStep extends StatelessWidget {
  const _HowToStep({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.skyInk,
              fontFamily: 'Nunito',
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              height: 1.35,
              color: AppColors.textDark,
              fontFamily: 'Nunito',
            ),
          ),
        ),
      ],
    );
  }
}
