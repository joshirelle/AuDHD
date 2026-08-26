import '../../../core/i18n/language_controller.dart';

/// Ang apat na pangkat ng CDC, hindi hinati at hindi pinagsama. Bahagi ng
/// hiniram na nilalaman ang pagkakagrupo, kaya hindi ito dapat baguhin.
enum MilestoneDomain {
  socialEmotional('Sosyal/Emosyonal', 'Social/Emotional'),
  language('Wika/Komunikasyon', 'Language/Communication'),
  cognitive('Pag-unawa', 'Cognitive'),
  movement('Paggalaw/Pisikal', 'Movement/Physical');

  const MilestoneDomain(this._labelFil, this._labelEng);

  final String _labelFil;
  final String _labelEng;

  String get label => tr(_labelFil, _labelEng);
}

/// Sanggunian lamang. Ang naabot o hindi ay nasa Hive, hindi rito.
class Milestone {
  final String id;
  final String _titleFil;
  final String _titleEng;
  final MilestoneDomain domain;
  final int targetAgeMonths;
  final String? _noteFil;

  const Milestone({
    required this.id,
    required String titleFil,
    required String titleEng,
    required this.domain,
    required this.targetAgeMonths,
    String? noteFil,
  }) : _titleFil = titleFil,
       _titleEng = titleEng,
       _noteFil = noteFil;

  String get title => tr(_titleFil, _titleEng);

  /// Para sa salitang walang katumbas sa Filipino: iniiwan ang Ingles at
  /// ipinapaliwanag, imbes na pilitin ang salin na lilituhin lang ang
  /// magulang. Wala itong silbi sa Ingles kaya doon ay tinatago.
  String? get note => LanguageController.isEnglish ? null : _noteFil;

  /// Taon kapag eksaktong nahahati sa 12; kung hindi, buwan. Ganito rin ang
  /// pagbibilang ng CDC — may banda silang 30 buwan.
  String get ageLabel => targetAgeMonths % 12 == 0
      ? tr('${targetAgeMonths ~/ 12} taon', '${targetAgeMonths ~/ 12} years')
      : tr('$targetAgeMonths buwan', '$targetAgeMonths months');
}
