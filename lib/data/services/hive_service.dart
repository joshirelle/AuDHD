import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import 'scoped_box.dart';
import '../../core/models/schedule_task.dart';
import '../models/child_profile.dart';
import '../models/screening_result.dart';
import '../models/behavior_log.dart';
import '../models/sensory_profile_result.dart';

class HiveService {
  static const String _screeningBoxName = 'screening_results';

  /// Ang nag-iisang bata bago ang multi-child. Iniiwan nang buo kahit
  /// nalipat na sa `child_profiles`: kopya ang migration, hindi paglilipat,
  /// para may mababalikan kung may masira.
  static const String _profileBoxName = 'child_profile';
  static const String _profileKey = 'child';

  /// Lahat ng bata, naka-susi sa `ChildProfile.id`.
  static const String _profilesBoxName = 'child_profiles';

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

  /// Tsek ng magulang sa mga papeles para sa DSWD Guarantee Letter.
  /// Naka-scope sa bata: nakapangalan sa isang bata ang medical abstract at
  /// ang quotation, kaya hiwalay ang aplikasyon kada anak.
  static const String _dswdChecklistBoxName = 'dswd_checklist_box';

  /// Sariling ayos at itinagong gawain ng magulang. Hiwalay sa `schedule_box`
  /// para manatili sa code ang mga default at maabot pa rin sila ng update.
  static const String _scheduleOrderBoxName = 'schedule_order';
  static const String _scheduleHiddenBoxName = 'schedule_hidden';

  /// Pangkalahatang kagustuhan ng magulang — kasalukuyang piniling wika.
  static const String _prefsBoxName = 'app_prefs';

  /// Nasa `app_prefs` at hindi sa `app_settings`: `Box<bool>` ang huli, at
  /// id ang itatago rito.
  static const String _activeChildKey = 'active_child_id';

  /// Hiwalay sa laman ng `child_profiles`: kapag binura ang lahat ng bata,
  /// hindi dapat mabuhay muli ang luma sa susunod na pagbukas.
  static const String _multiProfileMigrationKey = 'migrated_to_multi_profile';

  static const String hasSeenOnboardingKey = 'has_seen_onboarding';
  static const String hasSeenHomeTourKey = 'has_seen_home_tour_v5';
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
    await Hive.openBox(_profilesBoxName);
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
    await Hive.openBox<bool>(_dswdChecklistBoxName);
    await Hive.openBox<int>(_scheduleOrderBoxName);
    await Hive.openBox<bool>(_scheduleHiddenBoxName);
    await Hive.openBox<String>(_prefsBoxName);

