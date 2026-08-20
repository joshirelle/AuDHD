import '../i18n/language_controller.dart';

enum MoodTone { positive, neutral, negative }

/// Ang emoji ang palaging ipinapakita; asset lang kapag may naidagdag na
/// larawan. Huwag ideklara ang `assets/moods/` sa pubspec hangga't walang laman
/// ang folder — bibigo ang build.
enum MoodType {
  joyful('Masayang-masaya', 'Super Happy', '\u{1F33B}', MoodTone.positive, 'joyful'),
  happy('Masaya', 'Happy', '\u2600\uFE0F', MoodTone.positive, 'happy'),
  amused('Natutuwa', 'Giggly', '\u{1F604}', MoodTone.positive, 'amused'),
  excited('Sabik', 'Excited', '\u{1F389}', MoodTone.positive, 'excited'),
  calm('Payapa', 'Calm', '\u{1F338}', MoodTone.positive, 'calm'),
  confident('May Tiwala', 'Confident', '\u{1F4AA}', MoodTone.positive, 'confident'),
  inLove('Nagmamahal', 'Loving', '\u{1F496}', MoodTone.positive, 'in_love'),
  proud('Mataas ang Moral', 'Proud', '\u2B50', MoodTone.positive, 'proud'),
  sleepy('Inaantok', 'Sleepy', '\u{1F634}', MoodTone.neutral, 'sleepy'),
  bored('Nababagot', 'Bored', '\u{1F971}', MoodTone.neutral, 'bored'),
  confused('Lito', 'Confused', '\u{1F914}', MoodTone.neutral, 'confused'),
  worried('Nangangamba', 'Worried', '\u{1F61F}', MoodTone.negative, 'worried'),
  sad('Malungkot', 'Sad', '\u2601\uFE0F', MoodTone.negative, 'sad'),
  frustrated('Inis / Aburido', 'Frustrated', '\u{1F624}', MoodTone.negative, 'frustrated'),
  angry('Galit', 'Angry', '\u{1F525}', MoodTone.negative, 'angry'),
  disgusted('Nadedismaya', 'Disappointed', '\u{1F922}', MoodTone.negative, 'disgusted');

  const MoodType(this._fil, this._eng, this.emoji, this.tone, this._assetName);

  final String _fil;
  final String _eng;
  final String emoji;
  final MoodTone tone;
  final String _assetName;

  /// Nakaimbak ang mood sa pangalan ng enum, hindi sa label, kaya ligtas
  /// isalin ito.
  String get label => tr(_fil, _eng);

  String get assetPath => 'assets/moods/$_assetName.png';

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

  static String? emojiFor(String stored) => fromName(stored)?.emoji;

  static MoodType? fromLabel(String label) {
    for (final mood in MoodType.values) {
      if (mood.label == label) return mood;
    }
    return null;
  }
}
