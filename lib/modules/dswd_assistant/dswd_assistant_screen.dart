import 'package:flutter/material.dart';

import '../../core/i18n/language_controller.dart';
import '../../core/theme/app_theme.dart';
import 'widgets/office_directory_widget.dart';
import 'widgets/process_guide_widget.dart';
import 'widgets/requirements_checklist_widget.dart';

/// Gabay sa pagkuha ng DSWD Guarantee Letter sa ilalim ng AICS.
///
/// Hindi ito nag-a-apply para sa magulang at walang ipinapangakong halaga.
/// Sinasabi nito kung ano ang dalhin, ano ang mangyayari, at saan pupunta.
class DswdAssistantScreen extends StatefulWidget {
  const DswdAssistantScreen({super.key});

  @override
  State<DswdAssistantScreen> createState() => _DswdAssistantScreenState();
}

class _DswdAssistantScreenState extends State<DswdAssistantScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('DSWD Guarantee Letter', 'DSWD Guarantee Letter')),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Text(
                tr(
                  'Gabay sa paghingi ng tulong-pinansyal para sa pagsusuri at '
                      'therapy ng anak mo.',
                  'A guide to asking for financial help with your child\'s '
                      'assessment and therapy.',
                ),
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.45,
                  color: AppColors.textMuted,
                  fontFamily: 'Nunito',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
              child: Row(
                children: [
                  _buildTab(
                    index: 0,
                    icon: Icons.checklist_rounded,
                    label: tr('Dalhin', 'Bring'),
                  ),
                  const SizedBox(width: 10),
                  _buildTab(
                    index: 1,
                    icon: Icons.route_rounded,
                    label: tr('Proseso', 'Process'),
                  ),
                  const SizedBox(width: 10),
                  _buildTab(
                    index: 2,
                    icon: Icons.place_rounded,
                    label: tr('Opisina', 'Office'),
                  ),
                ],
              ),
            ),
            Expanded(child: _bodyFor(_tab)),
          ],
        ),
      ),
    );
  }

  Widget _bodyFor(int index) {
    switch (index) {
      case 1:
        return const ProcessGuideWidget();
      case 2:
        return const OfficeDirectoryWidget();
      default:
        return const RequirementsChecklistWidget();
    }
  }

  /// Nakapatong ang label sa ilalim ng icon at hindi katabi: tatlo ang tab
  /// dito, at hindi kasya ang magkatabi sa makikitid na telepono.
  Widget _buildTab({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isActive = _tab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.skyBlue : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: isActive ? AppColors.skyInk : AppColors.divider,
              width: isActive ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon at hindi emoji: walang emoji glyph ang Nunito.
              Icon(
                icon,
                size: 18,
                color: isActive ? AppColors.skyInk : AppColors.textMuted,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: isActive ? AppColors.skyInk : AppColors.textMuted,
                  fontFamily: 'Nunito',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
