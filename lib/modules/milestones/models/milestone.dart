enum MilestoneDomain {
  grossMotor('Gross Motor'),
  fineMotor('Fine Motor'),
  speechLanguage('Speech / Language'),
  socialEmotional('Social-Emotional');

  const MilestoneDomain(this.label);

  final String label;
}

/// Sanggunian lamang. Ang naabot o hindi ay nasa Hive, hindi rito.
class Milestone {
  final String id;
  final String titleTagalog;
  final MilestoneDomain domain;
  final int targetAgeMonths;

  const Milestone({
    required this.id,
    required this.titleTagalog,
    required this.domain,
    required this.targetAgeMonths,
  });

  String get targetAgeLabel => 'Bago mag-$targetAgeMonths buwan';
}
