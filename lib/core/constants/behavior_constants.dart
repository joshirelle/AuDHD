import '../i18n/language_controller.dart';

/// Mungkahi lang ang mga ito. Ang mismong napili ang naiimbak sa `behavior_logs`,
/// kaya nakasulat ito sa wikang gamit noong itinala.
class BehaviorConstants {
  static List<String> get commonAntecedents => [
    tr('Malakas na ingay o kaluskos', 'Loud noise or rustling sounds'),
    tr('Maliwanag o kumukutitap na ilaw', 'Bright or flickering lights'),
    tr('Biglaang pagbabago sa nakagawian', 'Sudden change in routine'),
    tr('Mahirap o maraming hakbang na gawain', 'Hard or multi-step task'),
    tr('Pagod o kulang sa tulog', 'Tired or lacking sleep'),
    tr(
      'Gutom, nauuhaw, o may masakit sa katawan',
      'Hungry, thirsty, or body aches',
    ),
    tr('Sikip o tekstura ng damit', 'Tight or textured clothing'),
    tr('Maraming tao o bagong kapaligiran', 'Crowds or a new place'),
    tr(
      'Inagawan ng laruan o pinagbawalan sa gadget',
      'Toy taken away or gadget not allowed',
    ),
  ];

  static List<String> get commonBehaviors => [
    tr('Meltdown o malakas na pag-iyak', 'Meltdown or loud crying'),
    tr('Pagtakip ng tainga o mata', 'Covering ears or eyes'),
    tr(
      'Paulit-ulit na galaw (pagkampay, pag-ikot, pag-uga)',
      'Repeated movement (flapping, spinning, rocking)',
    ),
    tr('Pambabato o paghahagis ng gamit', 'Throwing or tossing things'),
    tr(
      'Pananakit sa sarili (pangangagat, pag-uuntog)',
      'Hurting self (biting, head-banging)',
    ),
    tr('Pagtakbo nang malayo o pagtatago', 'Running off or hiding'),
    tr('Pagtili o pag-angil nang malakas', 'Screaming or groaning loudly'),
    tr('Pagmamatigas o pagtanggi', 'Refusing or resisting'),
  ];

  static List<String> get commonConsequences => [
    tr(
      'Inilipat sa tahimik na lugar o inalis ang sanhi',
      'Moved to a quiet place or removed the cause',
    ),
    tr(
      'Binigyan ng headphones o gamit na nakakapagpakalma',
      'Gave headphones or a calming item',
    ),
    tr(
      'Binigyan ng mabigat na kumot o mahigpit na yakap',
      'Gave a weighted blanket or a firm hug',
    ),
    tr('Kinausap at niyakap para kumalma', 'Talked to and hugged to calm down'),
    tr('Inalis muna ang mahirap na gawain', 'Set the hard task aside for now'),
    tr(
      'Binigyan ng gustong laruan, pagkain, o gadget',
      'Gave the toy, food, or gadget wanted',
    ),
  ];

  /// Filipino muna, tapos ang klinikal na termino — nakikita ng magulang ang
  /// una, nakikita ng doktor ang pangalawa sa PDF.
  static List<String> get sensoryCategories => [
    tr('Pandinig (Auditory)', 'Hearing (Auditory)'),
    tr('Paningin (Visual)', 'Sight (Visual)'),
    tr('Paghipo at tekstura (Tactile)', 'Touch and texture (Tactile)'),
    tr('Balanse at paggalaw (Vestibular)', 'Balance and movement (Vestibular)'),
    tr(
      'Lakas at presyon (Proprioceptive)',
      'Force and pressure (Proprioceptive)',
    ),
    tr(
      'Panloob na pakiramdam, gutom o sakit (Interoception)',
      'Inner feelings, hunger or pain (Interoception)',
    ),
  ];
}