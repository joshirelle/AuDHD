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

  /// Petsa lang ng huling kopya ng datos — hiwalay sa profile para hindi
  /// mabura kasama nito.
  static const String _backupMetaBoxName = 'backup_meta';

  static const String _guideBookmarkBoxName = 'guide_bookmarks';
  static const String _guideTipBoxName = 'guide_tips';

  /// Sariling ayos at itinagong gawain ng magulang. Hiwalay sa `schedule_box`
  /// para manatili sa code ang mga default at maabot pa rin sila ng update.
  static const String _scheduleOrderBoxName = 'schedule_order';
  static const String _scheduleHiddenBoxName = 'schedule_hidden';

  static const String hasSeenOnboardingKey = 'has_seen_onboarding';
  static const String hasSeenHomeTourKey = 'has_seen_home_tour';
  static const String hasSeenScheduleTourKey = 'has_seen_schedule_tour_v4';

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
    await Hive.openBox<String>(_backupMetaBoxName);
    await Hive.openBox<bool>(_guideBookmarkBoxName);
    await Hive.openBox<bool>(_guideTipBoxName);
    await Hive.openBox<int>(_scheduleOrderBoxName);
    await Hive.openBox<bool>(_scheduleHiddenBoxName);
  }

  static Box<String> getBackupMetaBox() =>
      Hive.box<String>(_backupMetaBoxName);

  static Box<bool> getGuideBookmarkBox() =>
      Hive.box<bool>(_guideBookmarkBoxName);

  static Box<bool> getGuideTipBox() => Hive.box<bool>(_guideTipBoxName);

  static bool isGuideBookmarked(String cardId) =>
      getGuideBookmarkBox().get(cardId) ?? false;

  /// Binubura imbes na isulat na `false`: mas maliit ang box at ang backup.
  static Future<void> setGuideBookmarked(String cardId, bool value) async {
    final box = getGuideBookmarkBox();
    if (value) {
      await box.put(cardId, true);
    } else {
      await box.delete(cardId);
    }
  }

  /// Nakabatay sa pagkakasunod ang susi, kaya kapag inayos muli ang mga tip sa
  /// code, mababalik sa blangko ang tsek ng magulang.
  static String guideTipKey(String cardId, int index) => '${cardId}_$index';

  static bool isGuideTipDone(String cardId, int index) =>
      getGuideTipBox().get(guideTipKey(cardId, index)) ?? false;

  static Future<void> setGuideTipDone(
    String cardId,
    int index,
    bool value,
  ) async {
    final box = getGuideTipBox();
    final key = guideTipKey(cardId, index);
    if (value) {
      await box.put(key, true);
    } else {
      await box.delete(key);
    }
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

  static Box<int> getScheduleOrderBox() =>
      Hive.box<int>(_scheduleOrderBoxName);

  static Box<bool> getScheduleHiddenBox() =>
      Hive.box<bool>(_scheduleHiddenBoxName);

  /// Lahat ng gawain kasama ang nakatago — para sa screen ng pag-aayos.
  static List<ScheduleTask> getAllScheduleTasks() {
    final tasks = [...ScheduleTask.defaults, ...getScheduleBox().values];
    final natural = <String, int>{
      for (var i = 0; i < tasks.length; i++) tasks[i].id: i,
    };

    tasks.sort((a, b) {
      final byTimeOfDay = a.timeOfDay.index.compareTo(b.timeOfDay.index);
      if (byTimeOfDay != 0) return byTimeOfDay;
      return _scheduleRank(
        a,
        natural[a.id]!,
      ).compareTo(_scheduleRank(b, natural[b.id]!));
    });
    return tasks;
  }

  /// Ang inayos ng magulang ang laging nauuna. Ang gawaing idinagdag matapos
  /// niyang mag-ayos ay napupunta sa dulo ng sariling bahagi ng araw, hindi sa
  /// dulo ng buong listahan.
  static int _scheduleRank(ScheduleTask task, int naturalIndex) {
    final explicit = getScheduleOrderBox().get(task.id);
    if (explicit != null) return explicit;
    return 100000 + (task.minuteOfDay ?? (1440 + naturalIndex));
  }

  static List<ScheduleTask> getScheduleTasks() => getAllScheduleTasks()
      .where((task) => !isScheduleTaskHidden(task.id))
      .toList();

  static bool isScheduleTaskHidden(String taskId) =>
      getScheduleHiddenBox().get(taskId) ?? false;

  static Future<void> setScheduleTaskHidden(String taskId, bool hidden) async {
    final box = getScheduleHiddenBox();
    if (hidden) {
      await box.put(taskId, true);
    } else {
      await box.delete(taskId);
    }
  }

  static Future<void> saveScheduleOrder(List<ScheduleTask> ordered) async {
    final box = getScheduleOrderBox();
    await box.clear();
    await box.putAll({
      for (var i = 0; i < ordered.length; i++) ordered[i].id: i,
    });
  }

  static Future<void> addScheduleTask(ScheduleTask task) async {
    await getScheduleBox().put(task.id, task);
  }

  static Future<void> deleteScheduleTask(String taskId) async {
    await getScheduleBox().delete(taskId);
    await getScheduleOrderBox().delete(taskId);
    await getScheduleHiddenBox().delete(taskId);

    // Ang bituin ay kinukwenta mula mismo sa talang ito, kaya kasama itong
    // nabubura. Gamitin ang pagtatago kung nais panatilihin ang kasaysayan.
    final done = getScheduleDoneBox();
    await done.deleteAll(
      done.keys.where((key) => _scheduleKeyIsFor(key, taskId)).toList(),
    );
  }

  static bool _scheduleKeyIsFor(dynamic key, String taskId) {
    final raw = key.toString();
    final split = raw.indexOf('_');
    return split != -1 && raw.substring(split + 1) == taskId;
  }

  /// Bilang ng araw na natapos ang gawain at ang kabuuang bituin nito — para
  /// masabi sa magulang kung ano ang mawawala bago siya magbura.
  static ({int days, int stars}) scheduleHistoryFor(String taskId) {
    final box = getScheduleDoneBox();
    var days = 0;
    var stars = 0;

    for (final key in box.keys) {
      if (!_scheduleKeyIsFor(key, taskId)) continue;
      days++;
      stars += box.get(key) ?? 0;
    }
    return (days: days, stars: stars);
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

  static bool hasAnyScheduleDoneOn(DateTime date) {
    final prefix = '${dateKey(date)}_';
    return getScheduleDoneBox()
        .keys
        .any((key) => key.toString().startsWith(prefix));
  }

  /// Ilang araw sa saklaw natapos ang bawat gawain. Susi = `taskId`.
  ///
  /// Walang underscore ang petsa, kaya ang unang underscore ang hangganan —
  /// may underscore ang ilang `taskId` gaya ng `default_almusal`.
  static Map<String, int> scheduleDoneCountsInRange(
    DateTime from,
    DateTime to,
  ) {
    final counts = <String, int>{};
    for (final key in getScheduleDoneBox().keys) {
      final raw = key.toString();
      final split = raw.indexOf('_');
      if (split == -1) continue;

      final date = DateTime.tryParse(raw.substring(0, split));
      if (date == null || date.isBefore(from) || date.isAfter(to)) continue;

      final taskId = raw.substring(split + 1);
      counts[taskId] = (counts[taskId] ?? 0) + 1;
    }
    return counts;
  }

  /// Bilang ng araw sa saklaw na may kahit isang natapos na gawain.
  static int scheduleActiveDaysInRange(DateTime from, DateTime to) {
    final days = <String>{};
    for (final key in getScheduleDoneBox().keys) {
      final raw = key.toString();
      final split = raw.indexOf('_');
      if (split == -1) continue;

      final dayKey = raw.substring(0, split);
      final date = DateTime.tryParse(dayKey);
      if (date == null || date.isBefore(from) || date.isAfter(to)) continue;
      days.add(dayKey);
    }
    return days.length;
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

  static Future<void> deleteSensoryResult(String id) async {
    await getSensoryBox().delete(id);
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

  static Future<void> deleteLog(String id) async {
    await getBehaviorBox().delete(id);
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