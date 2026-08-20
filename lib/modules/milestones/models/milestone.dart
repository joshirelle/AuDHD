import '../../../core/i18n/language_controller.dart';

enum MilestoneDomain {
  grossMotor('Malalaking Galaw', 'Big Movements'),
  fineMotor('Maliliit na Galaw', 'Small Movements'),
  speechLanguage('Pagsasalita', 'Talking'),
  socialEmotional('Pakikisalamuha', 'Getting Along');

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

  const Milestone({
    required this.id,
    required String titleFil,
    required String titleEng,
    required this.domain,
    required this.targetAgeMonths,
  }) : _titleFil = titleFil,
       _titleEng = titleEng;

  String get title => tr(_titleFil, _titleEng);

  String get targetAgeLabel =>
      tr('Bago mag-$targetAgeMonths buwan', 'Before $targetAgeMonths months');
}
