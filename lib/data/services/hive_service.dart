import 'package:hive_flutter/hive_flutter.dart';
import '../models/child_profile.dart';
import '../models/screening_result.dart';

class HiveService {
  static const String _screeningBoxName = 'screening_results';
  static const String _profileBoxName = 'child_profiles';
  static const String _settingsBoxName = 'app_settings';
  static const String _activeChildKey = 'active_child_id';

  /// I-initialize ang Hive sa app startup
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_screeningBoxName);
    await Hive.openBox(_profileBoxName);
    await Hive.openBox(_settingsBoxName);
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
    final box = Hive.box(_profileBoxName);
    await box.put(profile.id, profile.toMap());
  }

  static Future<void> deleteChildProfile(String id) async {
    await Hive.box(_profileBoxName).delete(id);
    if (getActiveChildId() == id) {
      await Hive.box(_settingsBoxName).delete(_activeChildKey);
    }
  }

  static List<ChildProfile> getAllChildProfiles() {
    final box = Hive.box(_profileBoxName);
    final profiles = [
      for (final item in box.values) ChildProfile.fromMap(item as Map),
    ];
    profiles.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return profiles;
  }

  static ChildProfile? getChildProfile(String? id) {
    if (id == null) return null;
    final raw = Hive.box(_profileBoxName).get(id);
    return raw == null ? null : ChildProfile.fromMap(raw as Map);
  }

  static String? getActiveChildId() {
    return Hive.box(_settingsBoxName).get(_activeChildKey) as String?;
  }

  static Future<void> setActiveChildId(String? id) async {
    final box = Hive.box(_settingsBoxName);
    if (id == null) {
      await box.delete(_activeChildKey);
    } else {
      await box.put(_activeChildKey, id);
    }
  }

  static ChildProfile? getActiveChild() => getChildProfile(getActiveChildId());
}