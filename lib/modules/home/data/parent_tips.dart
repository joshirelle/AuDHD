import '../../../core/i18n/language_controller.dart';
import '../../../core/utils/support_focus_split.dart';
import '../../../data/models/child_profile.dart';

/// Isang linyang para sa magulang, hindi sa bata.
class ParentTip {
  const ParentTip(this.id, this._fil, this._eng, [this.relevantTo = const {}]);

  final String id;
  final String _fil;
  final String _eng;

  /// Blangko = para sa lahat. Ang tag ay NAGDARAGDAG sa mapagpipilian at
  /// hindi humahalili: opsyonal ang pokus ng suporta, at ang magulang na
  /// walang pinili ay hindi dapat mawalan ng mababasa.
  final Set<SupportFocus> relevantTo;

  String get text => tr(_fil, _eng);
}

/// Ang linyang nakikita ng magulang sa greeting card kada araw.
///
/// Tatlong panuntunan sa pagsulat dito:
/// 1. Sa magulang ito nakikipag-usap, hindi sa bata.
/// 2. Walang ipinapangako. Ang "magiging maayos din ang lahat" ay hindi natin
///    masisiguro, at sisi sa magulang kapag hindi ito nangyari.
/// 3. Walang utos na may kasamang pagkakasala. Paalala ito, hindi takdang-aralin.
class ParentTips {
  const ParentTips._();

