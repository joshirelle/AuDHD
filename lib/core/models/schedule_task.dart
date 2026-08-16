import 'package:hive/hive.dart';

part 'schedule_task.g.dart';

/// Bahagi ng araw kung kailan ginagawa ang gawain.
@HiveType(typeId: 4)
enum ScheduleTimeOfDay {
  @HiveField(0)
  morning('Umaga'),

  @HiveField(1)
  afternoon('Hapon'),

  @HiveField(2)
  evening('Gabi');

  final String label;

  const ScheduleTimeOfDay(this.label);
}

/// Depinisyon lang ng gawain — walang `isCompleted` dito.
///
/// Ang pagkatapos ay naka-index sa petsa (`HiveService.scheduleKey`), kaya
/// kusang blangko ang bagong araw nang walang timer sa hatinggabi, at hindi
/// nabubura ang tala kahapon.
@HiveType(typeId: 3)
class ScheduleTask {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String titleTagalog;

  /// Susi papunta sa `ScheduleIcons` — hindi codePoint. Tingnan ang paliwanag doon.
  @HiveField(2)
  final String iconKey;

  @HiveField(3)
  final ScheduleTimeOfDay timeOfDay;

  @HiveField(4)
  final int starReward;

  const ScheduleTask({
    required this.id,
    required this.titleTagalog,
    required this.iconKey,
    required this.timeOfDay,
    this.starReward = 1,
  });

  /// Nasa code at hindi sa Hive: kapag naisulat sa box ang mga ito sa unang
  /// pagbukas, hindi na maaabot ng susunod na bersyon ng app ang mga lumang user.
  static const List<ScheduleTask> defaults = [
    ScheduleTask(
      id: 'default_almusal',
      titleTagalog: 'Pag-almusal',
      iconKey: 'breakfast',
      timeOfDay: ScheduleTimeOfDay.morning,
    ),
    ScheduleTask(
      id: 'default_sipilyo',
      titleTagalog: 'Magsipilyo',
      iconKey: 'toothbrush',
      timeOfDay: ScheduleTimeOfDay.morning,
    ),
    ScheduleTask(
      id: 'default_aaral',
      titleTagalog: 'Pag-aaral',
      iconKey: 'school',
      timeOfDay: ScheduleTimeOfDay.morning,
    ),
    ScheduleTask(
      id: 'default_tanghalian',
      titleTagalog: 'Pananghalian',
      iconKey: 'lunch',
      timeOfDay: ScheduleTimeOfDay.afternoon,
    ),
    ScheduleTask(
      id: 'default_laro',
      titleTagalog: 'Oras ng Laro',
      iconKey: 'toy',
      timeOfDay: ScheduleTimeOfDay.afternoon,
    ),
    ScheduleTask(
      id: 'default_tahimik',
      titleTagalog: 'Tahimik na Oras',
      iconKey: 'pencil',
      timeOfDay: ScheduleTimeOfDay.afternoon,
    ),
    ScheduleTask(
      id: 'default_ehersisyo',
      titleTagalog: 'Pag-eehersisyo',
      iconKey: 'run',
      timeOfDay: ScheduleTimeOfDay.afternoon,
    ),
    ScheduleTask(
      id: 'default_hapunan',
      titleTagalog: 'Hapunan',
      iconKey: 'dinner',
      timeOfDay: ScheduleTimeOfDay.evening,
    ),
    ScheduleTask(
      id: 'default_ligo',
      titleTagalog: 'Pagligo',
      iconKey: 'bath',
      timeOfDay: ScheduleTimeOfDay.evening,
    ),
  ];
}
