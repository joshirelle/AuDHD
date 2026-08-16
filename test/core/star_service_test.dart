import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:kiko_app/core/models/schedule_task.dart';
import 'package:kiko_app/core/services/star_service.dart';
import 'package:kiko_app/data/services/hive_service.dart';

void main() {
  late Directory tempDir;
  late Box<bool> completionBox;
  late Box<int> milestoneBox;
  late Box<int> scheduleDoneBox;

  const task = ScheduleTask(
    id: 'default_almusal',
    titleTagalog: 'Pag-almusal',
    iconKey: 'breakfast',
    timeOfDay: ScheduleTimeOfDay.morning,
  );

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('audhd_star_test');
    Hive.init(tempDir.path);
    completionBox = await Hive.openBox<bool>('sensory_completion_box');
    milestoneBox = await Hive.openBox<int>('milestone_progress');
    scheduleDoneBox = await Hive.openBox<int>('schedule_completion');
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  setUp(() async {
    await completionBox.clear();
    await milestoneBox.clear();
    await scheduleDoneBox.clear();
  });

  test('a fresh install has no stars', () {
    expect(StarService.totalStars(), 0);
  });

  test('each completed sensory activity is worth one star', () async {
    await HiveService.setActivityCompleted(DateTime(2026, 8, 16), 'act_01', true);
    await HiveService.setActivityCompleted(DateTime(2026, 8, 16), 'act_02', true);

    expect(StarService.sensoryStars(), 2);
    expect(StarService.totalStars(), 2);
  });

  test('each achieved milestone is worth two stars', () async {
    await HiveService.setMilestoneAchieved('gm_1', true);
    await HiveService.setMilestoneAchieved('gm_2', true);

    expect(StarService.milestoneStars(), 4);
    expect(StarService.totalStars(), 4);
  });

  test('the same activity on two days counts twice', () async {
    await HiveService.setActivityCompleted(DateTime(2026, 8, 15), 'act_01', true);
    await HiveService.setActivityCompleted(DateTime(2026, 8, 16), 'act_01', true);

    expect(StarService.totalStars(), 2);
  });

  test('both sources add up', () async {
    await HiveService.setActivityCompleted(DateTime(2026, 8, 16), 'act_01', true);
    await HiveService.setMilestoneAchieved('gm_1', true);

    expect(StarService.totalStars(), 3);
  });

  test('unchecking takes the stars back', () async {
    await HiveService.setMilestoneAchieved('gm_1', true);
    expect(StarService.totalStars(), 2);

    await HiveService.setMilestoneAchieved('gm_1', false);
    expect(StarService.totalStars(), 0);
  });

  test('each finished routine task is worth its star reward', () async {
    await HiveService.setScheduleTaskDone(DateTime(2026, 8, 16), task, true);

    expect(StarService.scheduleStars(), 1);
    expect(StarService.totalStars(), 1);
  });

  test('a routine task keeps its own reward, not a flat one', () async {
    const chore = ScheduleTask(
      id: 'custom_chore',
      titleTagalog: 'Maglinis',
      iconKey: 'clean',
      timeOfDay: ScheduleTimeOfDay.evening,
      starReward: 3,
    );

    await HiveService.setScheduleTaskDone(DateTime(2026, 8, 16), chore, true);

    expect(StarService.scheduleStars(), 3);
  });

  test('the same routine task on two days counts twice', () async {
    await HiveService.setScheduleTaskDone(DateTime(2026, 8, 15), task, true);
    await HiveService.setScheduleTaskDone(DateTime(2026, 8, 16), task, true);

    expect(StarService.scheduleStars(), 2);
  });

  test('yesterday stays done when the day rolls over', () async {
    await HiveService.setScheduleTaskDone(DateTime(2026, 8, 15), task, true);

    expect(HiveService.isScheduleTaskDone(DateTime(2026, 8, 15), task.id), true);
    expect(HiveService.isScheduleTaskDone(DateTime(2026, 8, 16), task.id), false);
  });

  test('unchecking a routine task takes the star back', () async {
    await HiveService.setScheduleTaskDone(DateTime(2026, 8, 16), task, true);
    expect(StarService.scheduleStars(), 1);

    await HiveService.setScheduleTaskDone(DateTime(2026, 8, 16), task, false);
    expect(StarService.scheduleStars(), 0);
  });

  test('routine stars add to the other sources', () async {
    await HiveService.setActivityCompleted(DateTime(2026, 8, 16), 'act_01', true);
    await HiveService.setMilestoneAchieved('gm_1', true);
    await HiveService.setScheduleTaskDone(DateTime(2026, 8, 16), task, true);

    expect(StarService.totalStars(), 4);
  });
}
