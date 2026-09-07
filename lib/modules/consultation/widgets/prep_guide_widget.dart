import 'package:flutter/material.dart';

import '../../../core/i18n/language_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/kiko_card.dart';
import '../../dswd_assistant/dswd_assistant_screen.dart';

class PrepStep {
  const PrepStep({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;
}

/// Nilalaman ng gabay bago ang konsultasyon.
///
/// Sinasadyang walang tiyak na bilang ng buwan o oras dito. Ang alam natin ay
/// mahaba ang pila at matagal ang pagsusuri — hindi natin alam ang eksaktong
/// numero, at ang pekeng katiyakan ay naghahanda sa magulang sa maling bagay.
class PrepGuide {
  const PrepGuide._();

  static List<PrepStep> get bring => [
    PrepStep(
      icon: Icons.picture_as_pdf_rounded,
      title: tr('Ang ulat mula sa app', 'The report from this app'),
      body: tr(
        'Nasa Bahay ang "Ulat para sa Doktor". I-export ito bago pumunta at '
            'i-print kung kaya. Nandoon ang mood, ugali, pandama, at routine ng '
            'anak mo sa loob ng 30 o 90 araw — mahirap itong tandaan nang pasalita.',
        'The "Doctor Report" is on the Home screen. Export it before you go and '
            'print it if you can. It holds your child\'s moods, behaviour, '
            'senses, and routine over 30 or 90 days — things that are hard to '
            'recall out loud.',
      ),
    ),
    PrepStep(
      icon: Icons.videocam_rounded,
      title: tr('Maiikling video', 'Short videos'),
      body: tr(
        'Kung komportable ka, kumuha ng 15 hanggang 30 segundong video ng '
            'nakikita mo sa bahay — paraan ng pagsasalita, paggalaw, o kung ano '
            'ang hitsura ng mahirap na sandali. Madalas hindi ito nakikita ng '
            'doktor sa loob ng klinika.',
        'If you are comfortable, take 15 to 30 second videos of what you see at '
            'home — how they speak, how they move, or what a hard moment looks '
            'like. The doctor often will not see any of this inside the clinic.',
      ),
    ),
    PrepStep(
      icon: Icons.menu_book_rounded,
      title: tr('Baby book o health card', 'Baby book or health card'),
      body: tr(
        'Dalhin ang tala ng bakuna at ang mga naunang milestone. Dito nakikita '
            'ng doktor ang buong paglaki, hindi lang ang ngayon.',
        'Bring the immunisation record and the earlier milestones. This is where '
            'the doctor sees the whole of growing up, not only today.',
      ),
    ),
    PrepStep(
      icon: Icons.school_rounded,
      title: tr('Tala mula sa titser', 'Notes from the teacher'),
      body: tr(
        'Kung nag-aaral na, humingi ng maikling tala sa titser o daycare. '
            'Malaki ang halaga nito dahil ibang tao ang nakakita, sa ibang lugar.',
        'If they are already in school, ask the teacher or daycare for a short '
            'note. It carries weight because a different person saw it, in a '
            'different place.',
      ),
    ),
  ];

  static List<PrepStep> get expect => [
    PrepStep(
      icon: Icons.hourglass_bottom_rounded,
      title: tr('Mahaba ang pila', 'The wait is long'),
      body: tr(
        'Karaniwan sa Pilipinas ang maghintay ng ilang buwan para sa slot sa '
            'developmental pediatrician, lalo na sa pampublikong ospital. Hindi '
            'ito nangangahulugang huli ka na — ganito talaga ang sistema.',
        'Waiting several months for a slot with a developmental pediatrician is '
            'ordinary in the Philippines, especially in public hospitals. It '
            'does not mean you are late — this is simply how it works.',
      ),
    ),
    PrepStep(
      icon: Icons.schedule_rounded,
      title: tr('Mas mahaba sa karaniwan', 'Longer than a usual visit'),
      body: tr(
        'Hindi ito parang mabilisang check-up. Tatanungin ang buong kasaysayan '
            'ng paglaki ng bata, kaya maghanda ng oras at ng pagkain o gamit na '
            'makakatulong sa kanya habang naghihintay.',
        'This is not a quick check-up. You will be asked about the whole story '
            'of your child\'s growing up, so allow time and bring food or things '
            'that help them while waiting.',
      ),
    ),
    PrepStep(
      icon: Icons.help_outline_rounded,
      title: tr('Maaaring walang agad na sagot', 'There may be no answer yet'),
      body: tr(
        'Maaaring hindi sapat ang isang bisita. Minsan kailangan ng higit sa '
            'isa bago makumpleto ang pagsusuri. Hindi ito pagkaantala — bahagi '
            'ito ng maingat na pagsusuri.',
        'One visit may not be enough. Sometimes more than one is needed before '
            'the assessment is complete. This is not a delay — it is what a '
            'careful assessment looks like.',
      ),
    ),
    PrepStep(
      icon: Icons.favorite_rounded,
      title: tr('Habang naghihintay', 'While you wait'),
      body: tr(
        'Hindi kailangang maghintay ng papel bago magsimula. Ang mga gawain sa '
            'bahay, ang iskedyul, at ang pagtatala ay puwede nang gawin ngayon — '
            'at ang mismong naitala mo ang magpapaganda ng konsultasyon kapag '
            'dumating na ang araw.',
        'You do not need a piece of paper before you can start. The home '
            'activities, the routine, and the record-keeping can begin today — '
            'and what you record is exactly what will make the consultation '
            'better when the day comes.',
      ),
    ),
  ];
}

/// Isang seksyon ng gabay.
class PrepGuideWidget extends StatelessWidget {
  const PrepGuideWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        _buildHeading(
          icon: Icons.checklist_rounded,
          label: tr('Ano ang ihahanda', 'What to bring'),
        ),
        const SizedBox(height: 12),
        for (final step in PrepGuide.bring) ...[
          _buildStep(step, AppColors.mintGreen, AppColors.mintInk),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 12),
        _buildHeading(
          icon: Icons.visibility_rounded,
          label: tr('Ano ang aasahan', 'What to expect'),
        ),
        const SizedBox(height: 12),
        for (final step in PrepGuide.expect) ...[
          _buildStep(step, AppColors.skyBlueLight, AppColors.skyInk),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 12),
        _buildDswdLink(context),
      ],
    );
  }

  /// Ang tanong na kasunod ng "ano ang dalhin" ay madalas "saan kukuha ng
  /// pambayad". Dito ito sinasagot, hindi sa ibang bahagi ng app.
  Widget _buildDswdLink(BuildContext context) {
    return KikoCard(
      backgroundColor: AppColors.butterYellow,
      padding: const EdgeInsets.all(16),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DswdAssistantScreen()),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.volunteer_activism_rounded,
              size: 20,
              color: AppColors.butterInk,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('Tulong sa gastos (DSWD)', 'Help with the cost (DSWD)'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.butterInk,
                    fontFamily: 'Nunito',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  tr(
                    'May Guarantee Letter ang DSWD na puwedeng ibawas sa bayad '
                        'sa pagsusuri at therapy. Tingnan kung ano ang dalhin.',
                    'The DSWD has a guarantee letter that can be taken off the '
                        'cost of an assessment and therapy. See what to bring.',
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: AppColors.butterInk,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            size: 22,
            color: AppColors.butterInk,
          ),
        ],
      ),
    );
  }

  Widget _buildHeading({required IconData icon, required String label}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textDark),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
            color: AppColors.textDark,
            fontFamily: 'Nunito',
          ),
        ),
      ],
    );
  }

  Widget _buildStep(PrepStep step, Color background, Color ink) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(step.icon, size: 20, color: ink),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ink,
                    fontFamily: 'Nunito',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  step.body,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: ink,
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
