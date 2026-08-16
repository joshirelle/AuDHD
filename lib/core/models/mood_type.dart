enum MoodTone { positive, neutral, negative }

/// Ang emoji ang palaging ipinapakita; asset lang kapag may naidagdag na
/// larawan. Huwag ideklara ang `assets/moods/` sa pubspec hangga't walang laman
/// ang folder — bibigo ang build.
enum MoodType {
  joyful('Masayang-masaya', '\u{1F33B}', MoodTone.positive, 'joyful'),
  happy('Masaya', '\u2600\uFE0F', MoodTone.positive, 'happy'),
  amused('Natutuwa', '\u{1F604}', MoodTone.positive, 'amused'),
  excited('Sabik', '\u{1F389}', MoodTone.positive, 'excited'),
  calm('Payapa', '\u{1F338}', MoodTone.positive, 'calm'),
  confident('May Tiwala', '\u{1F4AA}', MoodTone.positive, 'confident'),
  inLove('Nagmamahal', '\u{1F496}', MoodTone.positive, 'in_love'),
  proud('Mataas ang Moral', '\u2B50', MoodTone.positive, 'proud'),
  sleepy('Inaantok', '\u{1F634}', MoodTone.neutral, 'sleepy'),
  bored('Nababagot', '\u{1F971}', MoodTone.neutral, 'bored'),
  confused('Lito', '\u{1F914}', MoodTone.neutral, 'confused'),
  worried('Nangangamba', '\u{1F61F}', MoodTone.negative, 'worried'),
  sad('Malungkot', '\u2601\uFE0F', MoodTone.negative, 'sad'),
  frustrated('Inis / Aburido', '\u{1F624}', MoodTone.negative, 'frustrated'),
  angry('Galit', '\u{1F525}', MoodTone.negative, 'angry'),
  disgusted('Nadedismaya', '\u{1F922}', MoodTone.negative, 'disgusted');

  const MoodType(this.label, this.emoji, this.tone, this._assetName);

  final String label;
  final String emoji;
  final MoodTone tone;
  final String _assetName;

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
