import 'package:flutter/material.dart';

import '../../../core/i18n/language_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/hive_service.dart';
import '../../../widgets/community_link.dart';
import '../../dswd_assistant/dswd_assistant_screen.dart';
import '../../knowledge/screens/knowledge_hub_screen.dart';
import '../../milestones/screens/milestones_screen.dart';
import '../../profile/profile_screen.dart';
import '../../schedule/screens/visual_schedule_screen.dart';
import 'star_reward_dialog.dart';

class _NewThing {
  const _NewThing(this.icon, this.title, this.body, {this.open});

  final IconData icon;
  final String title;
  final String body;

  /// Dinadala ang magulang mismo sa feature. Walang laman kapag wala talagang
  /// pupuntahan — huwag mangakong may mabubuksan kung wala naman.
  final void Function(BuildContext host)? open;
}

/// Buod ng mga naidagdag sa bersyon 6.
///
/// Hindi ito lumalabas sa bagong user: kung katatapos lang niya ng onboarding,
/// lahat ay bago sa kanya at walang saysay ang "ano ang bago". Kaya wala rito
/// ang mga pagbabago sa onboarding mismo — tapos na iyon sa mga makakabasa
/// nito.
class WhatsNewSheet extends StatelessWidget {
  const WhatsNewSheet({super.key, required this.host});

  /// Ang screen na nagbukas nito. Kailangan para may mapagdaanan pa rin ang
  /// navigation matapos isara ang sheet.
  final BuildContext host;

  /// Bagong susi kada bersyon. Habang sinusubok, mabubuksan ito anumang oras
  /// mula sa Profile — hindi na kailangang palitan ito.
  static const String seenKey = 'has_seen_whats_new_v6';

  static void _go(BuildContext host, Widget screen) {
    Navigator.push(host, MaterialPageRoute(builder: (context) => screen));
  }

