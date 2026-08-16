import 'package:hive_flutter/hive_flutter.dart';
import '../../core/models/schedule_task.dart';
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
  static const String _milestoneBoxName = 'milestone_progress';
  static const String _settingsBoxName = 'app_settings';
  static const String _scheduleBoxName = 'schedule_box';
  static const String _scheduleDoneBoxName = 'schedule_completion';
  static const String _rewardBoxName = 'custom_rewards';

  static const String hasSeenOnboardingKey = 'has_seen_onboarding';
  static const String hasSeenHomeTourKey = 'has_seen_home_tour';

  /// I-initialize ang Hive sa app startup
  static Future<void> init() async {
    await Hive.initFlutter();
    // Register Adapters
    Hive.registerAdapter(BehaviorLogAdapter());
    Hive.registerAdapter(SensoryProfileResultAdapter());
    Hive.registerAdapter(ScheduleTaskAdapter());
    Hive.registerAdapter(ScheduleTimeOfDayAdapter());

    await Hive.openBox(_screeningBoxName);
    await Hive.openBox(_profileBoxName);
    // Open Boxes
    await Hive.openBox<BehaviorLog>(_behaviorBoxName);
    await Hive.openBox<SensoryProfileResult>(_sensoryBoxName);
    await Hive.openBox<bool>(_completionBoxName);
    await Hive.openBox<String>(_moodBoxName);
    await Hive.openBox<int>(_milestoneBoxName);
    await Hive.openBox<bool>(_settingsBoxName);
    await Hive.openBox<ScheduleTask>(_scheduleBoxName);
    await Hive.openBox<int>(_scheduleDoneBoxName);
    await Hive.openBox<int>(_rewardBoxName);
  }

  /// Susi = pangalan ng pabuya, halaga = bilang ng bituing kailangan.
  /// Mga dagdag ng magulang lang ang laman; nasa code ang mga default.
  static Box<int> getRewardBox() => Hive.box<int>(_rewardBoxName);

  static Future<void> addCustomReward(String reward, int stars) async {
    await getRewardBox().put(reward.trim(), stars);
  }

  static Future<void> deleteCustomReward(String reward) async {
    await getRewardBox().delete(reward);
  }

  /// Mga custom na routine lang ang laman; nasa code ang mga default.
  static Box<ScheduleTask> getScheduleBox() =>
      Hive.box<ScheduleTask>(_scheduleBoxName);

  static List<ScheduleTask> getScheduleTasks() => [
    ...ScheduleTask.defaults,
    ...getScheduleBox().values,
  ];

  static Future<void> addScheduleTask(ScheduleTask task) async {
    await getScheduleBox().put(task.id, task);
  }

  static Future<void> deleteScheduleTask(String taskId) async {
    await getScheduleBox().delete(taskId);
  }

  static bool isCustomScheduleTask(String taskId) =>
      getScheduleBox().containsKey(taskId);

  /// Hiwalay sa `_completionBoxName` dahil binibilang ng `StarService` ang haba
  /// ng bawat box — magkakamali ang sensory stars kung pagsasabayin dito.
  /// Ang halaga ay bilang ng bituing naipagkaloob, hindi `true`.
  static Box<int> getScheduleDoneBox() => Hive.box<int>(_scheduleDoneBoxName);

  static String scheduleKey(DateTime date, String taskId) =>
      '${dateKey(date)}_$taskId';

  static bool isScheduleTaskDone(DateTime date, String taskId) =>
      getScheduleDoneBox().containsKey(scheduleKey(date, taskId));

  static Future<void> setScheduleTaskDone(
    DateTime date,
    ScheduleTask task,
    bool isDone,
  ) async {
    final box = getScheduleDoneBox();
    final key = scheduleKey(date, task.id);
    if (isDone) {
      await box.put(key, task.starReward);
    } else {
      await box.delete(key);
    }
  }

  static int countScheduleDoneOn(DateTime date, List<String> taskIds) =>
      taskIds.where((id) => isScheduleTaskDone(date, id)).length;

  static Box<bool> getSettingsBox() => Hive.box<bool>(_settingsBoxName);

  static bool hasSeen(String key) => getSettingsBox().get(key) ?? false;

  static Future<void> markSeen(String key) async {
    await getSettingsBox().put(key, true);
  }

  /// Iniimbak ang petsa ng pag-abot; ang pagkakaroon ng key ang ibig sabihin ng naabot.
  static Box<int> getMilestoneBox() => Hive.box<int>(_milestoneBoxName);

  static String milestoneKey(String milestoneId) => '${milestoneId}_achieved';

  static bool isMilestoneAchieved(String milestoneId) =>
      getMilestoneBox().containsKey(milestoneKey(milestoneId));

  static DateTime? milestoneAchievedDate(String milestoneId) {
    final millis = getMilestoneBox().get(milestoneKey(milestoneId));
    return millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
  }

  static Future<void> setMilestoneAchieved(
    String milestoneId,
    bool isAchieved,
  ) async {
    final box = getMilestoneBox();
    final key = milestoneKey(milestoneId);
    if (isAchieved) {
      await box.put(key, DateTime.now().millisecondsSinceEpoch);
    } else {
      await box.delete(key);
    }
  }

  static Box<String> getMoodBox() => Hive.box<String>(_moodBoxName);

  static String moodKey(DateTime date) => 'mood_${dateKey(date)}';

  static String? getMood(DateTime date) => getMoodBox().get(moodKey(date));

  static Future<void> saveMood(DateTime date, String mood) async {
    await getMoodBox().put(moodKey(date), mood);
  }

  static String noteKey(DateTime date) => 'note_${dateKey(date)}';

  static String? getMoodNote(DateTime date) => getMoodBox().get(noteKey(date));

  static Future<void> saveMoodNote(DateTime date, String note) async {
    final box = getMoodBox();
    final trimmed = note.trim();
    if (trimmed.isEmpty) {
      await box.delete(noteKey(date));
    } else {
      await box.put(noteKey(date), trimmed);
    }
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