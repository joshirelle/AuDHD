import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:kiko_app/core/services/star_service.dart';
import 'package:kiko_app/data/services/hive_service.dart';

void main() {
  late Directory tempDir;
  late Box<bool> completionBox;
  late Box<int> milestoneBox;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('audhd_star_test');
    Hive.init(tempDir.path);
    completionBox = await Hive.openBox<bool>('sensory_completion_box');
    milestoneBox = await Hive.openBox<int>('milestone_progress');
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  setUp(() async {
    await completionBox.clear();
    await milestoneBox.clear();
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
}
