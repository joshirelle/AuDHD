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

  /// Minuto mula hatinggabi, hal. `450` para sa 7:30 AM.
  ///
  /// `null` kapag walang tiyak na oras — iyon ang lahat ng default, at ang
  /// mga lumang gawain na naitala bago ito idagdag.
  @HiveField(5)
  final int? minuteOfDay;

  const ScheduleTask({
    required this.id,
    required this.titleTagalog,
    required this.iconKey,
    required this.timeOfDay,
    this.starReward = 1,
    this.minuteOfDay,
  });

  /// Halimbawa: `7:30 AM`. Blangko kapag walang tiyak na oras.
  String get timeLabel {
    final minutes = minuteOfDay;
    if (minutes == null) return '';

    final hour24 = minutes ~/ 60;
    final minute = (minutes % 60).toString().padLeft(2, '0');
    final suffix = hour24 < 12 ? 'AM' : 'PM';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    return '$hour12:$minute $suffix';
  }

  /// Para sa kopya ng datos. Pangalan ng enum ang isinusulat, hindi index,
  /// para hindi masira kapag nadagdagan ang `ScheduleTimeOfDay`.
  Map<String, dynamic> toJson() => {
    'id': id,
    'titleTagalog': titleTagalog,
    'iconKey': iconKey,
    'timeOfDay': timeOfDay.name,
    'starReward': starReward,
    'minuteOfDay': minuteOfDay,
  };

  factory ScheduleTask.fromJson(Map<String, dynamic> json) => ScheduleTask(
    id: json['id'] as String,
    titleTagalog: json['titleTagalog'] as String? ?? '',
    iconKey: json['iconKey'] as String? ?? 'star',
    timeOfDay: ScheduleTimeOfDay.values.firstWhere(
      (e) => e.name == json['timeOfDay'],
      orElse: () => ScheduleTimeOfDay.morning,
    ),
    starReward: json['starReward'] as int? ?? 1,
    minuteOfDay: json['minuteOfDay'] as int?,
  );

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
