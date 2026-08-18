import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../../../core/enums/skill_area.dart';
import '../models/sensory_activity.dart';

class SensoryRecommendationService {
  static const String _assetPath = 'assets/data/sensory_activities.json';

  static const String profileSeeking = 'seeking';
  static const String profileAvoiding = 'avoiding';
  static const String profileMixed = 'mixed';
  static const String profileRegulation = 'regulation';

  static List<SensoryActivity>? _cache;

  static Future<List<SensoryActivity>> loadAll() async {
    if (_cache != null) return _cache!;

    final List<dynamic> data = json.decode(await rootBundle.loadString(_assetPath));
    _cache = data
        .map((item) => SensoryActivity.fromJson(item as Map<String, dynamic>))
        .toList();
    return _cache!;
  }

  /// Isang gawain kada bahagi ng paglaki — anim lahat, bago kada araw.
  ///
  /// Iisang seed kada araw: hindi nagbabago ang pili sa bawat rebuild, kaya
  /// hindi nawawala sa listahan ang natapos nang gawain sa kalagitnaan ng araw.
  static Future<List<SensoryActivity>> getDailyRecommendations({
    required String userProfileResult,
    DateTime? date,
  }) async {
    final all = await loadAll();
    final profile = normalizeProfile(userProfileResult);
    final random = Random(_seedFor(date ?? DateTime.now()));

    final picks = <SensoryActivity>[];
    for (final area in SkillArea.values) {
      final inArea = all.where((a) => a.skillArea == area).toList();
      if (inArea.isEmpty) continue;
      inArea.shuffle(random);
      picks.add(_preferred(inArea, profile));
    }
    return picks;
  }

  /// Mas mabuti ang tugma sa profile ng bata, pero hindi ito hadlang — mas
  /// mahalagang may kinatawan ang bawat bahagi kaysa perpektong tugma.
  static SensoryActivity _preferred(
    List<SensoryActivity> shuffled,
    String profile,
  ) {
    if (profile != profileMixed) {
      for (final activity in shuffled) {
        if (activity.targetProfile == profile) return activity;
      }
    }
    for (final activity in shuffled) {
      if (activity.targetProfile == profileRegulation) return activity;
    }
    return shuffled.first;
  }

  /// Tinatanggap ang maikling code o ang buong `primaryProfile` mula sa calculator.
  static String normalizeProfile(String raw) {
    final value = raw.toLowerCase();
    if (value.contains('mixed')) return profileMixed;
    if (value.contains('seek')) return profileSeeking;
    if (value.contains('avoid') || value.contains('sensitive')) {
      return profileAvoiding;
    }
    // Walang malinaw na hilig — balansehin ang dalawang panig.
    return profileMixed;
  }

  static int _seedFor(DateTime date) {
    return date.year * 10000 + date.month * 100 + date.day;
  }
}
