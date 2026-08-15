import 'package:hive/hive.dart';

part 'sensory_profile_result.g.dart';

@HiveType(typeId: 2) // Unique typeId = 2 para sa Hive
class SensoryProfileResult extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  final Map<String, int> answers; // ItemID -> Score (0: Hindi kelanman, 1: Minsan, 2: Madalas, 3: Palagi)

  @HiveField(3)
  final int totalSeekingScore;

  @HiveField(4)
  final int totalAvoidingScore;

  @HiveField(5)
  final String primaryProfile; // 'Sensory Seeking', 'Sensory Avoiding', 'Mixed Profile', o 'Typical'

  @HiveField(6)
  final Map<String, String> domainBreakdown; // Domain -> Profile Status

  SensoryProfileResult({
    required this.id,
    required this.timestamp,
    required this.answers,
    required this.totalSeekingScore,
    required this.totalAvoidingScore,
    required this.primaryProfile,
    required this.domainBreakdown,
  });
}