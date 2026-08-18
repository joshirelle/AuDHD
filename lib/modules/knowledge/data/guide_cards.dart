import 'package:flutter/material.dart';

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

  static const List<GuideCard> all = [
    GuideCard(
      id: 'ingay',
      category: GuideCategory.sensory,
      icon: Icons.volume_up_rounded,
      title: 'Malakas na Ingay',
      summary: 'Mas malakas ang dating nito sa kanya kaysa sa atin.',
      description:
          'May mga batang mas matalas ang pandinig sa ilang tunog. Ang blender, '
          'palakpakan, o busina ay maaaring hindi lang basta maingay para sa '
          'kanya.\n\nKapag tinakpan niya ang tainga o umiyak, madalas iyon ang '
          'paraan niya para sabihing sobra na — hindi para magpapansin.',
      quote: 'Hindi siya pasaway. Nahihirapan siya.',
      actionTips: [
        'Bawasan ang ingay bago pa ito lumala',
        'Maghanda ng isang tahimik na sulok sa bahay',
        'Sabihan siya bago pumunta sa maingay na lugar',
        'Subukan ang headphones kapag sa mall o palengke',
      ],
    ),
    GuideCard(
      id: 'ilaw',
      category: GuideCategory.sensory,
      icon: Icons.light_mode_rounded,
      title: 'Maliwanag na Ilaw',
      summary: 'Nakakasilaw at nakakapagod sa mata niya ang ilang ilaw.',
      description:
          'Ang puting ilaw sa mall o ang kumukurap na fluorescent ay maaaring '
          'masakit sa mata ng ilang bata.\n\nHindi ito laging halata. Minsan '
          'ang tanging palatandaan ay pagkairita, pagtatago ng mukha, o biglang '
          'ayaw nang pumasok.',
      quote: 'Hindi siya sumusungit. Sumasakit ang mata niya.',
      actionTips: [
        'Piliin ang mas malamlam na ilaw kapag gabi',
        'Umupo nang malayo sa kumukurap na ilaw',
        'Magdala ng sombrero kapag matindi ang araw',
        'Bigyan siya ng saglit na pahinga sa madilim na lugar',
      ],
    ),
    GuideCard(
      id: 'damit',
      category: GuideCategory.sensory,
      icon: Icons.checkroom_rounded,
      title: 'Tekstura ng Damit',
      summary: 'May damit na parang kumakagat sa balat niya.',
      description:
          'Ang tag sa likod ng damit, ang makapal na tela, o ang basang medyas '
          'ay maaaring hindi matiis ng ilang bata.\n\nHindi ito pagiging '
          'maarte. Para sa kanya, parang may kumakamot sa balat na hindi mo '
          'nakikita.',
      quote: 'Hindi siya maarte. Hindi niya talaga matiis.',
      actionTips: [
        'Gupitin ang tag sa likod ng damit',
        'Hayaan siyang pumili ng damit kung kaya niya',
        'Labhan muna ang bagong damit bago isuot',
        'Magdala ng pamalit kapag lumalabas kayo',
      ],
    ),
    GuideCard(
      id: 'pagsabog',
      category: GuideCategory.emotion,
      icon: Icons.storm_rounded,
      title: 'Pagsabog ng Damdamin',
      summary: 'Hindi ito pagrerebelde. Umapaw na ang kaya niyang tiisin.',
      description:
          'May pagkakataong sobra na ang naipon sa isang araw — ingay, gutom, '
          'pagod, o biglaang pagbabago ng plano. Kapag umapaw, madalas hindi na '
          'niya kontrolado ang sarili niyang katawan.\n\nKaiba ito sa '
          'pagmamaktol na may hinihinging bagay. Dito, kadalasan ay wala siyang '
          'hinihingi — hindi na lang niya kaya.',
      quote: 'Hindi niya ito ginagawa sa akin. Nangyayari ito sa kanya.',
      actionTips: [
        'Bawasan ang salita — mas kaunti, mas mabuti',
        'Alisin muna ang ingay at ang maraming tao',
        'Manatiling malapit nang hindi humahawak agad',
        'Saka na ang mahabang usapan kapag kalmado na',
      ],
    ),
    GuideCard(
      id: 'paulit_ulit',
      category: GuideCategory.emotion,
      icon: Icons.repeat_rounded,
      title: 'Kailangan ng Paulit-ulit',
      summary: 'Ang alam na niya ang nagpapakalma sa kanya.',
      description:
          'Kapag alam ng bata kung ano ang susunod, mas kaunti ang kailangan '
          'niyang pangambahan.\n\nKaya ang biglaang pagbabago ng plano ay '
          'maaaring mabigat — parang nawalan siya ng lupang tinatapakan, kahit '
          'maliit lang ang pagbabago para sa atin.',
      quote: 'Hindi siya matigas ang ulo. Naghahanap siya ng katiyakan.',
      actionTips: [
        'Sabihin ang plano bago pa ito mangyari',
        'Magbilang bago lumipat sa ibang gawain',
        'Panatilihin ang parehong pagkakasunod-sunod sa umaga',
        'Kapag may pagbabago, ipaalam nang maaga',
      ],
    ),
    GuideCard(
      id: 'magsimula',
      category: GuideCategory.focus,
      icon: Icons.play_circle_outline_rounded,
      title: 'Mahirap Magsimula',
      summary: 'Alam niya ang gagawin, pero mabigat ang unang hakbang.',
      description:
          'May pagkakataong hindi ang gawain ang mabigat kundi ang pagsisimula '
          'nito.\n\nKahit gusto niyang gawin at alam niya kung paano, parang may '
          'humahadlang bago pa siya makagalaw.',
      quote: 'Hindi siya tamad. Nasa pagsisimula ang hirap.',
      actionTips: [
        'Hatiin ang gawain sa maliliit na hakbang',
        'Samahan siya sa unang isang minuto',
        'Isang utos lang sa bawat pagkakataon',
        'Gumamit ng timer para may makitang hangganan',
      ],
    ),
    GuideCard(
      id: 'utos',
      category: GuideCategory.focus,
      icon: Icons.checklist_rounded,
      title: 'Hindi Lahat Naaabutan',
      summary: 'Kapag maraming utos, minsan isa lang ang nahahawakan.',
      description:
          'Kapag tatlo o apat na utos ang sabay-sabay, maaaring isa lang ang '
          'maabutan niya.\n\nHindi ito pagsuway. Narinig niya, hindi lang lahat '
          'nakakapit nang sabay-sabay.',
      quote: 'Hindi niya ako binabalewala. Hindi lang lahat naabutan.',
      actionTips: [
        'Isa-isahin ang utos',
        'Patingnan muna siya bago magsalita',
        'Gumamit ng larawan o nakasulat na listahan',
        'Pasabihin sa kanya ang narinig niya',
      ],
    ),
    GuideCard(
      id: 'tingin',
      category: GuideCategory.social,
      icon: Icons.visibility_off_rounded,
      title: 'Hindi Tumitingin sa Mata',
      summary: 'May batang mas nakikinig kapag hindi nakatingin.',
      description:
          'Para sa ilang bata, mabigat ang tumingin sa mata habang nakikinig — '
          'parang dalawang bagay na sabay na ginagawa.\n\nMinsan, ang hindi '
          'pagtingin ang mismong paraan niya para mas maintindihan ka.',
      quote: 'Nakikinig siya. Iba lang ang paraan niya.',
      actionTips: [
        'Huwag piliting tumingin sa mata',
        'Mag-usap habang may ginagawang iba',
        'Tabi-tabi kayong umupo kaysa magkaharap',
        'Hanapin ang ibang senyales na nakikinig siya',
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
