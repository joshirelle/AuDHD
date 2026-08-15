enum SensoryType { seeking, avoiding }

class SensoryQuestion {
  final String id;
  final String domain; // Auditory, Visual, Tactile, Vestibular, Proprioceptive
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
      id: 'aud_avoid_1',
      domain: 'Auditory',
      textTagalog: 'Tinatakpan ang tainga o umiiyak kapag nakakarinig ng malakas na ingay (vacuum, blender, thunder).',
      type: SensoryType.avoiding,
    ),
    SensoryQuestion(
      id: 'aud_seek_1',
      domain: 'Auditory',
      textTagalog: 'Mahilig gumawa ng sariling malakas na ingay o itinatapat ang tainga sa speaker/maingay na bagay.',
      type: SensoryType.seeking,
    ),

    // --- VISUAL (PANINGIN) ---
    SensoryQuestion(
      id: 'vis_avoid_1',
      domain: 'Visual',
      textTagalog: 'Tinatakpan ang mata, umiiwas, o mabilis masilaw sa maliwanag na ilaw.',
      type: SensoryType.avoiding,
    ),
    SensoryQuestion(
      id: 'vis_seek_1',
      domain: 'Visual',
      textTagalog: 'Matagal na tumititig sa mga umiikot na bagay (bentilador, gulong) o kumukutitap na ilaw.',
      type: SensoryType.seeking,
    ),

    // --- TACTILE (PANALAT) ---
    SensoryQuestion(
      id: 'tac_avoid_1',
      domain: 'Tactile',
      textTagalog: 'Ayaw madumihan ang kamay (putik, pintura, glue) o ayaw sa partikular na tela/tag ng damit.',
      type: SensoryType.avoiding,
    ),
    SensoryQuestion(
      id: 'tac_seek_1',
      domain: 'Tactile',
      textTagalog: 'Paulit-ulit na humahawak o nagpapakaluskos sa iba\'t ibang tekstura ng bagay o ibabaw.',
      type: SensoryType.seeking,
    ),

    // --- VESTIBULAR (BALANSE AT PAGGALAW) ---
    SensoryQuestion(
      id: 'ves_avoid_1',
      domain: 'Vestibular',
      textTagalog: 'Takot sa matataas na lugar, takot tumapak sa hindi pantay na lupa, o ayaw sa duyan/playground equipment.',
      type: SensoryType.avoiding,
    ),
    SensoryQuestion(
      id: 'ves_seek_1',
      domain: 'Vestibular',
      textTagalog: 'Mahilig magpaikot-ikot (spinning), tumalon-talon nang paulit-ulit, o sumakay sa mabilis na laruan.',
      type: SensoryType.seeking,
    ),

    // --- PROPRIOCEPTIVE (PRESYON SA KALAMNAN) ---
    SensoryQuestion(
      id: 'pro_seek_1',
      domain: 'Proprioceptive',
      textTagalog: 'Sinasadyang bumangga sa pader/muwebles, gustong pumailalim sa mabibigat na unan, o nang-yayakap nang napakahigpit.',
      type: SensoryType.seeking,
    ),
    SensoryQuestion(
      id: 'pro_seek_2',
      domain: 'Proprioceptive',
      textTagalog: 'Mahilig mangangat ng hindi pagkain (kamay, damit, lapis, laruan).',
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