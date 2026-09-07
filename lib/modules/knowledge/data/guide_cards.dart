import 'package:flutter/material.dart';

import '../../../core/i18n/language_controller.dart';
import '../../../core/models/guide_card.dart';
import '../../../core/utils/support_focus_split.dart';
import '../../../data/models/child_profile.dart';

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
      relevantTo: const {SupportFocus.sensorySensitivity, SupportFocus.asd},
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
      relevantTo: const {SupportFocus.sensorySensitivity, SupportFocus.asd},
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
      relevantTo: const {SupportFocus.sensorySensitivity, SupportFocus.asd},
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
      id: 'amoy',
      category: GuideCategory.sensory,
      relevantTo: const {SupportFocus.sensorySensitivity, SupportFocus.asd},
      icon: Icons.air_rounded,
      title: tr('Amoy', 'Smells'),
      summary: tr(
        'May amoy na hindi niya kayang balewalain.',
        'Some smells are impossible for them to ignore.',
      ),
      description: tr(
        'Ang pabango ng bisita, ang iniihaw na ulam, o ang amoy ng palengke ay '
            'maaaring humigit sa kaya niya. Minsan nauuwi ito sa pagdighay, '
            'pagsusuka, o biglang ayaw kumain.\n\nHindi ito pagiging maselan. '
            'May ilong na mas maraming nahahalata.',
        'A visitor\'s perfume, something grilling, or the smell of the market '
            'can be more than they can take. Sometimes it ends in gagging or a '
            'sudden refusal to eat.\n\nThis is not fussiness. Some noses simply '
            'pick up more.',
      ),
      quote: tr(
        'Hindi siya maarte. Mas marami siyang naaamoy.',
        'They are not being fussy. They smell more than you do.',
      ),
      actionTips: [
        tr(
          'Buksan ang bintana habang nagluluto',
          'Open a window while you are cooking',
        ),
        tr(
          'Pumili ng sabon at pampalambot na walang matapang na amoy',
          'Choose soap and softener without a strong scent',
        ),
        tr(
          'Magdala ng bagay na pamilyar ang amoy',
          'Bring something that smells familiar',
        ),
        tr(
          'Lumabas saglit kapag sobra na',
          'Step outside for a moment when it is too much',
        ),
      ],
    ),
    GuideCard(
      id: 'pagkain',
      category: GuideCategory.sensory,
      relevantTo: const {SupportFocus.sensorySensitivity, SupportFocus.asd},
      icon: Icons.restaurant_rounded,
      title: tr('Tekstura ng Pagkain', 'Food Textures'),
      summary: tr(
        'Hindi laging lasa ang dahilan \u2014 minsan ang pakiramdam sa bibig.',
        'It is not always the taste \u2014 sometimes it is how it feels.',
      ),
      description: tr(
        'May batang iilang pagkain lang ang kinakain, o hindi kayang magdikit '
            'ang ulam at kanin sa plato. Maaaring ang basa, malagkit, o may '
            'butil na tekstura ang hindi niya kaya \u2014 hindi ang '
            'lasa.\n\nMabigat ito sa hapag, lalo na kapag may nagsasabing '
            'pinalayaw daw siya.',
        'Some children eat only a few foods, or cannot have the ulam touching '
            'the rice. It may be the wet, sticky, or grainy feel they cannot '
            'manage \u2014 not the flavour.\n\nThis is heavy at the table, '
            'especially when someone says you have spoiled them.',
      ),
      quote: tr(
        'Hindi siya pihikan. Iba ang dating nito sa bibig niya.',
        'They are not picky. It lands differently in their mouth.',
      ),
      actionTips: [
        tr(
          'Ihiwalay ang ulam sa kanin sa plato',
          'Keep the ulam and the rice apart on the plate',
        ),
        tr(
          'Ilagay ang bagong pagkain sa tabi, walang pilitan',
          'Put the new food beside them with no pressure',
        ),
        tr(
          'Panatilihin ang isang pagkaing tiyak niyang kakainin',
          'Keep one food you know they will eat',
        ),
        tr(
          'Sabihin sa doktor kung paunti nang paunti ang kinakain',
          'Tell the doctor if the list keeps getting shorter',
        ),
      ],
    ),
    GuideCard(
      id: 'gupit',
      category: GuideCategory.sensory,
      relevantTo: const {SupportFocus.sensorySensitivity, SupportFocus.asd},
      icon: Icons.content_cut_rounded,
      title: tr('Gupit, Sipilyo, at Kuko', 'Haircuts, Brushing, and Nails'),
      summary: tr(
        'May gawaing araw-araw na nauuwi sa labanan.',
        'Some everyday things turn into a fight.',
      ),
      description: tr(
        'Ang gupit, ang pagsisipilyo, at ang pagputol ng kuko ay may kasamang '
            'haplos, tunog, at panginginig na hindi niya pinili. Para sa ilang '
            'bata, hindi lang ito nakakainis \u2014 nakakatakot.\n\nMadalas hindi '
            'ang gawain ang mabigat kundi ang hindi malaman kung kailan ito '
            'matatapos.',
        'A haircut, brushing teeth, and cutting nails all come with touch, '
            'sound, and buzzing they did not choose. For some children that is '
            'not just annoying \u2014 it is frightening.\n\nOften the hard part is '
            'not the task but not knowing when it will end.',
      ),
      quote: tr(
        'Hindi siya pasaway. Hindi niya alam kung kailan titigil.',
        'They are not being difficult. They do not know when it stops.',
      ),
      actionTips: [
        tr(
          'Magbilang nang malakas para may makitang katapusan',
          'Count out loud so there is a visible end',
        ),
        tr(
          'Hayaan siyang humawak muna ng sipilyo o gunting',
          'Let them hold the brush or the clippers first',
        ),
        tr(
          'Gawin ito sa parehong oras araw-araw',
          'Do it at the same time every day',
        ),
        tr(
          'Humanap ng barberong papayag maghintay',
          'Find a barber who is willing to wait',
        ),
      ],
    ),
    GuideCard(
      id: 'paikot',
      category: GuideCategory.sensory,
      relevantTo: const {
        SupportFocus.sensorySensitivity,
        SupportFocus.adhd,
        SupportFocus.asd,
      },
      icon: Icons.autorenew_rounded,
      title: tr('Umiikot at Tumatalon', 'Spinning and Jumping'),
      summary: tr(
        'May katawang humihingi ng galaw para maging panatag.',
        'Some bodies ask for movement in order to settle.',
      ),
      description: tr(
        'May batang umiikot hanggang mahilo, tumatalon sa sopa, o sadyang '
            'bumabangga sa unan. Mukha itong panggugulo pero madalas ito ang '
            'paraan niya para kumalma.\n\nKapag tuluyang pinigilan, minsan '
            'lumalala pa ang kabalisahan.',
        'Some children spin until they are dizzy, jump on the sofa, or throw '
            'themselves into cushions on purpose. It looks like mischief but it '
            'is often how they settle.\n\nWhen it is stopped completely, the '
            'restlessness sometimes gets worse.',
      ),
      quote: tr(
        'Hindi siya nanggugulo. Naghahanap siya ng ginhawa.',
        'They are not being wild. They are looking for relief.',
      ),
      actionTips: [
        tr(
          'Magbigay ng ligtas na lugar para tumalon',
          'Give them a safe place to jump',
        ),
        tr(
          'Subukan ang mabigat na gawain: magbuhat, magtulak',
          'Try heavy work: carrying, pushing',
        ),
        tr(
          'Magpagalaw muna bago ang gawaing nakaupo',
          'Let them move before anything that needs sitting',
        ),
        tr(
          'Huwag gawing parusa ang pagpapatigil',
          'Do not turn stopping into a punishment',
        ),
      ],
    ),
    GuideCard(
      id: 'pagsabog',
      category: GuideCategory.emotion,
      relevantTo: const {SupportFocus.asd, SupportFocus.adhd},
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
      relevantTo: const {SupportFocus.asd},
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
      id: 'pagbabago',
      category: GuideCategory.emotion,
      relevantTo: const {SupportFocus.asd, SupportFocus.adhd},
      icon: Icons.swap_horiz_rounded,
      title: tr('Biglaang Pagbabago', 'A Sudden Change of Plan'),
      summary: tr(
        'Ang binagong plano ay parang nawalang sahig.',
        'A changed plan can feel like the floor moving.',
      ),
      description: tr(
        'Sinabi ninyong pupunta sa park, tapos umulan. Para sa ilang bata, '
            'hindi ito basta pagkadismaya \u2014 nawala ang larawang hawak niya, at '
            'wala siyang maipapalit dito.\n\nMinsan mas mabigat ang mismong '
            'pagbabago kaysa sa hindi natuloy.',
        'You said you were going to the park, and then it rained. For some '
            'children this is not simply disappointment \u2014 the picture they '
            'were holding is gone and there is nothing to put in its '
            'place.\n\nSometimes the change itself weighs more than what was '
            'lost.',
      ),
      quote: tr(
        'Hindi ang park ang iniiyakan niya. Ang pagbabago.',
        'They are not crying about the park. They are crying about the change.',
      ),
      actionTips: [
        tr(
          'Sabihin ang plano at kung ano ang maaaring bumago dito',
          'Say the plan and what might change it',
        ),
        tr(
          'Magbigay ng babala bago ang paglipat',
          'Give a warning before the switch',
        ),
        tr(
          'Mag-alok ng dalawang pamalit, hindi bukas na tanong',
          'Offer two replacements, not an open question',
        ),
        tr(
          'Bigyan siya ng oras bago mo siya kausapin',
          'Give them time before you talk it through',
        ),
      ],
    ),
    GuideCard(
      id: 'pagkatalo',
      category: GuideCategory.emotion,
      relevantTo: const {SupportFocus.asd, SupportFocus.adhd},
      icon: Icons.emoji_events_outlined,
      title: tr('Pagkatalo at Pagkakamali', 'Losing and Getting It Wrong'),
      summary: tr(
        'Ang maliit na mali ay maaaring dumating na malaki.',
        'A small mistake can land like a big one.',
      ),
      description: tr(
        'May batang umiiyak kapag natalo sa snakes and ladders, o pumupunit ng '
            'papel dahil sa isang maling titik. Hindi ito kawalan ng '
            'pagkamaginoo \u2014 nagiging sukatan ng sarili ang isang '
            'pagkakamali.\n\nMinsan mas madali nang huwag subukan kaysa '
            'magkamali ulit.',
        'Some children cry over losing snakes and ladders, or tear up the page '
            'over one wrong letter. This is not poor sportsmanship \u2014 one '
            'mistake starts to stand for who they are.\n\nSometimes it becomes '
            'easier not to try than to get it wrong again.',
      ),
      quote: tr(
        'Hindi siya sumusuko. Natatakot siyang magkamali.',
        'They are not giving up. They are afraid of getting it wrong.',
      ),
      actionTips: [
        tr(
          'Ipakita ang sarili mong pagkakamali nang malakas',
          'Show your own mistakes out loud',
        ),
        tr(
          'Purihin ang pagsubok, hindi ang pagkatama',
          'Praise the trying, not the getting it right',
        ),
        tr(
          'Maglaro ng walang panalo at walang talo',
          'Play games with no winner and no loser',
        ),
        tr('Iwasan ang "madali lang iyan"', 'Avoid saying it is easy'),
      ],
    ),
    GuideCard(
      id: 'pagod_sa_uwi',
      category: GuideCategory.emotion,
      relevantTo: const {SupportFocus.asd, SupportFocus.adhd},
      icon: Icons.home_rounded,
      title: tr('Pagsabog Pagkauwi', 'The Meltdown at the Door'),
      summary: tr(
        'Maayos sa eskwela, sumasabog pagdating sa bahay.',
        'Fine at school, and then it all comes out at home.',
      ),
      description: tr(
        'Pare-pareho ang sinasabi ng maraming magulang: mabait daw sa klase, '
            'pero pagsara ng pinto sa bahay ay iyakan agad. Buong araw niyang '
            'hinawakan ang sarili sa lugar na hindi ligtas '
            'bumitaw.\n\nMadalas, ang pagsabog sa bahay ay tanda na dito siya '
            'ligtas \u2014 wala nang natitirang maihahawak pa.',
        'Many parents say the same thing: the teacher reports a lovely child, '
            'then the door closes at home and the crying starts. They held '
            'themselves together all day somewhere it did not feel safe to let '
            'go.\n\nThe meltdown at home is often a sign that home is where it '
            'is safe \u2014 there is nothing left to hold.',
      ),
      quote: tr(
        'Hindi ka niya sinusubukan. Dito lang siya ligtas bumitaw.',
        'They are not testing you. Home is the only place safe enough.',
      ),
      actionTips: [
        tr(
          'Bigyan siya ng tahimik na oras bago ang mga tanong',
          'Give them quiet time before any questions',
        ),
        tr(
          'Ihanda ang meryenda bago pa siya dumating',
          'Have a snack ready before they arrive',
        ),
        tr(
          'Huwag agad magtanong tungkol sa eskwela',
          'Hold off on asking about school right away',
        ),
        tr(
          'Sabihin sa titser kung ano ang nakikita mo sa bahay',
          'Tell the teacher what you see at home',
        ),
      ],
    ),
    GuideCard(
      id: 'hindi_masabi',
      category: GuideCategory.emotion,
      relevantTo: const {SupportFocus.asd, SupportFocus.speechDelay},
      icon: Icons.psychology_alt_rounded,
      title: tr('Hindi Masabi ang Nararamdaman', 'No Words for the Feeling'),
      summary: tr(
        'Minsan wala siyang pangalan sa nararamdaman niya.',
        'Sometimes they have no name for what they feel.',
      ),
      description: tr(
        'Tinatanong natin kung bakit siya umiiyak at iyak pa rin ang sagot. '
            'May batang nararamdaman ang bigat pero walang salitang maidudugtong '
            'dito.\n\nMinsan ang "masakit ang tiyan ko" ang tanging paraan niya '
            'para sabihing kinakabahan siya.',
        'We ask why they are crying and the answer is more crying. Some '
            'children feel the weight but have no word to attach to '
            'it.\n\nSometimes "my tummy hurts" is the only way they can say '
            'they are anxious.',
      ),
      quote: tr(
        'Hindi siya tumatanggi. Wala pa siyang salita para dito.',
        'They are not refusing to answer. They have no word for it yet.',
      ),
      actionTips: [
        tr(
          'Pangalanan ang nakikita mo: "mukhang pagod ka"',
          'Name what you see: "you look tired"',
        ),
        tr(
          'Mag-alok ng dalawang salita kaysa bukas na tanong',
          'Offer two words instead of an open question',
        ),
        tr(
          'Gumamit ng mukha o larawan kaysa salita',
          'Use faces or pictures instead of words',
        ),
        tr(
          'Itala ang oras at kung ano ang nauna rito',
          'Write down the time and what came before it',
        ),
      ],
    ),
    GuideCard(
      id: 'magsimula',
      category: GuideCategory.focus,
      relevantTo: const {SupportFocus.adhd},
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
      relevantTo: const {SupportFocus.adhd, SupportFocus.speechDelay},
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
      id: 'tapusin',
      category: GuideCategory.focus,
      relevantTo: const {SupportFocus.adhd},
      icon: Icons.flag_rounded,
      title: tr('Pagtatapos ng Sinimulan', 'Finishing What Was Started'),
      summary: tr(
        'Madaling magsimula. Ang dulo ang mahirap.',
        'Starting is easy. The end is the hard part.',
      ),
      description: tr(
        'May batang nagsisimula ng tatlong bagay sa isang hapon at walang '
            'natatapos. Nakalimutan ba niya? Hindi laging \u2014 minsan nawawala '
            'lang ang sinulid sa gitna.\n\nAng malaking gawain ay parang '
            'hagdanang hindi mo makita ang dulo.',
        'Some children begin three things in one afternoon and finish none of '
            'them. Did they forget? Not always \u2014 sometimes the thread simply '
            'drops halfway.\n\nA big task can feel like a staircase with no '
            'visible top.',
      ),
      quote: tr(
        'Hindi siya tamad. Nawawala ang sinulid sa gitna.',
        'They are not lazy. The thread drops halfway.',
      ),
      actionTips: [
        tr(
          'Hatiin ang gawain sa dalawa o tatlong bahagi',
          'Break the task into two or three parts',
        ),
        tr(
          'Ipakita kung ano ang hitsura ng tapos',
          'Show them what finished looks like',
        ),
        tr(
          'Balikan siya sa gitna, hindi sa dulo',
          'Check in during, not at the end',
        ),
        tr('Isang gawain lang sa mesa', 'One task on the table at a time'),
      ],
    ),
    GuideCard(
      id: 'oras',
      category: GuideCategory.focus,
      relevantTo: const {SupportFocus.adhd, SupportFocus.asd},
      icon: Icons.timer_rounded,
      title: tr('Pakiramdam sa Oras', 'How Long Five Minutes Is'),
      summary: tr(
        'Walang hugis ang "limang minuto" para sa kanya.',
        '"Five more minutes" has no shape for them.',
      ),
      description: tr(
        'Sinasabi nating limang minuto na lang at parang hindi narinig. Para sa '
            'ilang bata, walang hitsura ang oras hangga\'t hindi ito '
            'nakikita.\n\nDito nanggagaling ang maraming away sa umaga at sa '
            'oras ng tulog \u2014 hindi pagsuway kundi hindi pagkakilala kung gaano '
            'katagal ang katagal.',
        'We say five more minutes and it seems not to land. For some children, '
            'time has no shape until they can see it.\n\nThis sits behind a lot '
            'of morning and bedtime fights \u2014 not defiance, but not knowing how '
            'long long is.',
      ),
      quote: tr(
        'Hindi ka niya binabalewala. Hindi niya nakikita ang oras.',
        'They are not ignoring you. They cannot see the time.',
      ),
      actionTips: [
        tr(
          'Gumamit ng timer na nakikita ang natitira',
          'Use a timer they can watch run down',
        ),
        tr(
          'Bilangin ang gawain, hindi ang minuto',
          'Count tasks instead of minutes',
        ),
        tr(
          'Magbabala sa gitna, hindi lang sa dulo',
          'Warn them partway, not only at the end',
        ),
        tr(
          'Panatilihin ang parehong pagkakasunod araw-araw',
          'Keep the same order every day',
        ),
      ],
    ),
    GuideCard(
      id: 'sobrang_pokus',
      category: GuideCategory.focus,
      relevantTo: const {SupportFocus.adhd, SupportFocus.asd},
      icon: Icons.center_focus_strong_rounded,
      title: tr('Sobrang Pokus', 'Locked On'),
      summary: tr(
        'Minsan sobrang lalim ng pokus na hindi ka na niya naririnig.',
        'Sometimes the focus runs so deep they cannot hear you.',
      ),
      description: tr(
        'Ang batang hindi makapagtuon sa assignment ay maaaring tatlong oras na '
            'nakatutok sa Lego nang hindi kumakain. Nakakalito ito sa magulang \u2014 '
            'kaya naman pala.\n\nHindi laging kaya niyang piliin kung saan '
            'mapupunta ang pokus. At kapag nakapasok na, mahirap ding lumabas.',
        'The child who cannot settle on homework may spend three hours on Lego '
            'without eating. It is confusing to a parent \u2014 so they can focus '
            'after all.\n\nWhere the focus lands is not always a choice. And '
            'once it is in, getting back out is hard too.',
      ),
      quote: tr(
        'Hindi niya pinipili kung kailan lalalim ang pokus.',
        'They do not get to choose when the focus goes deep.',
      ),
      actionTips: [
        tr(
          'Lapitan siya bago magsalita, huwag tumawag mula sa kabilang kuwarto',
          'Go to them before speaking, do not call from another room',
        ),
        tr(
          'Magbigay ng babala bago siya putulin',
          'Give a warning before you interrupt',
        ),
        tr(
          'Gamitin ang malalim na pokus sa gawaing kailangan',
          'Put the deep focus to work where it is needed',
        ),
        tr('Alalahanin ang pagkain at tubig', 'Keep an eye on food and water'),
      ],
    ),
    GuideCard(
      id: 'kilos',
      category: GuideCategory.focus,
      relevantTo: const {SupportFocus.adhd},
      icon: Icons.directions_run_rounded,
      title: tr('Hindi Mapakali sa Upuan', 'Cannot Sit Still'),
      summary: tr(
        'Minsan kailangan niyang gumalaw para makinig.',
        'Sometimes moving is how they listen.',
      ),
      description: tr(
        'Ang batang nakatikwas ang silya, kumakalampag ang paa, o nakatayo '
            'habang kumakain ay madalas napapagalitan sa hapag at sa '
            'klase.\n\nPero may batang mas nakukuha ang sinasabi mo habang '
            'gumagalaw kaysa habang pinipilit manatiling tahimik.',
        'The child tipping the chair, tapping a foot, or standing up during '
            'meals gets told off at the table and in class.\n\nBut some children '
            'take in more of what you say while moving than while being held '
            'still.',
      ),
      quote: tr(
        'Hindi siya hindi nakikinig. Ganito siya nakikinig.',
        'They are not failing to listen. This is them listening.',
      ),
      actionTips: [
        tr(
          'Payagan ang paggalaw kung wala namang naaabala',
          'Allow the movement when it disturbs no one',
        ),
        tr(
          'Bigyan siya ng maliit na hawakan sa kamay',
          'Give them something small to hold',
        ),
        tr(
          'Maikling pahinga sa gitna ng gawain',
          'Short breaks in the middle of a task',
        ),
        tr(
          'Sabihin sa titser kung ano ang nakakatulong',
          'Tell the teacher what helps',
        ),
      ],
    ),
    GuideCard(
      id: 'tingin',
      category: GuideCategory.social,
      relevantTo: const {SupportFocus.asd},
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
    GuideCard(
      id: 'pagbati',
      category: GuideCategory.social,
      relevantTo: const {SupportFocus.asd, SupportFocus.speechDelay},
      icon: Icons.waving_hand_rounded,
      title: tr('Pagbati at Paalam', 'Greetings and Goodbyes'),
      summary: tr(
        'Mabigat ang mano at beso kapag hindi mo alam ang susunod.',
        'A greeting is heavy when you do not know what comes next.',
      ),
      description: tr(
        'Sa atin, halos laging may hinihinging mano, beso, o "hi po" sa bagong '
            'dating. Para sa ilang bata, sabay-sabay itong hamon: hawakan ang '
            'kamay ng hindi pamilyar, tumingin, at magsalita — lahat sa loob ng '
            'ilang segundo.\n\nKapag nagtago siya sa likod mo o hindi kumibo, '
            'madalas hindi iyon kawalan ng galang.',
        'In our homes, someone arriving almost always calls for mano, a kiss on '
            'the cheek, or a "hi po". For some children that is several hard '
            'things at once: take a hand they do not know, look up, and speak — '
            'all within seconds.\n\nWhen they hide behind you or go quiet, it is '
            'usually not rudeness.',
      ),
      quote: tr(
        'Hindi siya walang galang. Hindi lang niya alam ang susunod.',
        'They are not being rude. They just do not know what comes next.',
      ),
      actionTips: [
        tr(
          'Sabihin kung sino ang darating bago sila dumating',
          'Say who is coming before they arrive',
        ),
        tr(
          'Magsanay ng isang maikling pagbati sa bahay',
          'Practise one short greeting at home',
        ),
        tr(
          'Payagan ang kaway o tango kapalit ng mano',
          'Let a wave or a nod stand in for mano',
        ),
        tr(
          'Ipaliwanag ito sa kamag-anak nang mahinahon',
          'Explain it to relatives calmly',
        ),
      ],
    ),
    GuideCard(
      id: 'pagsali',
      category: GuideCategory.social,
      relevantTo: const {SupportFocus.asd},
      icon: Icons.group_add_rounded,
      title: tr('Paglapit sa Laro', 'Joining In'),
      summary: tr(
        'Minsan katabi muna bago kasama.',
        'Sometimes it is beside first, together later.',
      ),
      description: tr(
        'May batang matagal munang nanonood bago sumali, o naglalaro sa tabi ng '
            'iba nang hindi nakikipag-usap. Madalas itong napagkakamalang ayaw '
            'makisama.\n\nMaaaring paraan niya ito ng pag-aaral — binabasa muna '
            'niya ang patakaran bago siya pumasok.',
        'Some children watch for a long while before joining, or play right '
            'beside others without talking to them. This often gets read as not '
            'wanting to join in.\n\nIt may be how they learn — they read the '
            'rules first before stepping in.',
      ),
      quote: tr(
        'Nanonood siya, hindi umiiwas.',
        'They are watching, not avoiding.',
      ),
      actionTips: [
        tr(
          'Bigyan siya ng oras na manood, huwag itulak',
          'Give them time to watch, do not push',
        ),
        tr(
          'Magsimula sa isang bata bago sa grupo',
          'Start with one child before a group',
        ),
        tr(
          'Pumili ng larong may malinaw na patakaran',
          'Choose a game with clear rules',
        ),
        tr(
          'Pansinin ang paglapit, kahit sandali lang',
          'Notice the stepping in, even if it is brief',
        ),
      ],
    ),
    GuideCard(
      id: 'biro',
      category: GuideCategory.social,
      relevantTo: const {SupportFocus.asd, SupportFocus.speechDelay},
      icon: Icons.chat_bubble_outline_rounded,
      title: tr('Biro at Patalinghaga', 'Jokes and Figures of Speech'),
      summary: tr(
        'May batang tuwid ang pagkarinig sa sinasabi natin.',
        'Some children hear what we say exactly as it is.',
      ),
      description: tr(
        'Ang "isang taon na kitang hinihintay" o ang "kakainin kita" ay '
            'maaaring intindihin nang tuwiran. Minsan nauuwi ito sa pagkalito, '
            'minsan sa takot.\n\nHindi ito kakulangan sa talino. Iba lang ang '
            'daan ng salita papasok sa kanya.',
        '"I have been waiting a year for you" or "I could eat you up" may be '
            'taken exactly as said. Sometimes that ends in confusion, sometimes '
            'in fear.\n\nThis is not about being slow. Words simply take a '
            'different road in.',
      ),
      quote: tr(
        'Hindi siya mahina. Tuwid lang siyang makinig.',
        'They are not slow. They just listen straight.',
      ),
      actionTips: [
        tr(
          'Sabihin ang ibig sabihin mo nang diretso',
          'Say what you mean plainly',
        ),
        tr(
          'Ipaliwanag ang biro kapag nalito siya',
          'Explain the joke when they look lost',
        ),
        tr(
          'Iwasan ang pananakot na hindi naman totoo',
          'Avoid threats you do not mean',
        ),
        tr(
          'Turuan siya ng ilang karaniwang kasabihan',
          'Teach them a few common sayings',
        ),
      ],
    ),
    GuideCard(
      id: 'handaan',
      category: GuideCategory.social,
      relevantTo: const {
        SupportFocus.asd,
        SupportFocus.sensorySensitivity,
        SupportFocus.adhd,
      },
      icon: Icons.celebration_rounded,
      title: tr('Handaan at Maraming Tao', 'Parties and Crowds'),
      summary: tr(
        'Ang saya ng lahat ay maaaring sobra para sa kanya.',
        'What is fun for everyone else can be too much for them.',
      ),
      description: tr(
        'Ang binyag, kaarawan, o reunion ay dumarating nang sabay-sabay: '
            'maraming boses, bagong amoy, mahigpit na yakap, at walang tiyak na '
            'oras ng uwian.\n\nMaaaring maayos siya sa unang oras at biglang '
            'hindi na. Hindi iyon kapritso — naubos lang ang kaya niya.',
        'A christening, a birthday, or a reunion arrives all at once: many '
            'voices, new smells, tight hugs, and no fixed time to go '
            'home.\n\nThey may be fine for the first hour and then suddenly not. '
            'That is not a tantrum — they simply ran out.',
      ),
      quote: tr(
        'Hindi niya sinisira ang saya. Naubusan lang siya.',
        'They are not spoiling the fun. They have run out.',
      ),
      actionTips: [
        tr(
          'Pag-usapan ang pupuntahan bago umalis ng bahay',
          'Talk through where you are going before you leave',
        ),
        tr(
          'Maghanap ng isang tahimik na sulok pagdating',
          'Find one quiet corner when you arrive',
        ),
        tr(
          'Umalis nang maaga kaysa hintayin ang iyakan',
          'Leave early rather than wait for tears',
        ),
        tr(
          'Huwag piliting yakapin ang kamag-anak',
          'Do not make them hug a relative',
        ),
      ],
    ),
    GuideCard(
      id: 'kaibigan',
      category: GuideCategory.social,
      relevantTo: const {SupportFocus.asd, SupportFocus.adhd},
      icon: Icons.handshake_rounded,
      title: tr('Paghahanap ng Kaibigan', 'Making Friends'),
      summary: tr(
        'Sapat na ang isa kung iyon ang kaya niya.',
        'One friend is enough if that is what they have room for.',
      ),
      description: tr(
        'May batang iisa lang ang kaibigan at kontento na. May batang mas gusto '
            'ang katabi sa laro kaysa kausap. At may batang gustong-gusto '
            'makipagkaibigan pero hindi alam kung paano '
            'magsisimula.\n\nHindi sukatan ng ligaya ang bilang ng kaibigan.',
        'Some children have one friend and are content. Some prefer someone to '
            'play beside rather than talk to. And some badly want a friend but '
            'do not know how to begin.\n\nThe number of friends is not a measure '
            'of happiness.',
      ),
      quote: tr(
        'Hindi kalungkutan ang tahimik.',
        'Quiet is not the same as lonely.',
      ),
      actionTips: [
        tr(
          'Mag-ayos ng maikling laro sa bahay, dalawa lang',
          'Set up a short playdate at home, just the two of them',
        ),
        tr(
          'Pumili ng gawaing may malinaw na trabaho ang bawat isa',
          'Choose an activity with a clear job for each child',
        ),
        tr(
          'Huwag ihambing sa kapatid o pinsan',
          'Do not compare them to a sibling or a cousin',
        ),
        tr(
          'Tanungin ang titser kung sino ang kasundo niya',
          'Ask the teacher who they get on with',
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

  static List<GuideCard> inCategory(GuideCategory? category) => category == null
      ? all
      : all.where((card) => card.category == category).toList();

  /// Hinahati ayon sa tag ng bata: ang tumutugma muna, tapos ang iba.
  static (List<GuideCard> forChild, List<GuideCard> rest) splitFor(
    List<GuideCard> cards,
    List<SupportFocus> childTags,
  ) => splitByFocus(cards, childTags, (card) => card.relevantTo);
}