    await assignIdToLegacyProfile();
    await migrateToMultiProfile();
  }

  static Box<String> getPrefsBox() => Hive.box<String>(_prefsBoxName);

  static Box<String> getBackupMetaBox() => Hive.box<String>(_backupMetaBoxName);

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
  static Box<int> getRewardRawBox() => Hive.box<int>(_rewardBoxName);

  static ScopedBox<int> getRewardBox() => ScopedBox(getRewardRawBox(), _scope);

  static Future<void> addCustomReward(String reward, int stars) async {
    await getRewardBox().put(reward.trim(), stars);
  }

  static Future<void> deleteCustomReward(String reward) async {
    await getRewardBox().delete(reward);
  }

  /// Susi = `DswdRequirement.id`. Ang nakatsek lang ang naisusulat.
  static Box<bool> getDswdChecklistRawBox() =>
      Hive.box<bool>(_dswdChecklistBoxName);

  static ScopedBox<bool> getDswdChecklistBox() =>
      ScopedBox(getDswdChecklistRawBox(), _scope);

  static bool isDswdRequirementReady(String id) =>
      getDswdChecklistBox().get(id) ?? false;

  /// Binubura imbes na isulat na `false`: mas maliit ang box at ang backup.
  static Future<void> setDswdRequirementReady(String id, bool value) async {
    final box = getDswdChecklistBox();
    if (value) {
      await box.put(id, true);
    } else {
      await box.delete(id);
    }
  }

  /// Mga custom na routine lang ang laman; nasa code ang mga default.
  static Box<ScheduleTask> getScheduleRawBox() =>
      Hive.box<ScheduleTask>(_scheduleBoxName);

  static ScopedBox<ScheduleTask> getScheduleBox() =>
      ScopedBox(getScheduleRawBox(), _scope);

  static Box<int> getScheduleOrderRawBox() =>
      Hive.box<int>(_scheduleOrderBoxName);

  static ScopedBox<int> getScheduleOrderBox() =>
      ScopedBox(getScheduleOrderRawBox(), _scope);

  static Box<bool> getScheduleHiddenRawBox() =>
      Hive.box<bool>(_scheduleHiddenBoxName);

  static ScopedBox<bool> getScheduleHiddenBox() =>
      ScopedBox(getScheduleHiddenRawBox(), _scope);

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
  static Box<int> getScheduleDoneRawBox() =>
      Hive.box<int>(_scheduleDoneBoxName);

  static ScopedBox<int> getScheduleDoneBox() =>
      ScopedBox(getScheduleDoneRawBox(), _scope);

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
  static Box<int> getMilestoneRawBox() => Hive.box<int>(_milestoneBoxName);

  static ScopedBox<int> getMilestoneBox() =>
      ScopedBox(getMilestoneRawBox(), _scope);

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

  static Box<String> getMoodRawBox() => Hive.box<String>(_moodBoxName);

  static ScopedBox<String> getMoodBox() => ScopedBox(getMoodRawBox(), _scope);

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

  static Box<bool> getCompletionRawBox() => Hive.box<bool>(_completionBoxName);

  static ScopedBox<bool> getCompletionBox() =>
      ScopedBox(getCompletionRawBox(), _scope);

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
    return activityIds.where((id) => isActivityCompleted(date, id)).length;
  }

  static bool hasAnyCompletionOn(DateTime date) {
    final prefix = '${dateKey(date)}_';
    return getCompletionBox().keys.any(
      (key) => key.toString().startsWith(prefix),
    );
  }

  static bool hasAnyScheduleDoneOn(DateTime date) {
    final prefix = '${dateKey(date)}_';
    return getScheduleDoneBox().keys.any(
      (key) => key.toString().startsWith(prefix),
    );
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

  static Box<SensoryProfileResult> getSensoryRawBox() =>
      Hive.box<SensoryProfileResult>(_sensoryBoxName);

  static ScopedBox<SensoryProfileResult> getSensoryBox() =>
      ScopedBox(getSensoryRawBox(), _scope);

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

  static Box<BehaviorLog> getBehaviorRawBox() =>
      Hive.box<BehaviorLog>(_behaviorBoxName);

  static ScopedBox<BehaviorLog> getBehaviorBox() =>
      ScopedBox(getBehaviorRawBox(), _scope);

  static Future<void> addLog(BehaviorLog log) async {
    final box = getBehaviorBox();
    await box.put(log.id, log);
  }

  static List<BehaviorLog> getAllLogs() {
    final box = getBehaviorBox();
    return box.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
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

  static Box getProfilesBox() => Hive.box(_profilesBoxName);

  /// Lahat ng bata, sunod sa pangalan para hindi magpalit-palit ng pwesto ang
  /// switcher tuwing may idadagdag.
  static List<ChildProfile> getChildProfiles() {
    final children = getProfilesBox().values
        .whereType<Map>()
        .map(ChildProfile.fromMap)
        .toList();
    children.sort(
      (a, b) =>
          a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()),
    );
    return children;
  }

  static String? getActiveChildId() => getPrefsBox().get(_activeChildKey);

  static Future<void> setActiveChild(String id) async {
    await getPrefsBox().put(_activeChildKey, id);
  }

  static Future<void> clearActiveChild() async {
    await getPrefsBox().delete(_activeChildKey);
  }

  /// Prefix ng bawat naka-scope na box.
  ///
  /// Kapag walang bata, may sariling sulok ang datos na hindi nakikita
  /// kahit saan. Mas mabuti iyon kaysa sa `null` na kailangang bantayan ng
  /// bawat isa sa apatnapu't tatlong tumatawag.
  static String get _scope => getActiveChildId() ?? '__none';

  /// Kapag nabura ang aktibo o wala pang naitatakda, ang una ang hahalili.
  /// Hindi ito nagsusulat: walang getter na dapat magbago ng naka-imbak.
  static ChildProfile? getActiveChild() {
    final box = getProfilesBox();
    if (box.isEmpty) return null;

    final raw = box.get(getActiveChildId());
    if (raw is Map) return ChildProfile.fromMap(raw);

    return getChildProfiles().firstOrNull;
  }

  static Future<void> saveChild(ChildProfile profile) async {
    await getProfilesBox().put(profile.id, profile.toMap());
    if (getActiveChildId() == null) await setActiveChild(profile.id);
  }

  /// Ang datos ng bata ay tatanggalin ng `deleteChildData`, hindi rito.
  static Future<void> removeChild(String id) async {
    await getProfilesBox().delete(id);
    if (getActiveChildId() != id) return;

    final next = getChildProfiles().firstOrNull;
    if (next == null) {
      await clearActiveChild();
    } else {
      await setActiveChild(next.id);
    }
  }

  /// Bawat box na hinahati ayon sa bata.
  static List<Box> get _scopedRawBoxes => [
    getMoodRawBox(),
    getMilestoneRawBox(),
    getBehaviorRawBox(),
    getSensoryRawBox(),
    getCompletionRawBox(),
    getScheduleRawBox(),
    getScheduleDoneRawBox(),
    getScheduleOrderRawBox(),
    getScheduleHiddenRawBox(),
    getRewardRawBox(),
    getDswdChecklistRawBox(),
  ];

  /// Bilang ng naitala para sa isang bata.
  ///
  /// Para sa babala bago mabura: ang malabong "lahat ng datos" ay pinipindot
  /// nang hindi binabasa, ang "18 milestone" ay hindi.
  static Map<String, int> childDataCounts(String childId) {
    final prefix = '$childId${ScopedBox.separator}';
    int countIn(Box box, [String startsWith = '']) => box.keys
        .whereType<String>()
        .where((key) => key.startsWith('$prefix$startsWith'))
        .length;

    return {
      'milestones': countIn(getMilestoneRawBox()),
      'behavior': countIn(getBehaviorRawBox()),
      'schedule': countIn(getScheduleRawBox()),
      'mood': countIn(getMoodRawBox(), 'mood_'),
    };
  }

  /// Walang bakas: lahat ng susi ng bata sa bawat naka-scope na box.
  ///
  /// Ang litrato ay hindi rito — nasa disk iyon, hindi sa Hive, at ang
  /// tumatawag ang may hawak ng `ChildPhotoService`.
  static Future<void> deleteChildData(String childId) async {
    final prefix = '$childId${ScopedBox.separator}';
    for (final box in _scopedRawBoxes) {
      final own = box.keys
          .whereType<String>()
          .where((key) => key.startsWith(prefix))
          .toList();
      await box.deleteAll(own);
    }
  }

  /// Kinokopya ang datos na walang prefix papunta sa unang bata.
  ///
  /// Kopya at hindi paglilipat. Kung mahinto ito sa gitna, buo pa rin ang
  /// datos ng v6 at ligtas na maulit — ang mga susing walang prefix ay hindi
  /// nakikita ng `ScopedBox`, kaya walang doble sa mata ng magulang.
  static Future<void> _scopeLegacyDataTo(String childId) async {
    for (final box in _scopedRawBoxes) {
      final legacy = box.keys
          .whereType<String>()
          .where((key) => !key.contains(ScopedBox.separator))
          .toList();
      for (final key in legacy) {
        await box.put('$childId${ScopedBox.separator}$key', box.get(key));
      }
    }
  }

  static Future<void> saveChildProfile(ChildProfile profile) =>
      saveChild(profile);

  static Box getProfileBox() => Hive.box(_profileBoxName);

  static Future<void> deleteChildProfile() async {
    final id = getActiveChild()?.id;
    if (id != null) await removeChild(id);
  }

  static ChildProfile? getChildProfile() => getActiveChild();

  /// Binibigyan ng id ang profile na na-save bago ang multi-child.
  ///
  /// Isinusulat agad pabalik: kung sa pagbasa lang ito gagawin, iba ang id sa
  /// bawat pagbukas ng app at hindi na mahahanap ang datos ng bata.
  static Future<void> assignIdToLegacyProfile() async {
    final box = Hive.box(_profileBoxName);
    final raw = box.get(_profileKey);
    if (raw is! Map || raw['id'] is String) return;

    final profile = ChildProfile.fromMap(raw, idIfMissing: const Uuid().v4());
    await box.put(_profileKey, profile.toMap());
  }

  /// Inililipat ang nag-iisang bata papasok sa `child_profiles`.
  ///
  /// Ang bantay ay ang flag at hindi ang laman ng box: kung laman ang susukatin,
  /// mabubuhay muli ang binurang bata sa susunod na pagbukas ng app.
  static Future<void> migrateToMultiProfile() async {
    if (hasSeen(_multiProfileMigrationKey)) return;

    final legacy = Hive.box(_profileBoxName).get(_profileKey);
    if (legacy is Map) {
      final child = ChildProfile.fromMap(legacy);
      await getProfilesBox().put(child.id, child.toMap());
      await setActiveChild(child.id);
      await _scopeLegacyDataTo(child.id);
    }

    await markSeen(_multiProfileMigrationKey);
  }
}
