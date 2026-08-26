import 'package:flutter/material.dart';

import '../../../core/i18n/language_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/kiko_card.dart';
import '../../../widgets/medical_disclaimer_sheet.dart';
import '../data/observation_areas.dart';

/// Mga anyong maaaring mapansin ng magulang, hinati ayon sa bahagi ng paglaki.
///
/// Hindi ito paghahambing ng mga kondisyon. Tingnan ang paliwanag sa
/// `ObservationAreas`.
class ObservationAreasScreen extends StatelessWidget {
  const ObservationAreasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final areas = ObservationAreas.all;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('Mga Maaari Mong Mapansin', 'What You Might Notice')),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          _buildNotice(context),
          const SizedBox(height: 20),
          for (final area in areas) ...[
            _buildArea(area),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildNotice(BuildContext context) {
    return KikoCard(
      backgroundColor: AppColors.tintGold,
      padding: const EdgeInsets.all(16),
      onTap: () => MedicalDisclaimerSheet.show(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.warning,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tr(
                'Hindi ito panukat kung ano ang anak mo. Tulong ito para '
                    'makilala at maitala ang nakikita mo — ang doktor pa rin ang '
                    'magsasabi kung ano ang ibig sabihin nito.',
                'This is not a way to decide what your child is. It helps you '
                    'recognise and record what you see — a doctor is still the '
                    'one who says what it means.',
              ),
              style: const TextStyle(
                fontSize: 12,
                height: 1.45,
                color: AppColors.textDark,
                fontFamily: 'Nunito',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArea(ObservationArea area) {
    return KikoCard(
      backgroundColor: AppColors.surface,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: area.category.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(area.icon, size: 20, color: area.category.ink),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  area.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            area.intro,
            style: const TextStyle(
              fontSize: 12,
              height: 1.45,
              color: AppColors.textMuted,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 6),
          for (final pattern in area.patterns) _buildPattern(area, pattern),
        ],
      ),
    );
  }

  Widget _buildPattern(ObservationArea area, ObservationPattern pattern) {
    return Theme(
      // Inaalis ang linya ng Material sa ibabaw at ibaba ng bawat tile.
      data: ThemeData(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 12),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        iconColor: AppColors.textMuted,
        collapsedIconColor: AppColors.textMuted,
        title: Text(
          pattern.title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
            fontFamily: 'Nunito',
          ),
        ),
        children: [
          Text(
            pattern.body,
            style: const TextStyle(
              fontSize: 12,
              height: 1.5,
              color: AppColors.textDark,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: area.category.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('Maaari mong subukan', 'You could try'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: area.category.ink,
                    fontFamily: 'Nunito',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  pattern.help,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    color: area.category.ink,
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
}
