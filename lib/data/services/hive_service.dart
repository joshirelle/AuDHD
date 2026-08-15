import 'package:hive_flutter/hive_flutter.dart';
import '../models/screening_result.dart';

class HiveService {
  static const String _screeningBoxName = 'screening_results';

  /// I-initialize ang Hive sa app startup
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_screeningBoxName);
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
}