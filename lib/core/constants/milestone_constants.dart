import '../../modules/milestones/models/milestone.dart';

class MilestoneConstants {
  static const List<Milestone> milestones = [
    // --- GROSS MOTOR ---
    Milestone(
      id: 'gm_1',
      titleTagalog: 'Nakakaupo nang may kaunting alalay.',
      domain: MilestoneDomain.grossMotor,
      targetAgeMonths: 6,
    ),
    Milestone(
      id: 'gm_2',
      titleTagalog: 'Nakakatayo habang nakahawak sa muwebles.',
      domain: MilestoneDomain.grossMotor,
      targetAgeMonths: 12,
    ),
    Milestone(
      id: 'gm_3',
      titleTagalog: 'Nakakalakad nang mag-isa.',
      domain: MilestoneDomain.grossMotor,
      targetAgeMonths: 18,
    ),
    Milestone(
      id: 'gm_4',
      titleTagalog: 'Nakakatakbo at nakakasipa ng bola.',
      domain: MilestoneDomain.grossMotor,
      targetAgeMonths: 24,
    ),

    // --- FINE MOTOR ---
    Milestone(
      id: 'fm_1',
      titleTagalog: 'Naaabot at nahahawakan ang laruan gamit ang buong palad.',
      domain: MilestoneDomain.fineMotor,
      targetAgeMonths: 6,
    ),
    Milestone(
      id: 'fm_2',
      titleTagalog:
          'Napupulot ang maliliit na bagay gamit ang hinlalaki at hintuturo.',
      domain: MilestoneDomain.fineMotor,
      targetAgeMonths: 12,
    ),
    Milestone(
      id: 'fm_3',
      titleTagalog: 'Nakakaguhit ng gusot o linya gamit ang krayola.',
      domain: MilestoneDomain.fineMotor,
      targetAgeMonths: 18,
    ),
    Milestone(
      id: 'fm_4',
      titleTagalog: 'Nakakapagpatong ng apat o higit pang bloke.',
      domain: MilestoneDomain.fineMotor,
      targetAgeMonths: 24,
    ),

    // --- SPEECH / LANGUAGE ---
    Milestone(
      id: 'sl_1',
      titleTagalog: 'Nag-uulit ng tunog tulad ng "ba-ba" o "ma-ma".',
      domain: MilestoneDomain.speechLanguage,
      targetAgeMonths: 6,
    ),
    Milestone(
      id: 'sl_2',
      titleTagalog: 'Nakakasabi ng isa o dalawang salitang may kahulugan.',
      domain: MilestoneDomain.speechLanguage,
      targetAgeMonths: 12,
    ),
    Milestone(
      id: 'sl_3',
      titleTagalog: 'Nakakasunod sa simpleng utos kahit walang senyas.',
      domain: MilestoneDomain.speechLanguage,
      targetAgeMonths: 18,
    ),
    Milestone(
      id: 'sl_4',
      titleTagalog: 'Nakakapagdugtong ng dalawang salita.',
      domain: MilestoneDomain.speechLanguage,
      targetAgeMonths: 24,
    ),

    // --- SOCIAL-EMOTIONAL ---
    Milestone(
      id: 'se_1',
      titleTagalog: 'Ngumingiti bilang tugon sa pamilyar na mukha.',
      domain: MilestoneDomain.socialEmotional,
      targetAgeMonths: 6,
    ),
    Milestone(
      id: 'se_2',
      titleTagalog: 'Tumuturo sa bagay na gusto niyang ipakita sa iyo.',
      domain: MilestoneDomain.socialEmotional,
      targetAgeMonths: 12,
    ),
    Milestone(
      id: 'se_3',
      titleTagalog: 'Ginagaya ang gawain ng matanda sa bahay.',
      domain: MilestoneDomain.socialEmotional,
      targetAgeMonths: 18,
    ),
    Milestone(
      id: 'se_4',
      titleTagalog: 'Nakikipaglaro sa tabi ng ibang bata.',
      domain: MilestoneDomain.socialEmotional,
      targetAgeMonths: 24,
    ),
  ];

  static List<Milestone> inDomain(MilestoneDomain? domain) => domain == null
      ? milestones
      : milestones.where((m) => m.domain == domain).toList();
}
