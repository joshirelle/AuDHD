import '../i18n/language_controller.dart';

/// Magkapares na Filipino at Ingles ng isang mungkahi. Kailangang nakikita ang
/// dalawang wika para matukoy pa rin ang lumang tala kahit nagpalit ng wika.
class BehaviorOption {
  const BehaviorOption(this.fil, this.eng);

  final String fil;
  final String eng;

  String get label => tr(fil, eng);
}

/// Mungkahi lang ang mga ito. Ang mismong napili ang naiimbak sa `behavior_logs`,
/// kaya nakasulat ito sa wikang gamit noong itinala. Dumaan sa [localize] bago
/// ipakita at sa [canonical] bago bilangin.
class BehaviorConstants {
  static const List<BehaviorOption> antecedentOptions = [
    BehaviorOption(
      'Malakas na ingay o kaluskos',
      'Loud noise or rustling sounds',
    ),
    BehaviorOption(
      'Maliwanag o kumukutitap na ilaw',
      'Bright or flickering lights',
    ),
    BehaviorOption(
      'Biglaang pagbabago sa nakagawian',
      'Sudden change in routine',
    ),
    BehaviorOption(
      'Mahirap o maraming hakbang na gawain',
      'Hard or multi-step task',
    ),
    BehaviorOption('Pagod o kulang sa tulog', 'Tired or lacking sleep'),
    BehaviorOption(
      'Gutom, nauuhaw, o may masakit sa katawan',
      'Hungry, thirsty, or body aches',
    ),
    BehaviorOption('Sikip o tekstura ng damit', 'Tight or textured clothing'),
    BehaviorOption(
      'Maraming tao o bagong kapaligiran',
      'Crowds or a new place',
    ),
    BehaviorOption(
      'Inagawan ng laruan o pinagbawalan sa gadget',
      'Toy taken away or gadget not allowed',
    ),
  ];

  static const List<BehaviorOption> behaviorOptions = [
    BehaviorOption('Meltdown o malakas na pag-iyak', 'Meltdown or loud crying'),
    BehaviorOption('Pagtakip ng tainga o mata', 'Covering ears or eyes'),
    BehaviorOption(
      'Paulit-ulit na galaw (pagkampay, pag-ikot, pag-uga)',
      'Repeated movement (flapping, spinning, rocking)',
    ),
    BehaviorOption(
      'Pambabato o paghahagis ng gamit',
      'Throwing or tossing things',
    ),
    BehaviorOption(
      'Pananakit sa sarili (pangangagat, pag-uuntog)',
      'Hurting self (biting, head-banging)',
    ),
    BehaviorOption('Pagtakbo nang malayo o pagtatago', 'Running off or hiding'),
    BehaviorOption(
      'Pagtili o pag-angil nang malakas',
      'Screaming or groaning loudly',
    ),
    BehaviorOption('Pagmamatigas o pagtanggi', 'Refusing or resisting'),
  ];

  static const List<BehaviorOption> consequenceOptions = [
    BehaviorOption(
      'Inilipat sa tahimik na lugar o inalis ang sanhi',
      'Moved to a quiet place or removed the cause',
    ),
    BehaviorOption(
      'Binigyan ng headphones o gamit na nakakapagpakalma',
      'Gave headphones or a calming item',
    ),
    BehaviorOption(
      'Binigyan ng mabigat na kumot o mahigpit na yakap',
      'Gave a weighted blanket or a firm hug',
    ),
    BehaviorOption(
      'Kinausap at niyakap para kumalma',
      'Talked to and hugged to calm down',
    ),
    BehaviorOption(
      'Inalis muna ang mahirap na gawain',
      'Set the hard task aside for now',
    ),
    BehaviorOption(
      'Binigyan ng gustong laruan, pagkain, o gadget',
      'Gave the toy, food, or gadget wanted',
    ),
  ];

  /// Filipino muna, tapos ang klinikal na termino — nakikita ng magulang ang
  /// una, nakikita ng doktor ang pangalawa sa PDF.
  static const List<BehaviorOption> sensoryOptions = [
    BehaviorOption('Pandinig (Auditory)', 'Hearing (Auditory)'),
    BehaviorOption('Paningin (Visual)', 'Sight (Visual)'),
    BehaviorOption(
      'Paghipo at tekstura (Tactile)',
      'Touch and texture (Tactile)',
    ),
    BehaviorOption(
      'Balanse at paggalaw (Vestibular)',
      'Balance and movement (Vestibular)',
    ),
    BehaviorOption(
      'Lakas at presyon (Proprioceptive)',
      'Force and pressure (Proprioceptive)',
    ),
    BehaviorOption(
      'Panloob na pakiramdam, gutom o sakit (Interoception)',
      'Inner feelings, hunger or pain (Interoception)',
    ),
  ];

  static List<String> get commonAntecedents =>
      antecedentOptions.map((o) => o.label).toList();

  static List<String> get commonBehaviors =>
      behaviorOptions.map((o) => o.label).toList();

  static List<String> get commonConsequences =>
      consequenceOptions.map((o) => o.label).toList();

  static List<String> get sensoryCategories =>
      sensoryOptions.map((o) => o.label).toList();

  /// Ang naitala, sa Filipino man o Ingles, ay tumuturo sa parehong pares.
  static final Map<String, BehaviorOption> _byText = {
    for (final o in [
      ...antecedentOptions,
      ...behaviorOptions,
      ...consequenceOptions,
      ...sensoryOptions,
    ]) ...{o.fil: o, o.eng: o},
  };

  /// Ibinabalik ang naitala sa wikang gamit ngayon. Ang sariling sulat ng
  /// magulang ay hindi kilala rito, kaya ibinabalik nang buo at hindi ginagalaw.
  static String localize(String stored) => _byText[stored]?.label ?? stored;

  /// Iisang susi para sa magkatulad na tala kahit magkaibang wika ang ginamit,
  /// para hindi mahati sa dalawa ang bilang sa analytics.
  static String canonical(String stored) => _byText[stored]?.fil ?? stored;
}