  /// Getter, hindi `final`: nasa loob ng bawat teksto ang `tr()`, kaya kailangan
  /// itong muling buuin sa tuwing bubuksan para tumugma sa piniling wika.
  static List<_NewThing> get _things => [
    _NewThing(
      Icons.grid_view_rounded,
      tr('Limang bahagi sa ibaba', 'Five sections at the bottom'),
      tr(
        'Ang Iskedyul at ang Milestones ay isang pindot na lang mula saanman '
            'sa app. Inalis na namin ang mga kaparehong card sa Bahay.',
        'Schedule and Milestones are one tap away from anywhere in the app. We '
            'removed the cards on Home that did the same thing.',
      ),
    ),
    _NewThing(
      Icons.people_alt_rounded,
      tr('Higit sa isang bata', 'More than one child'),
      tr(
        'May magulang na dalawa o tatlo ang anak na may pangangailangan, at '
            'isa lang ang kasya rito dati. Magdagdag na kayo sa Profile \u2014 '
            'hiwalay ang tala, bituin, at iskedyul ng bawat isa.',
        'Some parents here are raising two or three children with support '
            'needs, and only one fitted. You can add them in Profile now \u2014 each '
            'one keeps their own records, stars, and schedule.',
      ),
      open: (host) => _go(host, const ProfileScreen()),
    ),
    _NewThing(
      Icons.volunteer_activism_rounded,
      tr('Tulong sa gastos mula sa DSWD', 'Help with the cost from the DSWD'),
      tr(
        'Bagong gabay sa paghingi ng Guarantee Letter sa ilalim ng AICS: ano '
            'ang dalhin, ano ang mangyayari sa loob ng opisina, at saan pumunta. '
            'Puwede itong ibawas sa bayad sa pagsusuri at therapy.',
        'A new guide to asking for a guarantee letter under AICS: what to '
            'bring, what happens inside the office, and where to go. It can be '
            'taken off the cost of an assessment and therapy.',
      ),
      open: (host) => _go(host, const DswdAssistantScreen()),
    ),
    _NewThing(
      Icons.stairs_rounded,
      tr('Milestones mula sa CDC', 'Milestones from the CDC'),
      tr(
        'Ang listahan ng milestone ay galing na sa CDC, nasa Filipino at '
            'Ingles. May gabay na rin kung kailan mainam kumonsulta.',
        'The milestone list now comes from the CDC, in Filipino and English. '
            'There is also guidance on when it is worth talking to a doctor.',
      ),
      open: (host) => _go(host, const MilestonesScreen()),
    ),
    _NewThing(
      Icons.menu_book_rounded,
      tr('Mas marami sa Gabay sa Pag-unawa', 'More in the Understanding Guide'),
      tr(
        'Mula walo, dalawampu\'t lima na ang paksa \u2014 pandama, damdamin, pokus, '
            'at pakikisama. Dumami rin ang Mga Maaari Mong Mapansin, at may '
            'bahagi na para sa damdamin.',
        'From eight to twenty-five topics \u2014 senses, feelings, focus, and '
            'getting along. What You Might Notice grew too, and now has a '
            'section on feelings.',
      ),
      open: (host) => _go(host, const KnowledgeHubScreen()),
    ),
    _NewThing(
      Icons.local_offer_rounded,
      tr('Pokus ng suporta', 'Support focus'),
      tr(
        'Puwede mong lagyan ng tag ang anak mo sa Profile \u2014 ASD, ADHD, Speech '
            'Delay, o Sensory. Inuuna nito ang gabay, ang laro, at ang mungkahi '
            'sa iskedyul na bagay sa kanya.\n\nOpsyonal ito at hindi ito '
            'diagnosis. Nakikita mo pa rin ang lahat.',
        'You can tag your child in Profile \u2014 ASD, ADHD, Speech Delay, or '
            'Sensory. It brings the guidance, the play, and the schedule '
            'suggestions that suit them to the front.\n\nIt is optional and it '
            'is not a diagnosis. You still see everything.',
      ),
      open: (host) => _go(host, const ProfileScreen()),
    ),
    _NewThing(
      Icons.route_rounded,
      tr('Mas madaling magdagdag ng gawain', 'Adding a task is easier'),
      tr(
        'May dalawampu\'t tatlong handang gawain na may isang linyang '
            'paliwanag kung bakit ito nakakatulong. May kulay na rin ang mga '
            'icon, at makikita mo ang card bago mo pa ito i-save.',
        'There are twenty-three ready-made tasks, each with a line on why it '
            'might help. The icons have colour now, and you can see the card '
            'before you save it.',
      ),
      open: (host) => _go(host, const VisualScheduleScreen()),
    ),
    _NewThing(
      Icons.emoji_events_rounded,
      tr('May larawan na ang pabuya', 'Rewards have a picture now'),
      tr(
        'Hindi pa nakakabasa ang marami sa mga batang ito. May larawan na ang '
            'bawat pabuya para makilala nila ito, at makikita mo kung ilang '
            'bituin na ang naipon bago ka magtakda.',
        'Many of these children cannot read yet. Every reward carries a '
            'picture they can recognise, and you can see how many stars there '
            'already are before you set a price.',
      ),
      open: StarRewardDialog.show,
    ),
    _NewThing(
      Icons.wb_twilight_rounded,
      tr('Isang linya para sa iyo', 'A line for you'),
      tr(
        'Sa itaas ng Bahay, may paalalang para sa iyo \u2014 hindi sa bata. Iba ito '
            'kada araw. Ang buong app ay humihingi ng gagawin mo; ito lang ang '
            'hindi.',
        'At the top of Home there is a line for you, not for your child. It '
            'changes each day. Everything else here asks something of you; this '
            'is the one thing that does not.',
      ),
    ),
    _NewThing(
      Icons.groups_rounded,
      tr('Grupo ng mga magulang', 'Group of parents'),
      tr(
        'Nandiyan pa rin ang Facebook group ng mga gumagamit ng app. Sabihin '
            'ninyo kung ano ang kulang \u2014 galing doon ang halos lahat ng nasa '
            'listahang ito.',
        'The Facebook group for app users is still there. Tell us what is '
            'missing \u2014 nearly everything on this list came from it.',
      ),
      open: openAudhdGroup,
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
                    'Salamat sa pagsubok ng app. May pana sa dulo ang mga '
                        'mabubuksan agad mula rito.',
                    'Thank you for trying the app. The ones with an arrow at '
                        'the end can be opened right from here.',
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
    final open = thing.open;
    final row = Padding(
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
          if (open != null)
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
    );

    if (open == null) return row;

    return InkWell(
      onTap: () {
        Navigator.pop(sheetContext);
        open(host);
      },
      borderRadius: BorderRadius.circular(14),
      child: row,
    );
  }
}
