import 'package:flutter/material.dart';

import '../../../core/i18n/language_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/hive_service.dart';
import '../../../widgets/community_link.dart';
import '../../profile/profile_screen.dart';
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

/// Buod ng mga naidagdag sa bersyon 5.
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
  static const String seenKey = 'has_seen_whats_new_v5';

  static void _go(BuildContext host, Widget screen) {
    Navigator.push(host, MaterialPageRoute(builder: (context) => screen));
  }

  /// Getter, hindi `final`: nasa loob ng bawat teksto ang `tr()`, kaya kailangan
  /// itong muling buuin sa tuwing bubuksan para tumugma sa piniling wika.
  static List<_NewThing> get _things => [
    _NewThing(
      Icons.translate_rounded,
      tr('Filipino o Ingles', 'Filipino or English'),
      tr(
        'May magulang na nagsabing Ingles lang ang naiintindihan ng anak '
            'nila. Mapapalitan mo na ang wika ng buong app sa Profile, pati '
            'ang PDF para sa doktor.',
        'Some parents told us their child only understands English. You can '
            'now switch the whole app in Profile, including the PDF for the '
            'doctor.',
      ),
      (host) => _go(host, const ProfileScreen()),
    ),
    _NewThing(
      Icons.auto_awesome_rounded,
      tr('Tatlong pindutan sa Bahay', 'Three buttons on Home'),
      tr(
        'Ang Ano ang Bago, ang grupo ng magulang, at ang pag-rate ay nasa '
            'itaas na ng Bahay — hindi na kailangang hanapin sa Profile.',
        'What\'s New, the parent group, and rating the app are now at the top '
            'of Home — no need to look for them in Profile.',
      ),
      (host) => _go(host, const ProfileScreen()),
    ),
    _NewThing(
      Icons.emoji_events_rounded,
      tr('Kayo na ang pumipili ng pabuya', 'You choose every reward'),
      tr(
        'Inalis na namin ang tatlong halimbawang pabuya. Kayo ang mas nakakaalam '
            'kung ano ang tunay na pabuya sa bahay ninyo.',
        'We removed the three sample rewards. You know better than we do what '
            'a real reward is in your home.',
      ),
      (host) => _go(host, const ProfileScreen()),
    ),
    _NewThing(
      Icons.palette_rounded,
      tr('Mas malambot na kulay', 'Softer colours'),
      tr(
        'Inalis namin ang matingkad na puti sa buong app. Mas madali na itong '
            'tingnan, lalo na sa gabi.',
        'We removed the harsh white from the whole app. It is easier on the '
            'eyes now, especially at night.',
      ),
      (host) => _go(host, const HomeActivitiesScreen()),
    ),
    _NewThing(
      Icons.system_update_rounded,
      tr('Kusang nag-a-update', 'Updates on its own'),
      tr(
        'Kapag may bagong bersyon, tahimik itong naidodownload sa likod at '
            'tatanungin ka lang kung kailan mo gustong i-restart.',
        'When a new version is out, it quietly downloads in the background '
            'and only asks when you want to restart.',
      ),
      (host) => _go(host, const ProfileScreen()),
    ),
    _NewThing(
      Icons.groups_rounded,
      tr('Grupo ng mga magulang', 'Group of parents'),
      tr(
        'May Facebook group na ng mga gumagamit ng app. Nasa Bahay na ang link.',
        'There is now a Facebook group for app users. The link is on Home.',
      ),
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
                Text(
                  tr('Ano ang bago sa AuDHD', "What's new in AuDHD"),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    fontFamily: 'Nunito',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tr(
                    'Salamat sa pagsubok ng app. Pindutin ang alinman para '
                        'makita mo agad kung nasaan ito.',
                    'Thank you for trying the app. Tap any of these to see '
                        'right away where it is.',
                  ),
                  style: const TextStyle(
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
                child: Text(
                  tr('Tingnan ko mamaya', "I'll look later"),
                  style: const TextStyle(
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
