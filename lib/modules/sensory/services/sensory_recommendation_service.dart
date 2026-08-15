import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
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

  /// Tatlong gawain: dalawang tugma sa profile ng bata, isang regulation.
  static Future<List<SensoryActivity>> getDailyRecommendations({
    required String userProfileResult,
  }) async {
    final all = await loadAll();
    final profile = normalizeProfile(userProfileResult);
    // Iisang seed kada araw para hindi magbago ang pili sa bawat rebuild.
    final random = Random(_todaySeed());

    final picks = <SensoryActivity>[];

    if (profile == profileMixed) {
      picks.addAll(_pick(all, profileSeeking, 1, random));
      picks.addAll(_pick(all, profileAvoiding, 1, random));
    } else {
      picks.addAll(_pick(all, profile, 2, random));
    }

    picks.addAll(_pick(all, profileRegulation, 1, random));
    return picks;
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

  static List<SensoryActivity> _pick(
    List<SensoryActivity> all,
    String targetProfile,
    int count,
    Random random,
  ) {
    final matches = all.where((a) => a.targetProfile == targetProfile).toList();
    if (matches.isEmpty) return [];

    matches.shuffle(random);
    return matches.take(count).toList();
  }

  static int _todaySeed() {
    final now = DateTime.now();
    return now.year * 10000 + now.month * 100 + now.day;
  }
}
