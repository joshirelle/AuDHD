import 'package:flutter/material.dart';

import '../i18n/language_controller.dart';
import '../theme/app_theme.dart';

/// Ang bahagi ng paglaki na tinutulungan ng isang gawain.
///
/// Sinadyang karaniwang salita ang ginamit at hindi terminong pang-klinika.
/// Hindi therapy ang app na ito at hindi ito nagsasabi ng kondisyon — gabay
/// lang para malaman ng magulang kung ano ang pinapasanay ng bawat gawain.
enum SkillArea {
  fineMotor(
    'Kamay at Daliri',
    'Hands and Fingers',
    Icons.pan_tool_rounded,
    AppColors.coralPeach,
    AppColors.coralInk,
    'Paghawak ng maliliit na bagay — lapis, kutsara, butones.',
    'Holding small things — pencils, spoons, buttons.',
  ),
  sensory(
    'Pandama',
    'Senses',
    Icons.spa_rounded,
    AppColors.lavender,
    AppColors.autismPurple,
    'Pagsanay sa ingay, hipo, at galaw na dating mahirap tiisin.',
    'Getting used to sounds, touch, and movement that were hard before.',
  ),
  grossMotor(
    'Kilos at Balanse',
    'Moving and Balance',
    Icons.directions_run_rounded,
    AppColors.skyBlueLight,
    AppColors.skyInk,
    'Buong katawan — takbo, talon, akyat, at balanse.',
    'The whole body — running, jumping, climbing, balancing.',
  ),
  dailyLiving(
    'Sarili Niya',
    'Doing It Alone',
    Icons.clean_hands_rounded,
    AppColors.mintGreen,
    AppColors.mintInk,
    'Mga gawaing pang-araw-araw — kain, bihis, ligo, ligpit.',
    'Everyday things — eating, dressing, bathing, tidying up.',
  ),
  focus(
    'Pokus at Pagpipigil',
    'Focus and Waiting',
    Icons.timer_rounded,
    AppColors.butterYellow,
    AppColors.butterInk,
    'Paghihintay, pagsunod sa hudyat, at pagtutuon ng pansin.',
    'Waiting, following a signal, and holding attention.',
  ),
  play(
    'Paglalaro',
    'Playing Together',
    Icons.toys_rounded,
    AppColors.tintBlue,
    AppColors.accentBlue,
    'Salitan, paghihintay ng turno, at paglalaro kasama ang iba.',
    'Sharing, taking turns, and playing with others.',
  );

  const SkillArea(
    this._label,
    this._labelEnglish,
    this.icon,
    this.background,
    this.ink,
    this._description,
    this._descriptionEnglish,
  );

  final String _label;
  final String _labelEnglish;
  final IconData icon;
  final Color background;

  /// Sapat ang kaibahan nito sa `background` para mabasa ng may mahinang mata.
  final Color ink;

  /// Paliwanag sa info sheet.
  final String _description;
  final String _descriptionEnglish;

  String get label => tr(_label, _labelEnglish);
  String get description => tr(_description, _descriptionEnglish);

  /// `grossMotor` ang pinakamalawak, kaya iyon ang bumabagsak na sagot kapag
  /// may gawaing walang tag sa JSON.
  static SkillArea fromKey(String? key) {
    for (final area in SkillArea.values) {
      if (area.name == key) return area;
    }
    return SkillArea.grossMotor;
  }
}
