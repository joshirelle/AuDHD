import 'package:flutter/material.dart';

import '../../../core/i18n/language_controller.dart';
import '../../../core/models/guide_card.dart';

/// Nilalaman ng "Gabay sa Pag-unawa".
///
/// Nasa code at hindi sa Hive para maabot ng bawat update ang mga lumang user.
///
/// Tatlong panuntunan sa pagsulat dito, at bawat isa ay may dahilan:
/// 1. Pananaw ng magulang, hindi paliwanag ng doktor. Walang sanhi, walang
///    diagnosis, walang lunas.
/// 2. "Maaaring" at "may batang" — hindi "lahat ng bata" o "ito ang dahilan".
/// 3. Orihinal ang bawat pangungusap. Walang hiniram sa materyales ng ibang
///    organisasyon.
class GuideCards {
  const GuideCards._();

  /// Getter at hindi `const` na listahan: kailangang mabuo muli ang teksto
  /// kapag nagpalit ng wika ang magulang.
  ///
  /// Ang `id` at ang pagkakasunod-sunod ng `actionTips` ay susi sa Hive —
  /// huwag baguhin, huwag dagdagan, huwag bawasan.
  static List<GuideCard> get all => [
    GuideCard(
      id: 'ingay',
      category: GuideCategory.sensory,
      icon: Icons.volume_up_rounded,
      title: tr('Malakas na Ingay', 'Loud Noise'),
      summary: tr(
        'Mas malakas ang dating nito sa kanya kaysa sa atin.',
        'It sounds much louder to them than it does to us.',
      ),
      description: tr(
        'May mga batang mas matalas ang pandinig sa ilang tunog. Ang blender, '
            'palakpakan, o busina ay maaaring hindi lang basta maingay para sa '
            'kanya.\n\nKapag tinakpan niya ang tainga o umiyak, madalas iyon ang '
            'paraan niya para sabihing sobra na — hindi para magpapansin.',
        'Some children hear certain sounds more sharply. A blender, clapping, '
            'or a car horn may be more than just noisy to them.\n\nWhen they '
            'cover their ears or cry, that is often their way of saying it is '
            'too much — not a way of getting attention.',
      ),
      quote: tr(
        'Hindi siya pasaway. Nahihirapan siya.',
        'They are not being naughty. They are having a hard time.',
      ),
      actionTips: [
        tr(
          'Bawasan ang ingay bago pa ito lumala',
          'Turn the noise down before it builds up',
        ),
        tr(
          'Maghanda ng isang tahimik na sulok sa bahay',
          'Set up one quiet corner at home',
        ),
        tr(
          'Sabihan siya bago pumunta sa maingay na lugar',
          'Tell them before going somewhere noisy',
        ),
        tr(
          'Subukan ang headphones kapag sa mall o palengke',
          'Try headphones at the mall or the market',
        ),
      ],
    ),
    GuideCard(
      id: 'ilaw',
      category: GuideCategory.sensory,
      icon: Icons.light_mode_rounded,
      title: tr('Maliwanag na Ilaw', 'Bright Light'),
      summary: tr(
        'Nakakasilaw at nakakapagod sa mata niya ang ilang ilaw.',
        'Some lights glare and tire out their eyes.',
      ),
      description: tr(
        'Ang puting ilaw sa mall o ang kumukurap na fluorescent ay maaaring '
            'masakit sa mata ng ilang bata.\n\nHindi ito laging halata. Minsan '
            'ang tanging palatandaan ay pagkairita, pagtatago ng mukha, o biglang '
            'ayaw nang pumasok.',
        'The white lights in a mall or a flickering fluorescent lamp can hurt '
            'some children\'s eyes.\n\nIt is not always obvious. Sometimes the '
            'only sign is getting cranky, hiding their face, or suddenly not '
            'wanting to go in.',
      ),
      quote: tr(
        'Hindi siya sumusungit. Sumasakit ang mata niya.',
        'They are not being grumpy. Their eyes hurt.',
      ),
      actionTips: [
        tr(
          'Piliin ang mas malamlam na ilaw kapag gabi',
          'Choose dimmer lights in the evening',
        ),
        tr(
          'Umupo nang malayo sa kumukurap na ilaw',
          'Sit away from flickering lights',
        ),
        tr(
          'Magdala ng sombrero kapag matindi ang araw',
          'Bring a hat when the sun is harsh',
        ),
        tr(
          'Bigyan siya ng saglit na pahinga sa madilim na lugar',
          'Give them a short break somewhere dim',
        ),
      ],
    ),
    GuideCard(
      id: 'damit',
      category: GuideCategory.sensory,
      icon: Icons.checkroom_rounded,
      title: tr('Tekstura ng Damit', 'Clothing Textures'),
      summary: tr(
        'May damit na parang kumakagat sa balat niya.',
        'Some clothes feel like they bite their skin.',
      ),
      description: tr(
        'Ang tag sa likod ng damit, ang makapal na tela, o ang basang medyas '
            'ay maaaring hindi matiis ng ilang bata.\n\nHindi ito pagiging '
            'maarte. Para sa kanya, parang may kumakamot sa balat na hindi mo '
            'nakikita.',
        'The tag at the back of a shirt, thick fabric, or damp socks can be '
            'unbearable for some children.\n\nThis is not being fussy. To them, '
            'it feels like something is scratching their skin that you cannot '
            'see.',
      ),
      quote: tr(
        'Hindi siya maarte. Hindi niya talaga matiis.',
        'They are not being fussy. They really cannot bear it.',
      ),
      actionTips: [
        tr(
          'Gupitin ang tag sa likod ng damit',
          'Cut off the tag at the back of the shirt',
        ),
        tr(
          'Hayaan siyang pumili ng damit kung kaya niya',
          'Let them pick their clothes if they can',
        ),
        tr(
          'Labhan muna ang bagong damit bago isuot',
          'Wash new clothes before they wear them',
        ),
        tr(
          'Magdala ng pamalit kapag lumalabas kayo',
          'Bring a change of clothes when you go out',
        ),
      ],
    ),
    GuideCard(
      id: 'pagsabog',
      category: GuideCategory.emotion,
      icon: Icons.storm_rounded,
      title: tr('Pagsabog ng Damdamin', 'When Feelings Boil Over'),
      summary: tr(
        'Hindi ito pagrerebelde. Umapaw na ang kaya niyang tiisin.',
        'This is not defiance. They have gone past what they can take.',
      ),
      description: tr(
        'May pagkakataong sobra na ang naipon sa isang araw — ingay, gutom, '
            'pagod, o biglaang pagbabago ng plano. Kapag umapaw, madalas hindi na '
            'niya kontrolado ang sarili niyang katawan.\n\nKaiba ito sa '
            'pagmamaktol na may hinihinging bagay. Dito, kadalasan ay wala siyang '
            'hinihingi — hindi na lang niya kaya.',
        'Some days too much piles up — noise, hunger, tiredness, or a sudden '
            'change of plans. When it overflows, they often no longer have '
            'control over their own body.\n\nThis is different from fussing for '
            'something they want. Here, they are usually not asking for anything '
            '— they simply cannot take any more.',
      ),
      quote: tr(
        'Hindi niya ito ginagawa sa akin. Nangyayari ito sa kanya.',
        'They are not doing this to me. This is happening to them.',
      ),
      actionTips: [
        tr(
          'Bawasan ang salita — mas kaunti, mas mabuti',
          'Use fewer words — less is better',
        ),
        tr(
          'Alisin muna ang ingay at ang maraming tao',
          'Take away the noise and the crowd first',
        ),
        tr(
          'Manatiling malapit nang hindi humahawak agad',
          'Stay close without reaching out right away',
        ),
        tr(
          'Saka na ang mahabang usapan kapag kalmado na',
          'Save the long talk for when things are calm',
        ),
      ],
    ),
    GuideCard(
      id: 'paulit_ulit',
      category: GuideCategory.emotion,
      icon: Icons.repeat_rounded,
      title: tr('Kailangan ng Paulit-ulit', 'The Need for Repetition'),
      summary: tr(
        'Ang alam na niya ang nagpapakalma sa kanya.',
        'What they already know is what calms them.',
      ),
      description: tr(
        'Kapag alam ng bata kung ano ang susunod, mas kaunti ang kailangan '
            'niyang pangambahan.\n\nKaya ang biglaang pagbabago ng plano ay '
            'maaaring mabigat — parang nawalan siya ng lupang tinatapakan, kahit '
            'maliit lang ang pagbabago para sa atin.',
        'When a child knows what comes next, there is less for them to worry '
            'about.\n\nThat is why a sudden change of plans can be heavy — like '
            'the ground was pulled from under them, even if the change seems '
            'small to us.',
      ),
      quote: tr(
        'Hindi siya matigas ang ulo. Naghahanap siya ng katiyakan.',
        'They are not being stubborn. They are looking for certainty.',
      ),
      actionTips: [
        tr(
          'Sabihin ang plano bago pa ito mangyari',
          'Say the plan before it happens',
        ),
        tr(
          'Magbilang bago lumipat sa ibang gawain',
          'Count down before switching to something else',
        ),
        tr(
          'Panatilihin ang parehong pagkakasunod-sunod sa umaga',
          'Keep the same order every morning',
        ),
        tr(
          'Kapag may pagbabago, ipaalam nang maaga',
          'When something changes, tell them early',
        ),
      ],
    ),
    GuideCard(
      id: 'magsimula',
      category: GuideCategory.focus,
      icon: Icons.play_circle_outline_rounded,
      title: tr('Mahirap Magsimula', 'Hard to Get Started'),
      summary: tr(
        'Alam niya ang gagawin, pero mabigat ang unang hakbang.',
        'They know what to do, but the first step feels heavy.',
      ),
      description: tr(
        'May pagkakataong hindi ang gawain ang mabigat kundi ang pagsisimula '
            'nito.\n\nKahit gusto niyang gawin at alam niya kung paano, parang may '
            'humahadlang bago pa siya makagalaw.',
        'Sometimes it is not the task that is heavy but the starting of '
            'it.\n\nEven when they want to do it and know how, something seems '
            'to block them before they can move.',
      ),
      quote: tr(
        'Hindi siya tamad. Nasa pagsisimula ang hirap.',
        'They are not lazy. The hard part is starting.',
      ),
      actionTips: [
        tr(
          'Hatiin ang gawain sa maliliit na hakbang',
          'Break the task into small steps',
        ),
        tr(
          'Samahan siya sa unang isang minuto',
          'Stay with them for the first minute',
        ),
        tr(
          'Isang utos lang sa bawat pagkakataon',
          'Only one instruction at a time',
        ),
        tr(
          'Gumamit ng timer para may makitang hangganan',
          'Use a timer so there is a visible end',
        ),
      ],
    ),
    GuideCard(
      id: 'utos',
      category: GuideCategory.focus,
      icon: Icons.checklist_rounded,
      title: tr('Hindi Lahat Naaabutan', 'Not Everything Gets Through'),
      summary: tr(
        'Kapag maraming utos, minsan isa lang ang nahahawakan.',
        'With many instructions, sometimes only one sticks.',
      ),
      description: tr(
        'Kapag tatlo o apat na utos ang sabay-sabay, maaaring isa lang ang '
            'maabutan niya.\n\nHindi ito pagsuway. Narinig niya, hindi lang lahat '
            'nakakapit nang sabay-sabay.',
        'When three or four instructions come at once, they may only catch '
            'one.\n\nThis is not disobedience. They heard you — not all of it '
            'sticks at the same time.',
      ),
      quote: tr(
        'Hindi niya ako binabalewala. Hindi lang lahat naabutan.',
        'They are not ignoring me. They just did not catch it all.',
      ),
      actionTips: [
        tr('Isa-isahin ang utos', 'Give instructions one at a time'),
        tr(
          'Patingnan muna siya bago magsalita',
          'Get their attention before you speak',
        ),
        tr(
          'Gumamit ng larawan o nakasulat na listahan',
          'Use pictures or a written list',
        ),
        tr(
          'Pasabihin sa kanya ang narinig niya',
          'Ask them to say back what they heard',
        ),
      ],
    ),
    GuideCard(
      id: 'tingin',
      category: GuideCategory.social,
      icon: Icons.visibility_off_rounded,
      title: tr('Hindi Tumitingin sa Mata', 'Not Looking You in the Eye'),
      summary: tr(
        'May batang mas nakikinig kapag hindi nakatingin.',
        'Some children listen better when they are not looking.',
      ),
      description: tr(
        'Para sa ilang bata, mabigat ang tumingin sa mata habang nakikinig — '
            'parang dalawang bagay na sabay na ginagawa.\n\nMinsan, ang hindi '
            'pagtingin ang mismong paraan niya para mas maintindihan ka.',
        'For some children, meeting your eyes while listening is heavy — like '
            'doing two things at once.\n\nSometimes, looking away is exactly how '
            'they understand you better.',
      ),
      quote: tr(
        'Nakikinig siya. Iba lang ang paraan niya.',
        'They are listening. Their way is just different.',
      ),
      actionTips: [
        tr(
          'Huwag piliting tumingin sa mata',
          'Do not force them to look you in the eye',
        ),
        tr(
          'Mag-usap habang may ginagawang iba',
          'Talk while doing something else',
        ),
        tr(
          'Tabi-tabi kayong umupo kaysa magkaharap',
          'Sit side by side instead of facing each other',
        ),
        tr(
          'Hanapin ang ibang senyales na nakikinig siya',
          'Look for other signs that they are listening',
        ),
      ],
    ),
  ];

  static GuideCard? byId(String id) {
    for (final card in all) {
      if (card.id == id) return card;
    }
    return null;
  }

  static List<GuideCard> inCategory(GuideCategory? category) =>
      category == null
      ? all
      : all.where((card) => card.category == category).toList();
}
