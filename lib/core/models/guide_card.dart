import 'package:flutter/material.dart';

import '../i18n/language_controller.dart';
import '../theme/app_theme.dart';

/// Pangkat ng mga gabay. Ang kulay at icon ay nakatali rito para hindi
/// magkaiba-iba ang hitsura ng magkakapatid na card.
enum GuideCategory {
  sensory(Icons.hearing_rounded, AppColors.skyBlueLight, AppColors.skyInk),
  emotion(Icons.favorite_rounded, AppColors.coralPeach, AppColors.coralInk),
  focus(Icons.bolt_rounded, AppColors.butterYellow, AppColors.butterInk),
  social(Icons.groups_rounded, AppColors.mintGreen, AppColors.mintInk);

  const GuideCategory(this.icon, this.background, this.ink);

  /// Getter at hindi `final` na field: kailangang mabasa muli kapag nagpalit
  /// ng wika ang magulang.
  String get label => switch (this) {
    GuideCategory.sensory => tr('Sensory', 'Sensory'),
    GuideCategory.emotion => tr('Damdamin', 'Emotions'),
    GuideCategory.focus => tr('Pokus', 'Focus'),
    GuideCategory.social => tr('Pakikisama', 'Getting Along'),
  };

  final IconData icon;
  final Color background;

  /// Sapat ang kaibahan nito sa `background` para mabasa ng may mahinang mata.
  final Color ink;
}

/// Isang paksa sa "Gabay sa Pag-unawa".
///
/// Pananaw ng magulang ang isinusulat dito, hindi paliwanag ng doktor. Walang
/// sinasabing sanhi, diagnosis, o lunas — kung ano ang maaaring maramdaman ng
/// bata, at kung ano ang maaaring subukan ng magulang.
class GuideCard {
  const GuideCard({
    required this.id,
    required this.category,
    required this.title,
    required this.summary,
    required this.description,
    required this.quote,
    required this.icon,
    required this.actionTips,
  });

  final String id;
  final GuideCategory category;

  final String title;

  /// Maikling nakikita sa card mismo.
  final String summary;

  /// Buong paliwanag sa bottom sheet.
  final String description;

  /// Ang linyang gustong maalala ng magulang.
  final String quote;

  final IconData icon;

  /// Bawat isa ay may sariling tsek na naaalala ng app.
  final List<String> actionTips;
}
