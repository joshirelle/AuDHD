import '../../data/services/hive_service.dart';
import '../models/reward.dart';
import 'star_service.dart';

class RewardService {
  /// Nasa code para maabot ng update ng app ang lahat ng user; ang mga dagdag
  /// ng magulang ay nasa `custom_rewards`.
  static const List<Reward> defaults = [
    Reward(label: '15 minutong dagdag na laro sa labas', stars: 5),
    Reward(label: 'Paboritong meryenda', stars: 10),
    Reward(label: 'Kwento bago matulog', stars: 15),
  ];

  static List<Reward> all() {
    final box = HiveService.getRewardBox();
    return <Reward>[
      ...defaults,
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
