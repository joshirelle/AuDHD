import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:kiko_app/core/models/schedule_task.dart';
import 'package:kiko_app/core/services/backup_service.dart';
import 'package:kiko_app/data/models/behavior_log.dart';
import 'package:kiko_app/data/models/child_profile.dart';
import 'package:kiko_app/data/models/sensory_profile_result.dart';
import 'package:kiko_app/data/services/hive_service.dart';

/// Ang tanging pagkakataon ng magulang na hindi mawala ang taon ng pagtatala
/// ay ang file na ito. Kung may nalalaglag na box dito, tahimik iyon.
void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('audhd_backup_test');
    Hive.init(tempDir.path);
    Hive.registerAdapter(BehaviorLogAdapter());
    Hive.registerAdapter(SensoryProfileResultAdapter());
    Hive.registerAdapter(ScheduleTaskAdapter());
    Hive.registerAdapter(ScheduleTimeOfDayAdapter());

    await Hive.openBox('child_profile');
    await Hive.openBox<BehaviorLog>('behavior_logs');
    await Hive.openBox<SensoryProfileResult>('sensory_profiles');
    await Hive.openBox<bool>('sensory_completion_box');
    await Hive.openBox<String>('daily_mood');
    await Hive.openBox<int>('milestone_progress');
    await Hive.openBox<bool>('app_settings');
    await Hive.openBox<ScheduleTask>('schedule_box');
    await Hive.openBox<int>('schedule_completion');
    await Hive.openBox<int>('custom_rewards');
    await Hive.openBox<String>('backup_meta');
    await Hive.openBox<bool>('guide_bookmarks');
    await Hive.openBox<bool>('guide_tips');
    await Hive.openBox<int>('schedule_order');
    await Hive.openBox<bool>('schedule_hidden');
    await Hive.openBox<String>('app_prefs');
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  final profile = ChildProfile(
    name: 'Alex Santos',
    birthDate: DateTime(2021, 3, 14),
    gender: Gender.male,
    nickname: 'Ax',
  );

  final log = BehaviorLog(
    id: 'log_1',
    timestamp: DateTime(2026, 8, 16, 14, 30),
    antecedent: 'Malakas na ingay ng blender',
    behavior: 'Tinakpan ang tainga, umiyak',
    consequence: 'Binigyan ng headphones',
    sensoryTriggers: const ['Auditory', 'Tactile'],
    intensity: 4,
    durationMinutes: 12,
    notes: 'Mas mahaba kaysa dati.',
  );

  final sensory = SensoryProfileResult(
    id: 'sen_1',
    timestamp: DateTime(2026, 8, 15, 9),
    answers: const {'a1': 3, 'a2': 1},
    totalSeekingScore: 14,
    totalAvoidingScore: 6,
    primaryProfile: 'Sensory Seeking',
    domainBreakdown: const {'Auditory': 'Avoiding', 'Vestibular': 'Seeking'},
  );

  const task = ScheduleTask(
    id: 'custom_1',
    titleTagalog: 'Maligo',
    iconKey: 'bath',
    timeOfDay: ScheduleTimeOfDay.evening,
    starReward: 2,
  );

  Future<void> seed() async {
    await HiveService.saveChildProfile(profile);
    await HiveService.getBehaviorBox().put(log.id, log);
    await HiveService.getSensoryBox().put(sensory.id, sensory);
    await HiveService.getScheduleBox().put(task.id, task);
    await HiveService.getCompletionBox().put('2026-08-16_act_01', true);
    await HiveService.getMoodBox().put('2026-08-16', 'masaya');
    await HiveService.getMilestoneBox().put('gm_1', 1);
    await HiveService.getSettingsBox().put('has_seen_onboarding', true);
    await HiveService.getScheduleDoneBox().put('2026-08-16_custom_1', 2);
    await HiveService.getRewardBox().put('Ice cream', 10);
    await HiveService.setGuideBookmarked('ingay', true);
    await HiveService.setGuideTipDone('ingay', 2, true);
    await HiveService.setScheduleTaskHidden('default_aaral', true);
    await HiveService.getScheduleOrderBox().put('default_almusal', 3);
    await HiveService.getPrefsBox().put('selected_language', 'eng');
  }

  Future<void> wipe() async {
    await HiveService.deleteChildProfile();
    await HiveService.getBehaviorBox().clear();
    await HiveService.getSensoryBox().clear();
    await HiveService.getScheduleBox().clear();
    await HiveService.getCompletionBox().clear();
    await HiveService.getMoodBox().clear();
    await HiveService.getMilestoneBox().clear();
    await HiveService.getSettingsBox().clear();
    await HiveService.getScheduleDoneBox().clear();
    await HiveService.getRewardBox().clear();
    await HiveService.getGuideBookmarkBox().clear();
    await HiveService.getGuideTipBox().clear();
    await HiveService.getScheduleOrderBox().clear();
    await HiveService.getScheduleHiddenBox().clear();
    await HiveService.getPrefsBox().clear();
  }

  setUp(() async {
    await wipe();
    await HiveService.getBackupMetaBox().clear();
  });

  test('a full round trip through JSON keeps every box intact', () async {
    await seed();

    // Dumadaan sa tunay na encode/decode: doon lumalabas ang mga tipong
    // hindi kayang isulat ng JSON, tulad ng DateTime.
    final payload = await BackupService.buildPayload();
    final reloaded =
        jsonDecode(jsonEncode(payload)) as Map<String, dynamic>;

    await wipe();
    await BackupService.restorePayload(reloaded);

    final restoredProfile = HiveService.getChildProfile()!;
    expect(restoredProfile.name, 'Alex Santos');
    expect(restoredProfile.birthDate, DateTime(2021, 3, 14));
    expect(restoredProfile.gender, Gender.male);
    expect(restoredProfile.nickname, 'Ax');

    final restoredLog = HiveService.getBehaviorBox().get('log_1')!;
    expect(restoredLog.timestamp, DateTime(2026, 8, 16, 14, 30));
    expect(restoredLog.antecedent, 'Malakas na ingay ng blender');
    expect(restoredLog.sensoryTriggers, ['Auditory', 'Tactile']);
    expect(restoredLog.intensity, 4);
    expect(restoredLog.durationMinutes, 12);
    expect(restoredLog.notes, 'Mas mahaba kaysa dati.');

    final restoredSensory = HiveService.getSensoryBox().get('sen_1')!;
    expect(restoredSensory.answers, {'a1': 3, 'a2': 1});
    expect(restoredSensory.totalSeekingScore, 14);
    expect(restoredSensory.domainBreakdown['Auditory'], 'Avoiding');

    final restoredTask = HiveService.getScheduleBox().get('custom_1')!;
    expect(restoredTask.titleTagalog, 'Maligo');
    expect(restoredTask.iconKey, 'bath');
    expect(restoredTask.timeOfDay, ScheduleTimeOfDay.evening);
    expect(restoredTask.starReward, 2);

    expect(HiveService.getCompletionBox().get('2026-08-16_act_01'), true);
    expect(HiveService.getMoodBox().get('2026-08-16'), 'masaya');
    expect(HiveService.getMilestoneBox().get('gm_1'), 1);
    expect(HiveService.getSettingsBox().get('has_seen_onboarding'), true);
    expect(HiveService.getScheduleDoneBox().get('2026-08-16_custom_1'), 2);
    expect(HiveService.getRewardBox().get('Ice cream'), 10);
    expect(HiveService.isGuideBookmarked('ingay'), isTrue);
    expect(HiveService.isGuideTipDone('ingay', 2), isTrue);
    expect(HiveService.isScheduleTaskHidden('default_aaral'), isTrue);
    expect(HiveService.getScheduleOrderBox().get('default_almusal'), 3);
    expect(HiveService.getPrefsBox().get('selected_language'), 'eng');
  });

  test('the PIN never leaves the device inside a backup', () async {
    await seed();
    final json = jsonEncode(await BackupService.buildPayload());

    expect(json.contains('pin_hash'), isFalse);
    expect(json.contains('pin_salt'), isFalse);
    expect(json.contains('security_box'), isFalse);
  });

  test('restoring replaces old entries instead of merging them', () async {
    await seed();
    final payload = await BackupService.buildPayload();

    await wipe();
    final stale = BehaviorLog(
      id: 'log_stale',
      timestamp: DateTime(2026, 1, 1),
      antecedent: 'luma',
      behavior: 'luma',
      consequence: 'luma',
      sensoryTriggers: const [],
      intensity: 1,
      durationMinutes: 1,
    );
    await HiveService.getBehaviorBox().put(stale.id, stale);

    await BackupService.restorePayload(payload);

    expect(HiveService.getBehaviorBox().get('log_stale'), isNull);
    expect(HiveService.getBehaviorBox().length, 1);
  });

  test('a payload with missing sections empties the app instead of crashing',
      () async {
    await seed();

    await BackupService.restorePayload({'format': 1, 'app': 'AuDHD'});

    expect(HiveService.getChildProfile(), isNull);
    expect(HiveService.getBehaviorBox().isEmpty, isTrue);
    expect(HiveService.getMoodBox().isEmpty, isTrue);
  });

  test('restoring on a wiped phone marks that a backup exists', () async {
    await seed();
    final payload = await BackupService.buildPayload();

    // Kagaya ng bagong telepono o ng "Clear data": walang natirang meta.
    await wipe();
    await HiveService.getBackupMetaBox().clear();
    expect(BackupService.hasBackup, isFalse);

    await BackupService.restorePayload(payload);

    expect(BackupService.hasBackup, isTrue);
    expect(
      BackupService.lastBackupAt(),
      DateTime.parse(payload['createdAt'] as String),
    );
  });
}
