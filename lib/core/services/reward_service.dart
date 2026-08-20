import '../../data/services/hive_service.dart';
import '../models/reward.dart';
import 'star_service.dart';

class RewardService {
  /// Walang default: ang magulang ang nakakaalam kung ano ang tunay na
  /// pabuya sa kanilang bahay, kaya sila ang naglalagay ng lahat.
  static List<Reward> all() {
    final box = HiveService.getRewardBox();
    return <Reward>[
      for (final key in box.keys)
        Reward(label: key as String, stars: box.get(key)!, isCustom: true),
    ]..sort((a, b) => a.stars.compareTo(b.stars));
  }

  static String _seenKey(String label) => 'reward_seen_$label';

  static bool wasCelebrated(String label) =>
      HiveService.hasSeen(_seenKey(label));

  static Future<void> markCelebrated(String label) =>
      HiveService.markSeen(_seenKey(label));

  /// Naabot na ang bituin pero hindi pa naipagdiriwang.
  static List<Reward> newlyUnlocked(int totalStars) => all()
      .where((reward) => totalStars >= reward.stars && !wasCelebrated(reward.label))
      .toList();

  static Future<void> addCustom(String label, int stars) async {
    await HiveService.addCustomReward(label, stars);
    // Walang bagong tagumpay kung naabot na ang bituin bago pa ito idagdag,
    // kaya tahimik na markahan sa halip na sumabog agad ang confetti.
    if (StarService.totalStars() >= stars) {
      await markCelebrated(label.trim());
    }
  }

  static Future<void> deleteCustom(String label) =>
      HiveService.deleteCustomReward(label);
}
