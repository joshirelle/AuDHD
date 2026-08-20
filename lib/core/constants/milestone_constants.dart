import '../../modules/milestones/models/milestone.dart';

class MilestoneConstants {
  static const List<Milestone> milestones = [
    // --- GROSS MOTOR ---
    Milestone(
      id: 'gm_1',
      titleFil: 'Nakakaupo nang may kaunting alalay.',
      titleEng: 'Sits up with a little support.',
      domain: MilestoneDomain.grossMotor,
      targetAgeMonths: 6,
    ),
    Milestone(
      id: 'gm_2',
      titleFil: 'Nakakatayo habang nakahawak sa muwebles.',
      titleEng: 'Stands while holding on to furniture.',
      domain: MilestoneDomain.grossMotor,
      targetAgeMonths: 12,
    ),
    Milestone(
      id: 'gm_3',
      titleFil: 'Nakakalakad nang mag-isa.',
      titleEng: 'Walks without help.',
      domain: MilestoneDomain.grossMotor,
      targetAgeMonths: 18,
    ),
    Milestone(
      id: 'gm_4',
      titleFil: 'Nakakatakbo at nakakasipa ng bola.',
      titleEng: 'Runs and kicks a ball.',
      domain: MilestoneDomain.grossMotor,
      targetAgeMonths: 24,
    ),

    // --- FINE MOTOR ---
    Milestone(
      id: 'fm_1',
      titleFil: 'Naaabot at nahahawakan ang laruan gamit ang buong palad.',
      titleEng: 'Reaches for and holds a toy with the whole palm.',
      domain: MilestoneDomain.fineMotor,
      targetAgeMonths: 6,
    ),
    Milestone(
      id: 'fm_2',
      titleFil:
          'Napupulot ang maliliit na bagay gamit ang hinlalaki at hintuturo.',
      titleEng: 'Picks up small things with thumb and forefinger.',
      domain: MilestoneDomain.fineMotor,
      targetAgeMonths: 12,
    ),
    Milestone(
      id: 'fm_3',
      titleFil: 'Nakakaguhit ng gusot o linya gamit ang krayola.',
      titleEng: 'Scribbles or draws lines with a crayon.',
      domain: MilestoneDomain.fineMotor,
      targetAgeMonths: 18,
    ),
    Milestone(
      id: 'fm_4',
      titleFil: 'Nakakapagpatong ng apat o higit pang bloke.',
      titleEng: 'Stacks four or more blocks.',
      domain: MilestoneDomain.fineMotor,
      targetAgeMonths: 24,
    ),

    // --- SPEECH / LANGUAGE ---
    Milestone(
      id: 'sl_1',
      titleFil: 'Nag-uulit ng tunog tulad ng "ba-ba" o "ma-ma".',
      titleEng: 'Repeats sounds like "ba-ba" or "ma-ma".',
      domain: MilestoneDomain.speechLanguage,
      targetAgeMonths: 6,
    ),
    Milestone(
      id: 'sl_2',
      titleFil: 'Nakakasabi ng isa o dalawang salitang may kahulugan.',
      titleEng: 'Says one or two words that carry meaning.',
      domain: MilestoneDomain.speechLanguage,
      targetAgeMonths: 12,
    ),
    Milestone(
      id: 'sl_3',
      titleFil: 'Nakakasunod sa simpleng utos kahit walang senyas.',
      titleEng: 'Follows a simple request even without a gesture.',
      domain: MilestoneDomain.speechLanguage,
      targetAgeMonths: 18,
    ),
    Milestone(
      id: 'sl_4',
      titleFil: 'Nakakapagdugtong ng dalawang salita.',
      titleEng: 'Puts two words together.',
      domain: MilestoneDomain.speechLanguage,
      targetAgeMonths: 24,
    ),

    // --- SOCIAL-EMOTIONAL ---
    Milestone(
      id: 'se_1',
      titleFil: 'Ngumingiti bilang tugon sa pamilyar na mukha.',
      titleEng: 'Smiles back at a familiar face.',
      domain: MilestoneDomain.socialEmotional,
      targetAgeMonths: 6,
    ),
    Milestone(
      id: 'se_2',
      titleFil: 'Tumuturo sa bagay na gusto niyang ipakita sa iyo.',
      titleEng: 'Points at something to show it to you.',
      domain: MilestoneDomain.socialEmotional,
      targetAgeMonths: 12,
    ),
    Milestone(
      id: 'se_3',
      titleFil: 'Ginagaya ang gawain ng matanda sa bahay.',
      titleEng: 'Copies what the grown-ups do at home.',
      domain: MilestoneDomain.socialEmotional,
      targetAgeMonths: 18,
    ),
    Milestone(
      id: 'se_4',
      titleFil: 'Nakikipaglaro sa tabi ng ibang bata.',
      titleEng: 'Plays alongside other children.',
      domain: MilestoneDomain.socialEmotional,
      targetAgeMonths: 24,
    ),
  ];

  static List<Milestone> inDomain(MilestoneDomain? domain) => domain == null
      ? milestones
      : milestones.where((m) => m.domain == domain).toList();
}
