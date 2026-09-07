import 'package:flutter/material.dart';

import '../i18n/language_controller.dart';
import '../theme/app_theme.dart';

enum MoodTone {
  positive(AppColors.mintGreen, AppColors.mintInk),
  neutral(AppColors.skyBlueLight, AppColors.skyInk),
  negative(AppColors.coralPeach, AppColors.coralInk);

  const MoodTone(this.fill, this.ink);

  final Color fill;

  /// Sapat ang kaibahan nito sa `fill` at sa `surface`.
  final Color ink;

  String get label => switch (this) {
    MoodTone.positive => tr('Masaya', 'Good'),
    MoodTone.neutral => tr('Karaniwan', 'In between'),
    MoodTone.negative => tr('Mahirap', 'Hard'),
  };
}

/// `IconData` at hindi emoji o asset.
///
/// Ang emoji ay dumadaan sa font fallback ng system — hindi tugma sa buong
/// app na `IconData` ang gamit, at nagbabago ang hitsura kada telepono. Ang
/// asset naman ay hindi umiiral: walang `assets/moods/`, kaya ang `errorBuilder`
/// ang naging normal na landas at labing-anim na palyadong lookup kada guhit.
enum MoodType {
  joyful(
    'Masayang-masaya',
    'Super Happy',
    Icons.sentiment_very_satisfied_rounded,
    MoodTone.positive,
  ),
  happy(
    'Masaya',
    'Happy',
    Icons.sentiment_satisfied_rounded,
    MoodTone.positive,
  ),
  amused('Natutuwa', 'Giggly', Icons.emoji_emotions_rounded, MoodTone.positive),
  excited('Sabik', 'Excited', Icons.celebration_rounded, MoodTone.positive),
  calm('Payapa', 'Calm', Icons.spa_rounded, MoodTone.positive),
  confident(
    'May Tiwala',
    'Confident',
    Icons.thumb_up_rounded,
    MoodTone.positive,
  ),
  inLove('Nagmamahal', 'Loving', Icons.favorite_rounded, MoodTone.positive),
  proud('Mataas ang Moral', 'Proud', Icons.star_rounded, MoodTone.positive),
  sleepy('Inaantok', 'Sleepy', Icons.bedtime_rounded, MoodTone.neutral),
  bored(
    'Nababagot',
    'Bored',
    Icons.sentiment_neutral_rounded,
    MoodTone.neutral,
  ),
  confused('Lito', 'Confused', Icons.psychology_alt_rounded, MoodTone.neutral),
  worried(
    'Nangangamba',
    'Worried',
    Icons.sentiment_dissatisfied_rounded,
    MoodTone.negative,
  ),
  sad(
    'Malungkot',
    'Sad',
    Icons.sentiment_very_dissatisfied_rounded,
    MoodTone.negative,
  ),
  frustrated(
    'Inis / Aburido',
    'Frustrated',
    Icons.mood_bad_rounded,
    MoodTone.negative,
  ),
  angry(
    'Galit',
    'Angry',
    Icons.local_fire_department_rounded,
    MoodTone.negative,
  ),
  disgusted(
    'Nadedismaya',
    'Disappointed',
    Icons.heart_broken_rounded,
    MoodTone.negative,
  );

  const MoodType(this._fil, this._eng, this.icon, this.tone);

  final String _fil;
  final String _eng;
  final IconData icon;
  final MoodTone tone;

  /// Nakaimbak ang mood sa pangalan ng enum, hindi sa label, kaya ligtas
  /// isalin ito.
  String get label => tr(_fil, _eng);

  /// `null` kapag hindi kilala — kabilang ang tatlong lumang halaga
  /// (`Kalmado`, `Masigla`, `Pagod`) na naitala bago ang enum na ito.
  static MoodType? fromName(String? name) {
    if (name == null) return null;
    for (final mood in MoodType.values) {
      if (mood.name == name) return mood;
    }
    return null;
  }

  /// Ipinapakita ang lumang naitala nang buo sa halip na itapon.
  static String labelFor(String stored) => fromName(stored)?.label ?? stored;

  static IconData iconFor(String? stored) =>
      fromName(stored)?.icon ?? Icons.edit_note_rounded;

  static List<MoodType> inTone(MoodTone? tone) => tone == null
      ? values
      : values.where((mood) => mood.tone == tone).toList();

  static MoodType? fromLabel(String label) {
    for (final mood in MoodType.values) {
      if (mood.label == label) return mood;
    }
    return null;
  }
}
