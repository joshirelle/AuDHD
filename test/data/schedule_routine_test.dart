import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:kiko_app/core/models/schedule_task.dart';
import 'package:kiko_app/data/services/hive_service.dart';

/// Ang pagbilang ay humihiwa ng susi na `<petsa>_<taskId>`. May underscore ang
/// ilang taskId, kaya dito madaling magkamali nang tahimik.
void main() {
  late Directory tempDir;
  late Box<int> doneBox;

  const almusal = ScheduleTask(
    id: 'default_almusal',
    titleTagalog: 'Pag-almusal',
    iconKey: 'breakfast',
    timeOfDay: ScheduleTimeOfDay.morning,
  );

  const maligo = ScheduleTask(
    id: 'default_maligo',
    titleTagalog: 'Maligo',
    iconKey: 'bath',
    timeOfDay: ScheduleTimeOfDay.evening,
  );

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('audhd_routine_test');
    Hive.init(tempDir.path);
    Hive.registerAdapter(ScheduleTaskAdapter());
    Hive.registerAdapter(ScheduleTimeOfDayAdapter());
    doneBox = await Hive.openBox<int>('schedule_completion');
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  setUp(() async => doneBox.clear());

  test('hindi napuputol ang taskId na may underscore', () async {
    await HiveService.setScheduleTaskDone(DateTime(2026, 8, 17), almusal, true);
    await HiveService.setScheduleTaskDone(DateTime(2026, 8, 18), almusal, true);

    final counts = HiveService.scheduleDoneCountsInRange(
      DateTime(2026, 8, 1),
      DateTime(2026, 8, 31),
    );

    expect(counts['default_almusal'], 2);
  });

  test('hiwalay ang bilang ng bawat gawain', () async {
    await HiveService.setScheduleTaskDone(DateTime(2026, 8, 17), almusal, true);
    await HiveService.setScheduleTaskDone(DateTime(2026, 8, 18), almusal, true);
    await HiveService.setScheduleTaskDone(DateTime(2026, 8, 18), maligo, true);

    final counts = HiveService.scheduleDoneCountsInRange(
      DateTime(2026, 8, 1),
      DateTime(2026, 8, 31),
    );

    expect(counts['default_almusal'], 2);
    expect(counts['default_maligo'], 1);
  });

  test('hindi kasama ang labas ng saklaw', () async {
    await HiveService.setScheduleTaskDone(DateTime(2026, 7, 10), almusal, true);
    await HiveService.setScheduleTaskDone(DateTime(2026, 8, 17), almusal, true);

    final counts = HiveService.scheduleDoneCountsInRange(
      DateTime(2026, 8, 1),
      DateTime(2026, 8, 31),
    );

    expect(counts['default_almusal'], 1);
  });

  test('isang beses lang binibilang ang araw kahit maraming gawain', () async {
    await HiveService.setScheduleTaskDone(DateTime(2026, 8, 18), almusal, true);
    await HiveService.setScheduleTaskDone(DateTime(2026, 8, 18), maligo, true);
    await HiveService.setScheduleTaskDone(DateTime(2026, 8, 19), almusal, true);

    final activeDays = HiveService.scheduleActiveDaysInRange(
      DateTime(2026, 8, 1),
      DateTime(2026, 8, 31),
    );

    expect(activeDays, 2);
  });

  test('nababawasan ang bilang kapag inalis ang tsek', () async {
    await HiveService.setScheduleTaskDone(DateTime(2026, 8, 18), almusal, true);
    await HiveService.setScheduleTaskDone(DateTime(2026, 8, 18), almusal, false);

    final counts = HiveService.scheduleDoneCountsInRange(
      DateTime(2026, 8, 1),
      DateTime(2026, 8, 31),
    );

    expect(counts['default_almusal'], isNull);
    expect(
      HiveService.scheduleActiveDaysInRange(
        DateTime(2026, 8, 1),
        DateTime(2026, 8, 31),
      ),
      0,
    );
  });
}
