import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/services/hive_service.dart';

/// Kinukwenta ang bituin mula mismo sa mga box para walang hiwalay na counter
/// na maaaring mahuli sa aktwal na progreso.
class StarService {
  static const int starsPerSensoryActivity = 1;
  static const int starsPerMilestone = 2;

  static Listenable? _listenable;

  /// Nagbabago kapag may natapos na laro o milestone.
  static Listenable get listenable => _listenable ??= Listenable.merge([
    HiveService.getCompletionBox().listenable(),
    HiveService.getMilestoneBox().listenable(),
  ]);

  static int sensoryStars() =>
      HiveService.getCompletionBox().length * starsPerSensoryActivity;

  static int milestoneStars() =>
      HiveService.getMilestoneBox().length * starsPerMilestone;

  static int totalStars() => sensoryStars() + milestoneStars();
}
