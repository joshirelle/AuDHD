// lib/core/constants/sensory_constants.dart

enum SensoryType { seeking, avoiding }

class SensoryQuestion {
  final String id;
  final String domain;
  final String textTagalog;
  final SensoryType type;

  const SensoryQuestion({
    required this.id,
    required this.domain,
    required this.textTagalog,
    required this.type,
  });
}

class SensoryConstants {
  static const List<SensoryQuestion> questions = [
    // --- AUDITORY (PANDINIG) ---
    SensoryQuestion(
      id: 'aud_avoid',
      domain: 'Auditory',
      textTagalog: 'Tinatakpan ang tainga o umiiyak kapag nakakarinig ng malakas na ingay (vacuum, blender, kulog).',
      type: SensoryType.avoiding,
    ),
    SensoryQuestion(
      id: 'aud_seek',
      domain: 'Auditory',
      textTagalog: 'Mahilig gumawa ng sariling malakas na ingay o itinatapat ang tainga sa speaker/maingay na bagay.',
      type: SensoryType.seeking,
    ),

    // --- VISUAL (PANINGIN) ---
    SensoryQuestion(
      id: 'vis_avoid',
      domain: 'Visual',
      textTagalog: 'Tinatakpan ang mata, umiiwas, o mabilis masilaw sa maliwanag na ilaw.',
      type: SensoryType.avoiding,
    ),
    SensoryQuestion(
      id: 'vis_seek',
      domain: 'Visual',
      textTagalog: 'Matagal na tumititig sa mga umiikot na bagay (bentilador, gulong) o kumukutitap na ilaw.',
      type: SensoryType.seeking,
    ),

    // --- TACTILE (PANALAT) ---
    SensoryQuestion(
      id: 'tac_avoid',
      domain: 'Tactile',
      textTagalog: 'Ayaw madumihan ang kamay (putik, pintura) o umiiwas sa partikular na tekstura/tag ng damit.',
      type: SensoryType.avoiding,
    ),
    SensoryQuestion(
      id: 'tac_seek',
      domain: 'Tactile',
      textTagalog: 'Paulit-ulit na humahawak sa iba\'t ibang tekstura o nagpapakaluskos ng mga bagay sa balat.',
      type: SensoryType.seeking,
    ),

    // --- VESTIBULAR (BALANSE AT PAGGALAW) ---
    SensoryQuestion(
      id: 'ves_avoid',
      domain: 'Vestibular',
      textTagalog: 'Takot sa matataas na lugar, takot tumapak sa hindi pantay na lupa, o ayaw sa duyan/galaw.',
      type: SensoryType.avoiding,
    ),
    SensoryQuestion(
      id: 'ves_seek',
      domain: 'Vestibular',
      textTagalog: 'Mahilig magpaikot-ikot (spinning), tumalon-talon nang paulit-ulit, o sumakay sa mabilis na laruan.',
      type: SensoryType.seeking,
    ),

    // --- PROPRIOCEPTIVE (PRESYON SA KALAMNAN AT KASUKASUAN) ---
    SensoryQuestion(
      id: 'pro_avoid',
      domain: 'Proprioceptive',
      textTagalog: 'Umiiwas sa mahihigpit na yakap, ayaw na nahahawakan ang mga kasukasuan, o umiiwas sa mabibigat na kumot/aktibidad.',
      type: SensoryType.avoiding,
    ),
    SensoryQuestion(
      id: 'pro_seek',
      domain: 'Proprioceptive',
      textTagalog: 'Sinasadyang bumangga sa pader/muwebles, gustong pumailalim sa mabibigat na bagay, o humihingi ng mahigpit na yakap.',
      type: SensoryType.seeking,
    ),
  ];

  static const Map<int, String> ratingScale = {
    0: 'Hindi Kelanman (0)',
    1: 'Minsan (1)',
    2: 'Madalas (2)',
    3: 'Palagi (3)',
  };
}