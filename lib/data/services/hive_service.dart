import 'package:hive_flutter/hive_flutter.dart';
import '../models/child_profile.dart';
import '../models/screening_result.dart';
import '../models/behavior_log.dart';
import '../models/sensory_profile_result.dart';

class HiveService {
  static const String _screeningBoxName = 'screening_results';
  static const String _profileBoxName = 'child_profile';
  static const String _profileKey = 'child';
  static const String _behaviorBoxName = 'behavior_logs';
  static const String _sensoryBoxName = 'sensory_profiles';
  static const String _completionBoxName = 'sensory_completion_box';
  static const String _moodBoxName = 'daily_mood';

  /// I-initialize ang Hive sa app startup
  static Future<void> init() async {
    await Hive.initFlutter();
    // Register Adapters
    Hive.registerAdapter(BehaviorLogAdapter());
    Hive.registerAdapter(SensoryProfileResultAdapter());

    await Hive.openBox(_screeningBoxName);
    await Hive.openBox(_profileBoxName);
    // Open Boxes
    await Hive.openBox<BehaviorLog>(_behaviorBoxName);
    await Hive.openBox<SensoryProfileResult>(_sensoryBoxName);
    await Hive.openBox<bool>(_completionBoxName);
    await Hive.openBox<String>(_moodBoxName);
  }

  static Box<String> getMoodBox() => Hive.box<String>(_moodBoxName);

  static String moodKey(DateTime date) => 'mood_${dateKey(date)}';

  static String? getMood(DateTime date) => getMoodBox().get(moodKey(date));

  static Future<void> saveMood(DateTime date, String mood) async {
    await getMoodBox().put(moodKey(date), mood);
  }

  /// Naka-index sa `dateKey`; nilalaktawan ang mga araw na walang naitala.
  static Map<String, String> getMoodsInRange(DateTime from, DateTime to) {
    final start = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day);
    final moods = <String, String>{};

    for (var i = 0; ; i++) {
      final day = DateTime(start.year, start.month, start.day + i);
      if (day.isAfter(end)) break;
      final mood = getMood(day);
      if (mood != null) moods[dateKey(day)] = mood;
    }
    return moods;
  }

  static Box<bool> getCompletionBox() => Hive.box<bool>(_completionBoxName);

  /// Halimbawa: '2026-08-15'
  static String dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  static String completionKey(DateTime date, String activityId) =>
      '${dateKey(date)}_$activityId';

  static bool isActivityCompleted(DateTime date, String activityId) =>
      getCompletionBox().get(completionKey(date, activityId)) ?? false;

  static Future<void> setActivityCompleted(
    DateTime date,
    String activityId,
    bool isCompleted,
  ) async {
    final box = getCompletionBox();
    final key = completionKey(date, activityId);
    // Huwag ipunin ang mga false — ang wala sa box ay hindi pa tapos.
    if (isCompleted) {
      await box.put(key, true);
    } else {
      await box.delete(key);
    }
  }

  static int countCompletedOn(DateTime date, List<String> activityIds) {
    return activityIds
        .where((id) => isActivityCompleted(date, id))
        .length;
  }

  static bool hasAnyCompletionOn(DateTime date) {
    final prefix = '${dateKey(date)}_';
    return getCompletionBox()
        .keys
        .any((key) => key.toString().startsWith(prefix));
  }

  static Box<SensoryProfileResult> getSensoryBox() =>
      Hive.box<SensoryProfileResult>(_sensoryBoxName);

  static Future<void> addSensoryResult(SensoryProfileResult result) async {
    await getSensoryBox().put(result.id, result);
  }

  static List<SensoryProfileResult> getAllSensoryResults() {
    return getSensoryBox().values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  static Box<BehaviorLog> getBehaviorBox() =>
      Hive.box<BehaviorLog>(_behaviorBoxName);

  static Future<void> addLog(BehaviorLog log) async {
    final box = getBehaviorBox();
    await box.put(log.id, log);
  }

  static List<BehaviorLog> getAllLogs() {
    final box = getBehaviorBox();
    return box.values.toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// I-save ang bagong screening result
  static Future<void> saveScreeningResult(ScreeningResult result) async {
    final box = Hive.box(_screeningBoxName);
    await box.put(result.id, result.toMap());
  }

  /// Kunin ang lahat ng nakaraang screening history (pinakabago muna)
  static List<ScreeningResult> getAllScreeningResults() {
    final box = Hive.box(_screeningBoxName);
    final List<ScreeningResult> results = [];
    for (var item in box.values) {
      results.add(ScreeningResult.fromMap(item as Map));
    }
    results.sort((a, b) => b.date.compareTo(a.date));
    return results;
  }

  static Future<void> saveChildProfile(ChildProfile profile) async {
    await Hive.box(_profileBoxName).put(_profileKey, profile.toMap());
  }

  static Box getProfileBox() => Hive.box(_profileBoxName);

  static Future<void> deleteChildProfile() async {
    await Hive.box(_profileBoxName).delete(_profileKey);
  }

  static ChildProfile? getChildProfile() {
    final raw = Hive.box(_profileBoxName).get(_profileKey);
    return raw == null ? null : ChildProfile.fromMap(raw as Map);
  }
}