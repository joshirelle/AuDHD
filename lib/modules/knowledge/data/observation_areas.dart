import 'package:flutter/material.dart';

import '../../../core/i18n/language_controller.dart';
import '../../../core/models/guide_card.dart';

/// Isang paraan kung paano maaaring lumitaw ang isang bahagi ng paglaki.
class ObservationPattern {
  const ObservationPattern({
    required this.title,
    required this.body,
    required this.help,
  });

  final String title;

  /// Ang maaaring makita ng magulang.
  final String body;

  /// Ang maaaring subukan niya.
  final String help;
}

/// Isang bahagi ng paglaki at ang magkakaibang anyo nito.
class ObservationArea {
  const ObservationArea({
    required this.id,
    required this.category,
    required this.icon,
    required this.title,
    required this.intro,
    required this.patterns,
  });

  final String id;
  final GuideCategory category;
  final IconData icon;
  final String title;

  /// Bakit magkakaiba ang anyo sa bahaging ito.
  final String intro;

  final List<ObservationPattern> patterns;
}

/// Mga anyong maaaring mapansin ng magulang, isinaayos ayon sa bahagi.
///
/// Sinasadyang WALANG pangalan ng kondisyon dito. Hindi ito paghahambing ng
/// ADHD, autism, at AuDHD — hindi trabaho ng app ang magsabi kung alin ang
/// anak mo, at ang ganoong talahanayan ay nag-aanyaya sa magulang na mag-
/// diagnose ng sarili niyang anak. Ang layunin dito ay makilala niya ang
/// nakikita niya at maitala ito nang maayos para sa doktor.
///
/// Sumusunod sa parehong tatlong panuntunan ng `GuideCards`:
/// 1. Pananaw ng magulang, walang sanhi, diagnosis, o lunas.
/// 2. "Maaaring" at "may batang", hindi "lahat ng bata".
/// 3. Orihinal ang bawat pangungusap.
class ObservationAreas {
  const ObservationAreas._();