  static const List<ParentTip> all = [
    // ------------------------------------------------- para sa lahat
    ParentTip(
      'tip_isang_sandali',
      'Hindi kailangang maganda ang buong araw. Sapat na ang isang sandaling '
          'maayos.',
      'The whole day does not have to go well. One moment that does is '
          'enough.',
    ),
    ParentTip(
      'tip_pagod',
      'Ang pagod mo ay hindi kabiguan. Ibig sabihin lang, may mabigat kang '
          'binubuhat.',
      'Being tired is not failing. It means you are carrying something heavy.',
    ),
    ParentTip(
      'tip_nagtatanong',
      'Walang magulang na alam ang lahat. Ang nagtatanong ay hindi mahina.',
      'No parent knows everything. Asking is not weakness.',
    ),
    ParentTip(
      'tip_pahinga',
      'Kung isang bagay lang ang kaya mo ngayon, piliin ang pahinga \u2014 kahit '
          'ang sa iyo.',
      'If you can only manage one thing today, choose rest \u2014 including your '
          'own.',
    ),
    ParentTip(
      'tip_walang_tala',
      'Ang araw na walang naitala ay araw pa rin na pinagdaanan ninyong '
          'dalawa.',
      'A day with nothing logged is still a day the two of you got through.',
    ),
    ParentTip(
      'tip_hindi_nag_iisa',
      'Hindi ka nag-iisa, kahit ganoon ang pakiramdam pagmulat mo sa umaga.',
      'You are not on your own, even when the morning feels like it.',
    ),
    ParentTip(
      'tip_humingi_tulong',
      'Ang paghingi ng tulong ay bahagi ng pag-aalaga, hindi pag-amin ng '
          'kakulangan.',
      'Asking for help is part of caring, not an admission of failing.',
    ),
    ParentTip(
      'tip_pabalik',
      'Ang pag-unlad ay hindi laging pataas. May pabalik, at karaniwan iyon.',
      'Progress does not only go up. It doubles back, and that is ordinary.',
    ),
    ParentTip(
      'tip_paghahambing',
      'Ang paghahambing sa ibang bata ay bihirang nakakatulong sa inyong '
          'dalawa.',
      'Comparing them to another child rarely helps either of you.',
    ),
    ParentTip(
      'tip_kilala_mo',
      'Kilala mo ang anak mo nang higit sa kahit sinong makakabasa ng papel '
          'niya.',
      'You know your child better than anyone who will ever read their file.',
    ),
    ParentTip(
      'tip_masamang_araw',
      'Ang masamang araw ay hindi bumubura sa mga mabubuting araw.',
      'A bad day does not erase the good ones.',
    ),
    ParentTip(
      'tip_kumain_ka',
      'Kumain ka na ba? Madalas itong nakakalimutan sa araw na mahirap.',
      'Have you eaten? It is the first thing to go on a hard day.',
    ),
    ParentTip(
      'tip_maliit_na_hakbang',
      'Ang maliit na hakbang na inuulit ay mas malayo ang mararating kaysa sa '
          'malaking hakbang na minsan lang.',
      'A small step repeated goes further than a big one taken once.',
    ),
    ParentTip(
      'tip_pagsabog',
      'Kapag sumabog siya, hindi ibig sabihin na nabigo ka.',
      'When they melt down, it does not mean you failed.',
    ),
    ParentTip(
      'tip_walang_paliwanag',
      'Puwede kang magpahinga nang walang paliwanag na kailangang ibigay.',
      'You are allowed to rest without owing anyone an explanation.',
    ),
    ParentTip(
      'tip_kamag_anak',
      'Ang tulong mula sa kamag-anak ay hindi kahihiyan. Iyon ang dahilan '
          'kung bakit sila nandiyan.',
      'Help from family is nothing to be ashamed of. That is what they are '
          'there for.',
    ),
    ParentTip(
      'tip_hindi_therapist',
      'Hindi mo kailangang maging therapist niya. Kailangan ka niyang maging '
          'magulang.',
      'You do not have to be their therapist. They need you to be their '
          'parent.',
    ),
    ParentTip(
      'tip_ipagdiwang',
      'Ang isang matagumpay na sandali ay sulit ipagdiwang, gaano man ito '
          'kaliit.',
      'A moment that went well is worth marking, however small it was.',
    ),
    ParentTip(
      'tip_hindi_karera',
      'Mahaba ang landas na ito. Hindi ito karera, at walang naghihintay sa '
          'dulo na may orasan.',
      'This road is long. It is not a race, and nobody is waiting at the end '
          'with a stopwatch.',
    ),
    ParentTip(
      'tip_mahirap_na_gabi',
      'Ang mahirap na gabi ay hindi hula kung ano ang magiging bukas.',
      'A hard night is not a forecast for tomorrow.',
    ),
    ParentTip(
      'tip_pagtatala',
      'Ang itinatala mo ngayon ay tulong sa iyo sa susunod na konsultasyon. '
          'Mahirap tandaan ang tatlong buwan nang pasalita.',
      'What you write down today helps you at the next appointment. Three '
          'months is hard to recall out loud.',
    ),
    ParentTip(
      'tip_araw_ng_pahinga',
      'Hindi lahat ng araw ay para sa pag-unlad. May araw na para sa '
          'pagpapahinga lang.',
      'Not every day has to be for progress. Some days are just for resting.',
    ),
    ParentTip(
      'tip_inip',
      'Ang inip mo ay pagiging tao lang. Hindi ito nangangahulugang kulang '
          'ang pagmamahal mo.',
      'Losing patience is being human. It does not mean you love them less.',
    ),
    ParentTip(
      'tip_hindi_kasalanan',
      'May mga bagay na hindi mo kayang ayusin, at hindi mo kasalanan iyon.',
      'There are things you cannot fix, and that is not your fault.',
    ),
    ParentTip(
      'tip_tama_ba',
      'Ang tanong na "tama ba ang ginagawa ko?" ay tanda ng nag-aalagang '
          'mabuti.',
      'Asking whether you are doing this right is the mark of someone doing '
          'it carefully.',
    ),
    ParentTip(
      'tip_gawaing_bahay',
      'Puwedeng maghintay ang gawaing bahay. Hindi ito tatakbo.',
      'The housework can wait. It is not going anywhere.',
    ),
    // ------------------------------------------------------------- ASD
    ParentTip(
      'tip_rutina',
      'Ang rutina ay hindi pagiging matigas. Iyon ang paraan niya para maging '
          'matiyak ang mundo.',
      'Routine is not rigidity. It is how the world becomes certain for them.',
      {SupportFocus.asd},
    ),
    ParentTip(
      'tip_paulit_ulit_paksa',
      'Kapag paulit-ulit ang paksang gusto niyang pag-usapan, iyon ang '
          'paraan niya para makipag-ugnayan sa iyo.',
      'When they return to the same subject again and again, that is them '
          'reaching for you.',
      {SupportFocus.asd},
    ),
    ParentTip(
      'tip_maagang_babala',
      'Ang pagsabi nang maaga tungkol sa pagbabago ay mas mabisa kaysa '
          'paghikayat pagkatapos.',
      'Saying a change is coming works better than coaxing after it has.',
      {SupportFocus.asd},
    ),
    ParentTip(
      'tip_paulit_ulit_galaw',
      'Ang paulit-ulit na galaw ay madalas ang paraan niya para huminahon. '
          'Hindi ito laging kailangang pigilan.',
      'The repeated movements are often how they settle. They do not always '
          'need to be stopped.',
      {SupportFocus.asd, SupportFocus.sensorySensitivity},
    ),
    // ------------------------------------------------------------ ADHD
    ParentTip(
      'tip_isahang_utos',
      'Ang isang utos ay mas malayo ang mararating kaysa sa listahang tatlo.',
      'One instruction goes further than a list of three.',
      {SupportFocus.adhd},
    ),
    ParentTip(
      'tip_galaw_habang_nakikinig',
      'Ang paggalaw niya habang nakikinig ay hindi kawalan ng respeto. '
          'Ganoon siya nakikinig.',
      'Moving while you talk is not disrespect. That is them listening.',
      {SupportFocus.adhd},
    ),
    ParentTip(
      'tip_nakalimutan',
      'Ang nakalimutan ay madalas hindi pagsuway.',
      'Forgotten is usually not the same as defiant.',
      {SupportFocus.adhd},
    ),
    ParentTip(
      'tip_nakikitang_paalala',
      'Ang paalalang nakikita ay mas mabisa kaysa sa paalalang sinasabi.',
      'A reminder they can see works better than one they hear.',
      {SupportFocus.adhd},
    ),
    // ---------------------------------------------------- speech delay
    ParentTip(
      'tip_naririnig',
      'Ang bawat salitang naririnig niya ay hindi nasasayang, kahit hindi pa '
          'siya sumasagot.',
      'Every word they hear counts, even while there is no answer yet.',
      {SupportFocus.speechDelay},
    ),
    ParentTip(
      'tip_wika_rin',
      'Ang pagturo, ang kaway, at ang tingin ay wika rin.',
      'Pointing, waving, and looking are language too.',
      {SupportFocus.speechDelay},
    ),
    ParentTip(
      'tip_hindi_perpekto',
      'Hindi mo kailangang tama ang bawat salita. Ang pakikinig niya sa boses '
          'mo ang mahalaga.',
      'You do not need to get every word right. Hearing your voice is the '
          'part that matters.',
      {SupportFocus.speechDelay},
    ),
    // ---------------------------------------------- sensory sensitivity
    ParentTip(
      'tip_tainga',
      'Kapag tinakpan niya ang tainga, hindi siya nagpapapansin.',
      'When they cover their ears, they are not making a scene.',
      {SupportFocus.sensorySensitivity},
    ),
    ParentTip(
      'tip_bawasan_maaga',
      'Ang pagbawas ng ingay bago pa lumala ay mas mabisa kaysa sa '
          'pagpapakalma pagkatapos.',
      'Turning the noise down early works better than calming things after.',
      {SupportFocus.sensorySensitivity},
    ),
    ParentTip(
      'tip_iba_kada_araw',
      'May araw na kaya niya ang mall, at may araw na hindi. Pareho itong '
          'totoo.',
      'Some days they can manage the mall and some days they cannot. Both are '
          'true.',
      {SupportFocus.sensorySensitivity},
    ),
  ];

  /// Ang mapagpipilian ngayon: lahat ng pangkalahatan, dagdag ang tumutugma
  /// sa tag ng bata. Hindi kailanman mas kaunti kaysa sa pangkalahatan.
  static List<ParentTip> poolFor(List<SupportFocus> childTags) {
    final tags = childTags.where(tagsThatSort.contains).toSet();
    return all
        .where(
          (tip) => tip.relevantTo.isEmpty || tip.relevantTo.any(tags.contains),
        )
        .toList();
  }

  /// Iisa kada araw. Naka-seed sa petsa at hindi random: kung magbabago ito
  /// sa bawat rebuild, hindi na ito paalala kundi ingay.
  static ParentTip forDay(DateTime date, List<SupportFocus> childTags) {
    final pool = poolFor(childTags);
    final days = DateTime(
      date.year,
      date.month,
      date.day,
    ).difference(DateTime(2020)).inDays;
    return pool[days.abs() % pool.length];
  }
}
