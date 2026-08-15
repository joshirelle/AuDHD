import 'package:hive/hive.dart';

part 'behavior_log.g.dart';

@HiveType(typeId: 1) // Unique typeId para sa Hive
class BehaviorLog extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  final String antecedent; // (A) Ano ang nangyari bago ang insidente? (e.g., Malakas na ingay, transition sa pagligo)

  @HiveField(3)
  final String behavior; // (B) Kilos / Insidente (e.g., Meltdown, Pagtakip ng tainga, Pag-iyak, Pambabato)

  @HiveField(4)
  final String consequence; // (C) Anong ginawa o tugon pagkatapos? (e.g., Binigyan ng noise-canceling headphones, niyakap)

  @HiveField(5)
  final List<String> sensoryTriggers; // Tags: Auditory, Visual, Tactile, Proprioceptive, Hunger/Fatigue

  @HiveField(6)
  final int intensity; // 1 (Mild) hanggang 5 (Severe)

  @HiveField(7)
  final int durationMinutes; // Tagal ng insidente

  @HiveField(8)
  final String? notes; // Karagdagang tala ng magulang

  BehaviorLog({
    required this.id,
    required this.timestamp,
    required this.antecedent,
    required this.behavior,
    required this.consequence,
    required this.sensoryTriggers,
    required this.intensity,
    required this.durationMinutes,
    this.notes,
  });
}