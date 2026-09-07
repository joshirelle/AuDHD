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
        ObservationPattern(
          title: tr('Walang takot sa estranghero', 'No wariness of strangers'),
          body: tr(
            'May batang lumalapit agad sa hindi kilala, yumayakap, o sumasama '
                'nang walang pag-aalinlangan. Madalas itong pinupuri bilang '
                'palakaibigan.',
            'Some children walk straight up to people they do not know, hug '
                'them, or go along without hesitating. This often gets praised '
                'as being friendly.',
          ),
          help: tr(
            'Ituro ang isang simpleng patakaran na pareho sa lahat ng lugar, '
                'at sabihin ito sa doktor. Hindi ito kabaligtaran ng kahihiyan '
                '— pareho itong tungkol sa pagbasa ng sitwasyon.',
            'Teach one simple rule that holds everywhere, and mention it to the '
                'doctor. It is not the opposite of shyness — both are about '
                'reading a situation.',
          ),
        ),
        ObservationPattern(
          title: tr(
            'Mas gusto ang matanda o mas bata',
            'Prefers older or younger children',
          ),
          body: tr(
            'May batang mas panatag sa kausap na matanda o sa mas batang '
                'kalaro kaysa sa kaedad niya. Sa dalawang iyon, mas malinaw '
                'kung sino ang susunod at sino ang mauuna.',
            'Some children are more at ease with adults or with younger '
                'playmates than with children their own age. With those two, it '
                'is clearer who leads and who follows.',
          ),
          help: tr(
            'Huwag itong pilitin. Itala kung kanino siya panatag — nagsasabi '
                'ito kung ano ang nakakatulong sa kanya.',
            'Do not force it. Note who they are at ease with — it says '
                'something about what helps them.',
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
        ObservationPattern(
          title: tr('Nawawala ang gamit', 'Things go missing'),
          body: tr(
            'May batang paulit-ulit na naiiwan ang tumbler, lapis, o kuwaderno. '
                'Hindi ito kawalan ng pagpapahalaga — nasa ibang lugar ang isip '
                'niya sa mismong sandali ng pag-alis.',
            'Some children leave the water bottle, the pencil, or the notebook '
                'behind again and again. It is not that they do not care — '
                'their mind was elsewhere at the moment of leaving.',
          ),
          help: tr(
            'Isang lugar lang para sa bawat gamit, at isang tingin bago umalis. '
                'Mas mabisa ang nakikitang paalala kaysa sa sinasabi.',
            'One place for each thing, and one look back before leaving. A '
                'reminder they can see works better than one they hear.',
          ),
        ),
        ObservationPattern(
          title: tr(
            'Naririnig pero hindi natutuloy',
            'Hears it but it does not happen',
          ),
          body: tr(
            'Nauulit niya ang sinabi mo pero hindi pa rin nagagawa. Nasa '
                'pagitan ito ng pagkarinig at ng paggalaw — hindi sa pandinig, '
                'at hindi sa kagustuhan.',
            'They can repeat what you said and still not do it. It sits between '
                'hearing and moving — not in the ears, and not in the wanting.',
          ),
          help: tr(
            'Isang utos lang bawat pagkakataon, at hintayin ang unang hakbang '
                'bago sabihin ang susunod.',
            'One instruction at a time, and wait for the first step before you '
                'say the next.',
          ),
        ),
        ObservationPattern(
          title: tr(
            'Mahirap magsimula kahit gusto niya',
            'Hard to start even when willing',
          ),
          body: tr(
            'May batang gustong-gusto na ngang gawin ang isang bagay pero '
                'hindi makaumpisa. Nakaupo siya sa harap nito nang matagal.',
            'Some children genuinely want to do the thing and still cannot '
                'begin. They sit in front of it for a long time.',
          ),
          help: tr(
            'Simulan mo ang unang hakbang kasama niya, tapos umalis ka. Madalas '
                'ang pagsisimula lang ang mabigat.',
            'Do the first step with them, then step away. It is often only the '
                'starting that is heavy.',
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
        ObservationPattern(
          title: tr(
            'Hindi napapansin ang sakit o lamig',
            'Does not seem to notice pain or cold',
          ),
          body: tr(
            'May batang hindi umiiyak sa gasgas, hindi nagrereklamo sa init o '
                'lamig, o hindi napapansin ang basang damit. Hindi ibig sabihin '
                'na hindi niya nararamdaman.',
            'Some children do not cry at a scrape, do not complain about heat '
                'or cold, or do not notice wet clothes. It does not mean they '
                'feel nothing.',
          ),
          help: tr(
            'Tingnan ang katawan niya paminsan-minsan kahit walang reklamo, at '
                'sabihin ito sa doktor. Kaligtasan ito, hindi lang pandama.',
            'Check them over now and then even with no complaint, and tell the '
                'doctor. This is a safety matter, not only a sensory one.',
          ),
        ),
        ObservationPattern(
          title: tr(
            'Naririnig ang hindi natin naririnig',
            'Hears what the rest of us do not',
          ),
          body: tr(
            'May batang nababagabag ng bentilador, ng ref, o ng aircon na '
                'matagal na nating hindi napapansin. Nandiyan ito buong araw, '
                'kaya buong araw din siyang nakikinig.',
            'Some children are bothered by the fan, the fridge, or the aircon '
                'that the rest of us stopped noticing long ago. It is there all '
                'day, so they are listening to it all day.',
          ),
          help: tr(
            'Tanungin siya kung ano ang naririnig niya sa isang tahimik na '
                'silid. Ang sagot ay madalas nakakagulat.',
            'Ask them what they can hear in a quiet room. The answer is often '
                'surprising.',
          ),
        ),
      ],
    ),
    ObservationArea(
      id: 'damdamin',
      category: GuideCategory.emotion,
      icon: Icons.favorite_rounded,
      title: tr('Damdamin', 'Feelings'),
      intro: tr(
        'Magkaiba ang laki ng nararamdaman ng bawat bata, at magkaiba rin ang '
            'daan palabas nito. Dalawang batang parehong nabibigatan ay '
            'maaaring magmukhang magkasalungat.',
        'Feelings come in different sizes for different children, and they '
            'find different ways out. Two children who are both struggling can '
            'look like opposites.',
      ),
      patterns: [
        ObservationPattern(
          title: tr(
            'Mabilis sumabog, mabilis matapos',
            'Flares fast, passes fast',
          ),
          body: tr(
            'May batang mabilis magalit at parang wala nang nangyari '
                'pagkaraan ng ilang minuto. Totoo ang bigat noong sandaling '
                'iyon kahit maikli lang ito.',
            'Some children flare quickly and seem to have moved on minutes '
                'later. The weight in that moment was real even if it was '
                'brief.',
          ),
          help: tr(
            'Huwag balikan agad ang usapan. Hintayin munang bumalik siya bago '
                'pag-usapan ang nangyari.',
            'Do not go back to it straight away. Wait until they are back '
                'before talking about what happened.',
          ),
        ),
        ObservationPattern(
          title: tr('Walang palatandaan hanggang sa huli', 'No warning at all'),
          body: tr(
            'May batang mukhang ayos lang hanggang sa biglang hindi na. Wala '
                'kang nakitang paunti-unting paglaki \u2014 dumating ito nang '
                'buo.',
            'Some children look fine right up until they are suddenly not. You '
                'saw nothing build \u2014 it arrived whole.',
          ),
          help: tr(
            'Itala ang oras, ang lugar, at ang nauna rito. Ang hindi nakikita '
                'sa isang araw ay madalas nakikita sa loob ng dalawang linggo.',
            'Write down the time, the place, and what came before. What is '
                'invisible in one day often shows across two weeks.',
          ),
        ),
        ObservationPattern(
          title: tr(
            'Matagal bumalik pagkatapos',
            'Takes a long time to come back',
          ),
          body: tr(
            'May batang tapos na ang iyakan pero hindi pa rin siya ang dating '
                'siya kahit lumipas ang oras. Nangangailangan pa siya ng '
                'panahon na hindi natin nakikita.',
            'For some children the crying stops but they are not themselves '
                'again for hours. They are still needing time we cannot see.',
          ),
          help: tr(
            'Huwag hingin ang paumanhin o ang paliwanag habang nasa ganitong '
                'kalagayan. Panatagin muna, saka mag-usap.',
            'Do not ask for an apology or an explanation while they are still '
                'in it. Settle first, talk later.',
          ),
        ),
        ObservationPattern(
          title: tr('Nag-aalala nang maaga pa', 'Worries long in advance'),
          body: tr(
            'May batang nag-aalala tungkol sa mangyayari sa susunod na linggo, '
                'o sa isang bagay na tapos na. Paulit-ulit ang tanong kahit '
                'nasagot na.',
            'Some children worry about next week, or about something already '
                'over. The same question comes back even after it has been '
                'answered.',
          ),
          help: tr(
            'Isang malinaw na sagot, tapos ulitin mo ang parehong sagot. Ang '
                'bagong salita sa bawat pagtatanong ay nagdadagdag ng '
                'pag-aalala.',
            'One clear answer, then repeat the same answer. New words each time '
                'add to the worry.',
          ),
        ),
        ObservationPattern(
          title: tr('Ang galit ay pasarili', 'The anger turns inward'),
          body: tr(
            'May batang sinasabing masama siya, tanga siya, o dapat wala na '
                'siya. Maaari rin niyang saktan ang sarili niya kapag sobrang '
                'bigat.',
            'Some children say they are bad, that they are stupid, or that they '
                'should not be here. Some may hurt themselves when it gets too '
                'heavy.',
          ),
          help: tr(
            'Huwag itong balewalain at huwag ding taasan ang boses. Itala kung '
                'kailan ito nangyayari at sabihin sa doktor o sa guidance sa '
                'paaralan sa lalong madaling panahon. Hindi ito kailangang '
                'pasanin nang mag-isa.',
            'Do not brush it aside and do not raise your voice. Write down when '
                'it happens and tell the doctor or the school guidance office '
                'soon. This is not something to carry alone.',
          ),
        ),
      ],
    ),
  ];
}