  /// Getter at hindi `const`: kailangang mabuo muli kapag nagpalit ng wika.
  static List<ObservationArea> get all => [
    ObservationArea(
      id: 'pakikisama',
      category: GuideCategory.social,
      icon: Icons.groups_rounded,
      title: tr('Pakikipag-usap at Pakikisama', 'Talking and Getting Along'),
      intro: tr(
        'Magkaiba ang paraan ng bawat bata sa pakikisalamuha. Dalawang batang '
            'parehong nahihirapan dito ay maaaring magmukhang magkasalungat.',
        'Every child connects differently. Two children who both find this '
            'hard can look like complete opposites.',
      ),
      patterns: [
        ObservationPattern(
          title: tr('Hindi makapaghintay ng turno', 'Cannot wait for a turn'),
          body: tr(
            'May batang nakakasingit sa usapan o nauunahan ang sagot bago pa '
                'matapos ang tanong. Hindi ito kawalan ng galang — mabilis lang '
                'lumabas ang nasa isip niya.',
            'Some children cut into conversations or answer before the question '
                'is finished. It is not rudeness — what is in their head simply '
                'comes out fast.',
          ),
          help: tr(
            'Bigyan siya ng senyas na makikita, gaya ng bagay na hawak ng '
                'kung sinong nagsasalita.',
            'Give them something they can see, like an object held by whoever '
                'is speaking.',
          ),
        ),
        ObservationPattern(
          title: tr('Hindi tumitingin sa mata', 'Does not meet your eyes'),
          body: tr(
            'May batang nakikinig nang husto pero hindi tumitingin. Sa iba, mas '
                'nakakatulong pa ngang huwag tumingin para makapag-isip.',
            'Some children listen closely without looking. For some, not looking '
                'is exactly what helps them think.',
          ),
          help: tr(
            'Huwag ipilit ang pagtingin sa mata. Tingnan kung sumasagot siya, '
                'hindi kung saan nakatingin.',
            'Do not insist on eye contact. Watch whether they answer, not where '
                'they are looking.',
          ),
        ),
        ObservationPattern(
          title: tr('Ang usapan pabalik-balik', 'Back-and-forth talking'),
          body: tr(
            'May batang nakakasagot at nakakapagpatuloy ng usapan nang '
                'pabalik-balik. May batang mabilis maubos ang masasabi, o '
                'lumilipat agad sa ibang paksa.',
            'Some children answer and keep a conversation going back and '
                'forth. Some run out of things to say quickly, or move straight '
                'to another topic.',
          ),
          help: tr(
            'Bilangin kung ilang beses kayong nakapagpalitan bago maputol, at '
                'itala mo. Ganitong detalye ang hinahanap ng doktor, at hindi '
                'mo ito matatandaan kung hindi mo isusulat.',
            'Count how many turns you take before it breaks off, and write it '
                'down. This is the kind of detail a doctor looks for, and you '
                'will not remember it unless you record it.',
          ),
        ),
        ObservationPattern(
          title: tr('Iisang paksa lang', 'Only one topic'),
          body: tr(
            'May batang paulit-ulit ang gustong pag-usapan. Madalas iyon ang '
                'pinakaligtas at pinaka-alam niyang paksa.',
            'Some children return to the same subject again and again. It is '
                'often the topic that feels safest and most known to them.',
          ),
          help: tr(
            'Bigyan muna ng oras ang paksa niya, tapos dahan-dahang idugtong '
                'ang sa iyo.',
            'Give their topic time first, then slowly join yours onto it.',
          ),
        ),
      ],
    ),
    ObservationArea(
      id: 'pokus',
      category: GuideCategory.focus,
      icon: Icons.bolt_rounded,
      title: tr('Pokus at Atensyon', 'Focus and Attention'),
      intro: tr(
        'Ang pokus ay hindi lang "meron" o "wala". Maaari itong masyadong '
            'mabilis lumipat, o masyadong mahirap ihinto.',
        'Focus is not simply present or absent. It can move too quickly, or be '
            'too hard to stop.',
      ),
      patterns: [
        ObservationPattern(
          title: tr('Mabilis lumipat', 'Moves on quickly'),
          body: tr(
            'May batang nagsisimula ng marami pero kaunti ang natatapos. '
                'Nakikita niya ang lahat sa paligid nang sabay-sabay.',
            'Some children start many things and finish few. They notice '
                'everything around them at once.',
          ),
          help: tr(
            'Isa-isahin ang hakbang. Isang gawain muna bago ang susunod.',
            'Break it into steps. One task at a time before the next.',
          ),
        ),
        ObservationPattern(
          title: tr('Sobrang lalim ng pokus', 'Focus that runs very deep'),
          body: tr(
            'May batang hindi ka talaga naririnig kapag tinatawag mo. Hindi '
                'siya nagbibingi-bingihan — nasa loob siya ng ginagawa niya.',
            'Some children truly do not hear you calling. They are not ignoring '
                'you — they are inside what they are doing.',
          ),
          help: tr(
            'Lapitan at haplusin muna bago magsalita. Magbigay ng babala bago '
                'ihinto ang ginagawa niya.',
            'Come close and touch their arm before speaking. Give a warning '
                'before stopping what they are doing.',
          ),
        ),
      ],
    ),
    ObservationArea(
      id: 'pandama',
      category: GuideCategory.sensory,
      icon: Icons.waves_rounded,
      title: tr('Pandama at Paggalaw', 'Senses and Movement'),
      intro: tr(
        'May batang naghahanap ng dagdag na pandama. May batang umiiwas dito. '
            'May batang parehong ginagawa, depende sa araw.',
        'Some children look for more sensory input. Some avoid it. Some do '
            'both, depending on the day.',
      ),
      patterns: [
        ObservationPattern(
          title: tr('Hinahanap ang galaw', 'Looks for movement'),
          body: tr(
            'May batang tumatakbo, umiikot, tumatalon, o humahawak sa lahat. '
                'Kailangan ng katawan niya ang dagdag na pakiramdam.',
            'Some children run, spin, jump, or touch everything. Their body is '
                'asking for more input.',
          ),
          help: tr(
            'Bigyan siya ng ligtas na paraan para makuha ito bago pa siya '
                'maghanap ng sarili niyang paraan.',
            'Give them a safe way to get it before they find their own way.',
          ),
        ),
        ObservationPattern(
          title: tr('Umiiwas sa sobra', 'Pulls away from too much'),
          body: tr(
            'May batang tinatakpan ang tainga, ayaw sa ilang tela, o umaatras '
                'sa maraming tao. Mas malakas ang dating ng paligid sa kanya.',
            'Some children cover their ears, refuse certain fabrics, or back '
                'away from crowds. The world arrives louder for them.',
          ),
          help: tr(
            'Bawasan ang dami bago pa lumala, hindi pagkatapos.',
            'Reduce what is coming in before it builds up, not after.',
          ),
        ),
        ObservationPattern(
          title: tr('Nagbabago-bago', 'Changes from day to day'),
          body: tr(
            'May batang naghahanap ngayon at umiiwas bukas. Karaniwan ito, at '
                'madalas nakadepende sa tulog, gutom, o pagod.',
            'Some children seek today and avoid tomorrow. This is common, and '
                'often depends on sleep, hunger, or tiredness.',
          ),
          help: tr(
            'Itala ang nakikita mo sa Tala ng Ugali. Ang pattern sa loob ng '
                'ilang linggo ang mas kapaki-pakinabang kaysa sa isang araw.',
            'Write down what you see in the Behavior Log. A pattern across a '
                'few weeks is far more useful than a single day.',
          ),
        ),
      ],
    ),
  ];
}
