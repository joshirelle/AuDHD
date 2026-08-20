// lib/core/constants/sensory_constants.dart

import '../i18n/language_controller.dart';

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
  // Getter na, hindi const: tumatawag ng `tr()` ang teksto ng tanong.
  // Ang `id` at `domain` ay susi — hindi isinasalin.
  static List<SensoryQuestion> get questions => [
    // --- AUDITORY (PANDINIG) ---
    SensoryQuestion(
      id: 'aud_avoid',
      domain: 'Auditory',
      textTagalog: tr(
        'Tinatakpan ang tainga o umiiyak kapag nakakarinig ng malakas na ingay (vacuum, blender, kulog).',
        'Covers the ears or cries when hearing loud noise (vacuum, blender, thunder).',
      ),
      type: SensoryType.avoiding,
    ),
    SensoryQuestion(
      id: 'aud_seek',
      domain: 'Auditory',
      textTagalog: tr(
        'Mahilig gumawa ng sariling malakas na ingay o itinatapat ang tainga sa speaker/maingay na bagay.',
        'Likes making loud noises or puts an ear right up to a speaker or noisy object.',
      ),
      type: SensoryType.seeking,
    ),

    // --- VISUAL (PANINGIN) ---
    SensoryQuestion(
      id: 'vis_avoid',
      domain: 'Visual',
      textTagalog: tr(
        'Tinatakpan ang mata, umiiwas, o mabilis masilaw sa maliwanag na ilaw.',
        'Covers the eyes, looks away, or is quickly dazzled by bright light.',
      ),
      type: SensoryType.avoiding,
    ),
    SensoryQuestion(
      id: 'vis_seek',
      domain: 'Visual',
      textTagalog: tr(
        'Matagal na tumititig sa mga umiikot na bagay (bentilador, gulong) o kumukutitap na ilaw.',
        'Stares for a long time at spinning things (fan, wheels) or flickering lights.',
      ),
      type: SensoryType.seeking,
    ),

    // --- TACTILE (PANALAT) ---
    SensoryQuestion(
      id: 'tac_avoid',
      domain: 'Tactile',
      textTagalog: tr(
        'Ayaw madumihan ang kamay (putik, pintura) o umiiwas sa partikular na tekstura/tag ng damit.',
        'Does not want dirty hands (mud, paint) or avoids certain textures or clothing tags.',
      ),
      type: SensoryType.avoiding,
    ),
    SensoryQuestion(
      id: 'tac_seek',
      domain: 'Tactile',
      textTagalog: tr(
        'Paulit-ulit na humahawak sa iba\'t ibang tekstura o nagpapakaluskos ng mga bagay sa balat.',
        'Keeps touching different textures or rubs things against the skin.',
      ),
      type: SensoryType.seeking,
    ),

    // --- VESTIBULAR (BALANSE AT PAGGALAW) ---
    SensoryQuestion(
      id: 'ves_avoid',
      domain: 'Vestibular',
      textTagalog: tr(
        'Takot sa matataas na lugar, takot tumapak sa hindi pantay na lupa, o ayaw sa duyan/galaw.',
        'Afraid of high places, afraid to step on uneven ground, or dislikes swings and movement.',
      ),
      type: SensoryType.avoiding,
    ),
    SensoryQuestion(
      id: 'ves_seek',
      domain: 'Vestibular',
      textTagalog: tr(
        'Mahilig magpaikot-ikot (spinning), tumalon-talon nang paulit-ulit, o sumakay sa mabilis na laruan.',
        'Loves to spin around, jump over and over, or ride fast rides.',
      ),
      type: SensoryType.seeking,
    ),

    // --- PROPRIOCEPTIVE (PRESYON SA KALAMNAN AT KASUKASUAN) ---
    SensoryQuestion(
      id: 'pro_avoid',
      domain: 'Proprioceptive',
      textTagalog: tr(
        'Umiiwas sa mahihigpit na yakap, ayaw na nahahawakan ang mga kasukasuan, o umiiwas sa mabibigat na kumot/aktibidad.',
        'Avoids tight hugs, dislikes having the joints held, or avoids heavy blankets and heavy activity.',
      ),
      type: SensoryType.avoiding,
    ),
    SensoryQuestion(
      id: 'pro_seek',
      domain: 'Proprioceptive',
      textTagalog: tr(
        'Sinasadyang bumangga sa pader/muwebles, gustong pumailalim sa mabibigat na bagay, o humihingi ng mahigpit na yakap.',
        'Bumps into walls or furniture on purpose, likes being under heavy things, or asks for tight hugs.',
      ),
      type: SensoryType.seeking,
    ),
  ];

  static Map<int, String> get ratingScale => {
    0: tr('Hindi Kelanman (0)', 'Never (0)'),
    1: tr('Minsan (1)', 'Sometimes (1)'),
    2: tr('Madalas (2)', 'Often (2)'),
    3: tr('Palagi (3)', 'Always (3)'),
  };
}