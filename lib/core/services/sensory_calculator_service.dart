// lib/core/services/sensory_calculator_service.dart

import '../constants/sensory_constants.dart';

class SensoryCalculatorService {
  static Map<String, dynamic> calculateProfile(Map<String, int> answers) {
    int totalSeeking = 0;
    int totalAvoiding = 0;

    final Map<String, int> domainSeekingScores = {};
    final Map<String, int> domainAvoidingScores = {};

    for (var q in SensoryConstants.questions) {
      final score = answers[q.id] ?? 0;

      if (q.type == SensoryType.seeking) {
        totalSeeking += score;
        domainSeekingScores[q.domain] = score;
      } else {
        totalAvoiding += score;
        domainAvoidingScores[q.domain] = score;
      }
    }

    // Inayos na Classification Logic (Max = 15 bawat kategorya)
    String overallProfile = 'Typical / Balanced Processing';

    if (totalSeeking >= 8 && totalAvoiding >= 8) {
      overallProfile = 'Mixed Profile (Seeking & Sensitive)';
    } else if ((totalSeeking - totalAvoiding) >= 4) {
      overallProfile = 'Sensory Seeking (High Movement / Input Need)';
    } else if ((totalAvoiding - totalSeeking) >= 4) {
      overallProfile = 'Sensory Avoiding (Hyper-sensitive / Sensitive)';
    }

    // Per-Domain Breakdown
    final Map<String, String> domainBreakdown = {};
    final domains = ['Auditory', 'Visual', 'Tactile', 'Vestibular', 'Proprioceptive'];

    for (var d in domains) {
      final sScore = domainSeekingScores[d] ?? 0;
      final aScore = domainAvoidingScores[d] ?? 0;

      if (sScore >= 2 && aScore >= 2) {
        domainBreakdown[d] = 'Mixed';
      } else if (sScore >= 2 && sScore > aScore) {
        domainBreakdown[d] = 'Seeking';
      } else if (aScore >= 2 && aScore > sScore) {
        domainBreakdown[d] = 'Avoiding';
      } else {
        domainBreakdown[d] = 'Typical';
      }
    }

    return {
      'totalSeekingScore': totalSeeking,
      'totalAvoidingScore': totalAvoiding,
      'primaryProfile': overallProfile,
      'domainBreakdown': domainBreakdown,
    };
  }
}