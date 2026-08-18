import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/services/hive_service.dart';
import '../../../widgets/community_link.dart';
import '../../knowledge/screens/knowledge_hub_screen.dart';
import '../../profile/profile_screen.dart';
import '../../reports/screens/doctor_report_screen.dart';
import '../../schedule/screens/visual_schedule_screen.dart';
import '../../sensory/screens/home_activities_screen.dart';

class _NewThing {
  const _NewThing(this.icon, this.title, this.body, this.open);

  final IconData icon;
  final String title;
  final String body;

  /// Dinadala ang magulang mismo sa feature. Ang wizard ay nagsasabi kung ano
  /// ang bago; ito ang sumasagot kung saan.
  final void Function(BuildContext host) open;
}

/// Buod ng mga naidagdag sa bersyon 4.
///
/// Hindi ito lumalabas sa bagong user: kung katatapos lang niya ng onboarding,
/// lahat ay bago sa kanya at walang saysay ang "ano ang bago".
class WhatsNewSheet extends StatelessWidget {
  const WhatsNewSheet({super.key, required this.host});

  /// Ang screen na nagbukas nito. Kailangan para may mapagdaanan pa rin ang
  /// navigation matapos isara ang sheet.
  final BuildContext host;

  /// Bagong susi kada bersyon. Habang sinusubok, mabubuksan ito anumang oras
  /// mula sa Profile — hindi na kailangang palitan ito.
  static const String seenKey = 'has_seen_whats_new_v4';

  static void _go(BuildContext host, Widget screen) {
    Navigator.push(host, MaterialPageRoute(builder: (context) => screen));
  }

  static final List<_NewThing> _things = [
    _NewThing(
      Icons.save_rounded,
      'Kopya ng Datos',
      'Hindi na mawawala ang mga naitala mo kapag napalitan, nasira, o '
          'nawala ang telepono. Nasa Profile ito.',
      (host) => _go(host, const ProfileScreen()),
    ),
    _NewThing(
      Icons.menu_book_rounded,
      'Gabay sa Pag-unawa',
      'Walong paksa tungkol sa maaaring pinagdadaanan ng bata — ingay, '
          'ilaw, pagsabog ng damdamin, at iba pa.',
      (host) => _go(host, const KnowledgeHubScreen()),
    ),
    _NewThing(
      Icons.sports_esports_rounded,
      '36 na gawain, dating 18',
      'Nakahati na sa anim na bahagi ng paglaki, at anim na bagong gawain '
          'ang lumalabas kada araw.',
      (host) => _go(host, const HomeActivitiesScreen()),
    ),
    _NewThing(
      Icons.tune_rounded,
      'Mas malayang iskedyul',
      'Ayusin ang pagkakasunod-sunod, itago ang hindi ninyo ginagawa, '
          'lagyan ng tiyak na oras, at balikan ang nakaraang araw.',
      (host) => _go(host, const VisualScheduleScreen()),
    ),
    _NewThing(
      Icons.medical_information_rounded,
      'Rutina sa ulat ng doktor',
      'Kasama na sa PDF kung gaano kadalas nasusunod ang bawat gawain.',
      (host) => _go(host, const DoctorReportScreen()),
    ),
    _NewThing(
      Icons.groups_rounded,
      'Grupo ng mga magulang',
      'May Facebook group na ng mga gumagamit ng app. Nasa Profile ang link.',
      openAudhdGroup,
    ),
  ];

  static Future<void> _present(
    BuildContext context, {
    required bool canDismiss,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: canDismiss,
      enableDrag: canDismiss,
      builder: (sheetContext) => WhatsNewSheet(host: context),
    );
  }

  /// Binubuksan mula sa Profile. Kailangan ito: kapag pinindot ng magulang ang
  /// "Tingnan ko mamaya", dapat may mabalikan siya.
  static Future<void> show(BuildContext context) =>
      _present(context, canDismiss: true);

  static Future<void> showIfNeeded(BuildContext context) async {
    if (!HiveService.hasSeen(HiveService.hasSeenOnboardingKey)) return;
    if (HiveService.hasSeen(seenKey)) return;

    await _present(context, canDismiss: false);
    await HiveService.markSeen(seenKey);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              children: [
                const Text(
                  'Ano ang bago sa AuDHD',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    fontFamily: 'Nunito',
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Salamat sa pagsubok ng app. Pindutin ang alinman para '
                  'makita mo agad kung nasaan ito.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    fontFamily: 'Nunito',
                  ),
                ),
                const SizedBox(height: 20),
                for (final thing in _things) ...[
                  _buildRow(context, thing),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.logoGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Tingnan ko mamaya',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext sheetContext, _NewThing thing) {
    return InkWell(
      onTap: () {
        Navigator.pop(sheetContext);
        thing.open(host);
      },
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: const BoxDecoration(
                color: AppColors.tintSuccess,
                shape: BoxShape.circle,
              ),
              child: Icon(thing.icon, size: 20, color: AppColors.logoGreen),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    thing.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    thing.body,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: AppColors.textMuted,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 8, left: 6),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
