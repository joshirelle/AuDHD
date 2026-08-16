import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'screening_attribution.dart';

/// Kasama na ito sa PDF; kailangan din sa screen dahil doon unang nakikita ng
/// magulang ang salitang "HIGH RISK".
class ScreeningDisclaimer extends StatelessWidget {
  const ScreeningDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.tintWarm,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.45)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_rounded, size: 18, color: AppColors.warning),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              ScreeningAttribution.disclaimer,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textDark,
                height: 1.4,
                fontFamily: 'Nunito',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
