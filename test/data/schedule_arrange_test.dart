import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:kiko_app/core/models/schedule_task.dart';
import 'package:kiko_app/data/services/hive_service.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('audhd_arrange_test');
    Hive.init(tempDir.path);
    Hive.registerAdapter(ScheduleTaskAdapter());
    Hive.registerAdapter(ScheduleTimeOfDayAdapter());
    await Hive.openBox<ScheduleTask>('schedule_box');
    await Hive.openBox<int>('schedule_order');
    await Hive.openBox<bool>('schedule_hidden');
    await Hive.openBox<int>('schedule_completion');
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  setUp(() async {
    await HiveService.getScheduleBox().clear();
    await HiveService.getScheduleOrderBox().clear();
    await HiveService.getScheduleHiddenBox().clear();
  });

  /// Ito ang mismong reklamo: ang dinagdag na panumaga ay lumilitaw dati
  /// pagkatapos ng panggabi, dahil idinudugtong lang sa dulo.
  test('ang bagong panumaga ay sumasama sa umaga, hindi sa dulo', () async {
    await HiveService.addScheduleTask(
      const ScheduleTask(
        id: 'custom_gatas',
        titleTagalog: 'Gatas sa Umaga',
        iconKey: 'milk',
        timeOfDay: ScheduleTimeOfDay.morning,
      ),
    );

    final tasks = HiveService.getScheduleTasks();
    final position = tasks.indexWhere((t) => t.id == 'custom_gatas');
    final firstEvening = tasks.indexWhere(
      (t) => t.timeOfDay == ScheduleTimeOfDay.evening,
    );

    expect(position, lessThan(firstEvening));
    expect(tasks[position].timeOfDay, ScheduleTimeOfDay.morning);
  });

  test('nauuna ang may mas maagang tiyak na oras', () async {
    await HiveService.addScheduleTask(
      const ScheduleTask(
        id: 'custom_huli',
        titleTagalog: 'Huli',
        iconKey: 'milk',
        timeOfDay: ScheduleTimeOfDay.morning,
        minuteOfDay: 480,
      ),
    );
    await HiveService.addScheduleTask(
      const ScheduleTask(
        id: 'custom_maaga',
        titleTagalog: 'Maaga',
        iconKey: 'milk',
        timeOfDay: ScheduleTimeOfDay.morning,
        minuteOfDay: 360,
      ),
    );

    final morning = HiveService.getScheduleTasks()
        .where((t) => t.timeOfDay == ScheduleTimeOfDay.morning)
        .map((t) => t.id)
        .toList();

    expect(
      morning.indexOf('custom_maaga'),
      lessThan(morning.indexOf('custom_huli')),
    );
  });

  test('nananatili ang inayos na pagkakasunod-sunod', () async {
    final original = HiveService.getScheduleTasks();
    final flipped = [original[1], original[0], ...original.skip(2)];

    await HiveService.saveScheduleOrder(flipped);

    final after = HiveService.getScheduleTasks();
    expect(after.first.id, original[1].id);
    expect(after[1].id, original[0].id);
  });

  test('nawawala sa listahan ang itinago pero hindi nabubura', () async {
    final target = HiveService.getScheduleTasks().first;

    await HiveService.setScheduleTaskHidden(target.id, true);

    expect(
      HiveService.getScheduleTasks().any((t) => t.id == target.id),
      isFalse,
    );
    expect(
      HiveService.getAllScheduleTasks().any((t) => t.id == target.id),
      isTrue,
    );
  });

  test('naibabalik ang itinagong default', () async {
    final target = HiveService.getScheduleTasks().first;

    await HiveService.setScheduleTaskHidden(target.id, true);
    await HiveService.setScheduleTaskHidden(target.id, false);

    expect(
      HiveService.getScheduleTasks().any((t) => t.id == target.id),
      isTrue,
    );
  });

  test('kahit nakatago ang lahat ay hindi nag-e-error', () async {
    for (final task in HiveService.getAllScheduleTasks()) {
      await HiveService.setScheduleTaskHidden(task.id, true);
    }

    expect(HiveService.getScheduleTasks(), isEmpty);
  });

  test('nabubura ang ayos at pagtatago kasama ng custom na gawain', () async {
    const task = ScheduleTask(
      id: 'custom_burahin',
      titleTagalog: 'Burahin',
      iconKey: 'milk',
      timeOfDay: ScheduleTimeOfDay.morning,
    );
    await HiveService.addScheduleTask(task);
    await HiveService.setScheduleTaskHidden(task.id, true);
    await HiveService.saveScheduleOrder(HiveService.getAllScheduleTasks());

    await HiveService.deleteScheduleTask(task.id);

    expect(HiveService.getScheduleOrderBox().containsKey(task.id), isFalse);
    expect(HiveService.getScheduleHiddenBox().containsKey(task.id), isFalse);
  });

  group('pagbura at bituin', () {
    const target = ScheduleTask(
      id: 'custom_gatas',
      titleTagalog: 'Gatas',
      iconKey: 'milk',
      timeOfDay: ScheduleTimeOfDay.morning,
      starReward: 2,
    );

    const other = ScheduleTask(
      id: 'custom_iba',
      titleTagalog: 'Iba',
      iconKey: 'milk',
      timeOfDay: ScheduleTimeOfDay.morning,
      starReward: 3,
    );

    setUp(() async {
      await HiveService.getScheduleDoneBox().clear();
      await HiveService.addScheduleTask(target);
      await HiveService.addScheduleTask(other);
      await HiveService.setScheduleTaskDone(DateTime(2026, 8, 17), target, true);
      await HiveService.setScheduleTaskDone(DateTime(2026, 8, 18), target, true);
      await HiveService.setScheduleTaskDone(DateTime(2026, 8, 18), other, true);
    });

    test('binibilang ang araw at bituin bago magbura', () {
      final history = HiveService.scheduleHistoryFor(target.id);

      expect(history.days, 2);
      expect(history.stars, 4);
    });

    test('nabubura ang tala ng natapos kasama ng gawain', () async {
      await HiveService.deleteScheduleTask(target.id);

      expect(HiveService.scheduleHistoryFor(target.id).days, 0);
      expect(HiveService.scheduleHistoryFor(target.id).stars, 0);
    });

    test('hindi naaapektuhan ang ibang gawain', () async {
      await HiveService.deleteScheduleTask(target.id);

      expect(HiveService.scheduleHistoryFor(other.id).days, 1);
      expect(HiveService.scheduleHistoryFor(other.id).stars, 3);
    });

    /// Ito ang buong punto ng pagpipiliang "Itago": nananatili ang bituin.
    test('hindi nababawasan ang bituin kapag itinago lang', () async {
      await HiveService.setScheduleTaskHidden(target.id, true);

      expect(HiveService.scheduleHistoryFor(target.id).stars, 4);
    });
  });
}
