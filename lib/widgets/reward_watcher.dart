import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/models/reward.dart';
import '../core/services/reward_service.dart';
import '../core/services/star_service.dart';
import '../data/services/hive_service.dart';
import 'goal_achieved_overlay.dart';

/// Nakikinig sa bituin saanman naroon ang magulang, kaya nakakabit ito sa
/// `MaterialApp.builder` — sa ibabaw ng Navigator at hindi namamatay sa
/// paglipat ng screen.
class RewardWatcher extends StatefulWidget {
  final Widget child;

  const RewardWatcher({super.key, required this.child});

  /// Nasa ibabaw ng Navigator ang widget na ito, kaya kailangan ng susi para
  /// makakuha ng context na kayang magpakita ng dialog.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  State<RewardWatcher> createState() => _RewardWatcherState();
}

class _RewardWatcherState extends State<RewardWatcher> {
  late final Listenable _sources;
  bool _isCelebrating = false;

  @override
  void initState() {
    super.initState();
    _sources = Listenable.merge([
      StarService.listenable,
      HiveService.getRewardBox().listenable(),
    ]);
    _sources.addListener(_onStarsChanged);
  }

  @override
  void dispose() {
    _sources.removeListener(_onStarsChanged);
    super.dispose();
  }

  void _onStarsChanged() {
    if (_isCelebrating) return;
    final unlocked = RewardService.newlyUnlocked(StarService.totalStars());
    if (unlocked.isEmpty) return;
    _celebrate(unlocked);
  }

  Future<void> _celebrate(List<Reward> rewards) async {
    _isCelebrating = true;
    // Markahan bago ipakita: kung magbabago muli ang bituin habang bukas ang
    // dialog, hindi na ito uulit para sa parehong pabuya.
    for (final reward in rewards) {
      await RewardService.markCelebrated(reward.label);
    }

    // Nagmumula ang tawag na ito sa gitna ng frame ng Hive listener.
    await WidgetsBinding.instance.endOfFrame;
    final navigatorContext = RewardWatcher.navigatorKey.currentContext;
    if (navigatorContext != null && navigatorContext.mounted) {
      await GoalAchievedOverlay.show(navigatorContext, rewards);
    }
    _isCelebrating = false;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
