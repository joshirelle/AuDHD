import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/services/hive_service.dart';

/// Kinukwenta ang bituin mula mismo sa mga box para walang hiwalay na counter
/// na maaaring mahuli sa aktwal na progreso.
class StarService {
  static const int starsPerSensoryActivity = 1;
  static const int starsPerMilestone = 2;

  static Listenable? _listenable;

  /// Nagbabago kapag may natapos na laro, milestone, o gawain sa iskedyul.
  static Listenable get listenable => _listenable ??= Listenable.merge([
    HiveService.getCompletionBox().listenable(),
    HiveService.getMilestoneBox().listenable(),
    HiveService.getScheduleDoneBox().listenable(),
  ]);

  static int sensoryStars() =>
      HiveService.getCompletionBox().length * starsPerSensoryActivity;

  static int milestoneStars() =>
      HiveService.getMilestoneBox().length * starsPerMilestone;

  /// Suma ng naitalang gantimpala, hindi bilang × 1: nababago ang `starReward`.
  static int scheduleStars() => HiveService.getScheduleDoneBox().values
      .fold(0, (sum, stars) => sum + stars);

  static int totalStars() => sensoryStars() + milestoneStars() + scheduleStars();
}
