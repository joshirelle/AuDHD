import 'package:flutter/material.dart';
import '../../../core/i18n/language_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/kiko_card.dart';
import '../../reports/screens/doctor_report_screen.dart';

class DoctorReportCard extends StatelessWidget {
  const DoctorReportCard({super.key});

  @override
  Widget build(BuildContext context) {
    return KikoCard(
      backgroundColor: AppColors.skyBlueLight,
      padding: const EdgeInsets.all(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DoctorReportScreen()),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.medical_information_rounded,
              color: AppColors.accentBlue,
              size: 32,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('ULAT PARA SA DOKTOR', 'DOCTOR\'S REPORT'),
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
                    'Buuin ang PDF na dadalhin mo sa developmental pediatrician.',
                    'Build the PDF you can bring to your developmental pediatrician.',
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
