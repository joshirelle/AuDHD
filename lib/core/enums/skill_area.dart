import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Ang bahagi ng paglaki na tinutulungan ng isang gawain.
///
/// Sinadyang karaniwang salita ang ginamit at hindi terminong pang-klinika.
/// Hindi therapy ang app na ito at hindi ito nagsasabi ng kondisyon — gabay
/// lang para malaman ng magulang kung ano ang pinapasanay ng bawat gawain.
enum SkillArea {
  fineMotor(
    'Kamay at Daliri',
    Icons.pan_tool_rounded,
    AppColors.coralPeach,
    AppColors.coralInk,
    'Paghawak ng maliliit na bagay — lapis, kutsara, butones.',
  ),
  sensory(
    'Pandama',
    Icons.spa_rounded,
    AppColors.lavender,
    AppColors.autismPurple,
    'Pagsanay sa ingay, hipo, at galaw na dating mahirap tiisin.',
  ),
  grossMotor(
    'Kilos at Balanse',
    Icons.directions_run_rounded,
    AppColors.skyBlueLight,
    AppColors.skyInk,
    'Buong katawan — takbo, talon, akyat, at balanse.',
  ),
  dailyLiving(
    'Sarili Niya',
    Icons.clean_hands_rounded,
    AppColors.mintGreen,
    AppColors.mintInk,
    'Mga gawaing pang-araw-araw — kain, bihis, ligo, ligpit.',
  ),
  focus(
    'Pokus at Pagpipigil',
    Icons.timer_rounded,
    AppColors.butterYellow,
    AppColors.butterInk,
    'Paghihintay, pagsunod sa hudyat, at pagtutuon ng pansin.',
  ),
  play(
    'Paglalaro',
    Icons.toys_rounded,
    AppColors.tintBlue,
    AppColors.accentBlue,
    'Salitan, paghihintay ng turno, at paglalaro kasama ang iba.',
  );

  const SkillArea(
    this.label,
    this.icon,
    this.background,
    this.ink,
    this.description,
  );

  final String label;
  final IconData icon;
  final Color background;

  /// Sapat ang kaibahan nito sa `background` para mabasa ng may mahinang mata.
  final Color ink;

  /// Paliwanag sa info sheet.
  final String description;

  /// `grossMotor` ang pinakamalawak, kaya iyon ang bumabagsak na sagot kapag
  /// may gawaing walang tag sa JSON.
  static SkillArea fromKey(String? key) {
    for (final area in SkillArea.values) {
      if (area.name == key) return area;
    }
    return SkillArea.grossMotor;
  }
}
