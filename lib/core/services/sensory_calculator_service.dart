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
        domainSeekingScores[q.domain] = (domainSeekingScores[q.domain] ?? 0) + score;
      } else {
        totalAvoiding += score;
        domainAvoidingScores[q.domain] = (domainAvoidingScores[q.domain] ?? 0) + score;
      }
    }

    // Pangkalahatang Classification Logic
    String overallProfile = 'Typical Sensory Processing';
    final scoreDiff = totalSeeking - totalAvoiding;

    if (totalSeeking > 12 && totalAvoiding > 12) {
      overallProfile = 'Mixed Profile (Seeking & Sensitive)';
    } else if (scoreDiff >= 5) {
      overallProfile = 'Sensory Seeking (High Movement/Input Need)';
    } else if (scoreDiff <= -5) {
      overallProfile = 'Sensory Avoiding (Hyper-sensitive / Over-responsive)';
    }

    // Per Domain Breakdown
    final Map<String, String> domainBreakdown = {};
    final domains = ['Auditory', 'Visual', 'Tactile', 'Vestibular', 'Proprioceptive'];

    for (var d in domains) {
      final sScore = domainSeekingScores[d] ?? 0;
      final aScore = domainAvoidingScores[d] ?? 0;

      if (sScore > aScore && sScore >= 2) {
        domainBreakdown[d] = 'Sensory Seeking';
      } else if (aScore > sScore && aScore >= 2) {
        domainBreakdown[d] = 'Sensory Avoiding';
      } else if (sScore >= 2 && aScore >= 2) {
        domainBreakdown[d] = 'Mixed Responsiveness';
      } else {
        domainBreakdown[d] = 'Typical / Balanced';
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