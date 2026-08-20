import 'package:flutter/material.dart';

import '../../../core/i18n/language_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/community_link.dart';
import '../../../widgets/kiko_card.dart';
import '../../../widgets/play_store_link.dart';
import 'whats_new_sheet.dart';

/// Tatlong maiikling pindutan sa ilalim ng bituin.
///
/// Dating nasa Profile ang tatlo. Inilipat dito para makita agad — pero
/// may markang palabas ang dalawa na umaalis ng app.
class QuickLinksRow extends StatelessWidget {
  const QuickLinksRow({super.key});

  @override
  Widget build(BuildContext context) {
    // Walang CrossAxisAlignment.stretch: walang hangganan ang taas sa loob ng
    // SingleChildScrollView. Pareho naman ang laman ng tatlo kaya pantay sila.
    return Row(
      children: [
        Expanded(
          child: _QuickLink(
            icon: Icons.auto_awesome_rounded,
            label: tr('Bago', "What's New"),
            fill: AppColors.mintGreen,
            ink: AppColors.mintInk,
            onTap: () => WhatsNewSheet.show(context),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickLink(
            icon: Icons.groups_rounded,
            label: tr('Grupo', 'Group'),
            fill: AppColors.coralPeach,
            ink: AppColors.coralInk,
            leavesApp: true,
            onTap: () => openAudhdGroup(context),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickLink(
            icon: Icons.star_rounded,
            label: tr('I-rate', 'Rate'),
            fill: AppColors.skyBlue,
            ink: AppColors.skyInk,
            leavesApp: true,
            onTap: () => openPlayStoreListing(context),
          ),
        ),
      ],
    );
  }
}

class _QuickLink extends StatelessWidget {
  const _QuickLink({
    required this.icon,
    required this.label,
    required this.fill,
    required this.ink,
    required this.onTap,
    this.leavesApp = false,
  });

  final IconData icon;
  final String label;
  final Color fill;
  final Color ink;
  final VoidCallback onTap;

  /// Nagpapakita ng maliit na pahiwatig na aalis sa AuDHD kapag pinindot.
  final bool leavesApp;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: leavesApp
          ? tr(
              '$label. Bubukas sa labas ng app.',
              '$label. Opens outside the app.',
            )
          : label,
      child: KikoCard(
        backgroundColor: fill,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        onTap: onTap,
        child: Stack(
          children: [
            // Sumusukat ang Stack sa laman nito, kaya kailangang punuin muna
            // ang lapad bago ma-center ang icon at label.
            SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: ink, size: 24),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: ink,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ],
              ),
            ),
            if (leavesApp)
              Positioned(
                top: 0,
                right: 0,
                child: Icon(
                  Icons.open_in_new_rounded,
                  size: 11,
                  color: ink.withValues(alpha: 0.65),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
