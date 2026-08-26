import 'package:flutter/material.dart';

import '../../core/i18n/language_controller.dart';
import '../../core/theme/app_theme.dart';
import 'widgets/directory_shell_widget.dart';
import 'widgets/prep_guide_widget.dart';

/// Gabay bago at habang naghihintay ng konsultasyon.
///
/// Hindi ito nagsasabi kung ano ang kondisyon ng bata. Sinasabi nito kung ano
/// ang dalhin, ano ang aasahan, at kung saan puwedeng magsimula.
class ConsultationScreen extends StatefulWidget {
  const ConsultationScreen({super.key});

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('Gabay sa Konsultasyon', 'Consultation Guide')),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Row(
                children: [
                  _buildTab(
                    index: 0,
                    icon: Icons.checklist_rounded,
                    label: tr('Gabay sa Pagpunta', 'Getting Ready'),
                  ),
                  const SizedBox(width: 10),
                  _buildTab(
                    index: 1,
                    icon: Icons.local_hospital_rounded,
                    label: tr('Hanap Klinika', 'Find a Clinic'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _tab == 0
                  ? const PrepGuideWidget()
                  : const DirectoryShellWidget(),
            ),
          ],
        ),
      ),
    );
  }

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
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.skyBlue : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: isActive ? AppColors.skyInk : AppColors.divider,
              width: isActive ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon at hindi emoji: walang emoji glyph ang Nunito.
              Icon(
                icon,
                size: 18,
                color: isActive ? AppColors.skyInk : AppColors.textMuted,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isActive ? AppColors.skyInk : AppColors.textMuted,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
