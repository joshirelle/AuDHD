import 'package:flutter/material.dart';

import '../../../core/i18n/language_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/hive_service.dart';
import '../../../widgets/kiko_card.dart';
import '../data/dswd_guide.dart';

/// Ang mga papeles na dadalhin, may tsek na natatandaan.
///
/// Ang tsek ay nasa bawat bata: iba ang medical abstract at ang quotation
/// kada anak, kaya hiwalay din ang aplikasyon.
class RequirementsChecklistWidget extends StatefulWidget {
  const RequirementsChecklistWidget({super.key});

  @override
  State<RequirementsChecklistWidget> createState() =>
      _RequirementsChecklistWidgetState();
}

class _RequirementsChecklistWidgetState
    extends State<RequirementsChecklistWidget> {
  Future<void> _toggle(DswdRequirement requirement) async {
    final isReady = HiveService.isDswdRequirementReady(requirement.id);
    await HiveService.setDswdRequirementReady(requirement.id, !isReady);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final requirements = DswdGuide.requirements;
    final ready = requirements
        .where((r) => HiveService.isDswdRequirementReady(r.id))
        .length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        _buildProgress(ready, requirements.length),
        const SizedBox(height: 16),
        for (final requirement in requirements) ...[
          _buildRequirement(requirement),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 4),
        _buildDisclaimer(),
      ],
    );
  }

  Widget _buildProgress(int ready, int total) {
    final childName = HiveService.getActiveChild()?.displayName;

    return KikoCard(
      backgroundColor: AppColors.tintGold,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('$ready sa $total naihanda', '$ready of $total prepared'),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : ready / total,
              minHeight: 8,
              backgroundColor: AppColors.surface,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.logoGreen,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            childName == null
                ? tr(
                    'Maaaring may hingin pang ibang papel ang opisina.',
                    'The office may still ask for other papers.',
                  )
                : tr(
                    'Para kay $childName. Maaaring may hingin pang ibang papel '
                        'ang opisina.',
                    'For $childName. The office may still ask for other papers.',
                  ),
            style: const TextStyle(
              fontSize: 12,
              height: 1.45,
              color: AppColors.textDark,
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirement(DswdRequirement requirement) {
    final isReady = HiveService.isDswdRequirementReady(requirement.id);

    return KikoCard(
      backgroundColor: AppColors.surface,
      borderColor: isReady ? AppColors.logoGreen : null,
      padding: const EdgeInsets.all(16),
      onTap: () => _toggle(requirement),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCheck(isReady),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icon at hindi emoji: walang emoji glyph ang Nunito.
                    Icon(
                      requirement.icon,
                      size: 18,
                      color: AppColors.accentBlue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        requirement.title,
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
                  requirement.body,
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

  /// Sariling gawa at hindi `Checkbox`: pinapasok ng Material ang sariling
  /// kulay nito, at dalawang linya lang naman ang buong hitsura.
  Widget _buildCheck(bool isReady) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: isReady ? AppColors.logoGreen : AppColors.background,
        shape: BoxShape.circle,
        border: Border.all(
          color: isReady ? AppColors.logoGreen : AppColors.divider,
          width: 2,
        ),
      ),
      child: isReady
          ? const Icon(Icons.check_rounded, size: 16, color: AppColors.surface)
          : null,
    );
  }

  Widget _buildDisclaimer() {
    return KikoCard(
      backgroundColor: AppColors.tintGold,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: AppColors.warning,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              DswdGuide.disclaimer,
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
}
