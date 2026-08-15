import 'package:hive_flutter/hive_flutter.dart';
import '../models/child_profile.dart';
import '../models/screening_result.dart';
import '../models/behavior_log.dart';

class HiveService {
  static const String _screeningBoxName = 'screening_results';
  static const String _profileBoxName = 'child_profile';
  static const String _profileKey = 'child';
  static const String _behaviorBoxName = 'behavior_logs';

  /// I-initialize ang Hive sa app startup
  static Future<void> init() async {
    await Hive.initFlutter();
    // Register Adapters
    Hive.registerAdapter(BehaviorLogAdapter());

    await Hive.openBox(_screeningBoxName);
    await Hive.openBox(_profileBoxName);
    // Open Boxes
    await Hive.openBox<BehaviorLog>(_behaviorBoxName);
  }

  static Box<BehaviorLog> getBehaviorBox() =>
      Hive.box<BehaviorLog>(_behaviorBoxName);

  static Future<void> addLog(BehaviorLog log) async {
    final box = getBehaviorBox();
    await box.put(log.id, log);
  }

  static List<BehaviorLog> getAllLogs() {
    final box = getBehaviorBox();
    return box.values.toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
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

  static Future<void> saveChildProfile(ChildProfile profile) async {
    await Hive.box(_profileBoxName).put(_profileKey, profile.toMap());
  }

  static Future<void> deleteChildProfile() async {
    await Hive.box(_profileBoxName).delete(_profileKey);
  }

  static ChildProfile? getChildProfile() {
    final raw = Hive.box(_profileBoxName).get(_profileKey);
    return raw == null ? null : ChildProfile.fromMap(raw as Map);
  }
}