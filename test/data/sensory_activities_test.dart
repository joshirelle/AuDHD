import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kiko_app/core/enums/skill_area.dart';
import 'package:kiko_app/core/utils/support_focus_split.dart';
import 'package:kiko_app/data/models/child_profile.dart';
import 'package:kiko_app/modules/sensory/models/sensory_activity.dart';

/// Binabasa ang tunay na asset, hindi kopya — dito lumalabas ang maling tag na
/// hindi mapapansin ng analyzer.
void main() {
  late List<SensoryActivity> activities;

  setUpAll(() {
    final raw = File('assets/data/sensory_activities.json').readAsStringSync();
    activities = (jsonDecode(raw) as List)
        .map((e) => SensoryActivity.fromJson(e as Map<String, dynamic>))
        .toList();
  });

  test('nababasa ang lahat ng gawain', () {
    expect(activities, isNotEmpty);
  });

  test('walang magkaparehong id', () {
    final ids = activities.map((a) => a.id).toList();

    expect(ids.toSet().length, ids.length);
  });

  /// Ang blangkong chip ay mukhang sirang app sa magulang.
  test('may kahit isang gawain ang bawat bahagi', () {
    for (final area in SkillArea.values) {
      expect(
        activities.where((a) => a.skillArea == area),
        isNotEmpty,
        reason: 'Blangko ang chip na ${area.label}',
      );
    }
  });

  test('may hakbang at kagamitan ang bawat gawain', () {
    for (final activity in activities) {
      expect(activity.stepByStepTagalog, isNotEmpty, reason: activity.id);
      expect(activity.materialsNeeded, isNotEmpty, reason: activity.id);
      expect(activity.safetyNoteTagalog, isNotEmpty, reason: activity.id);
      expect(activity.estimatedMinutes, greaterThan(0), reason: activity.id);
    }
  });

  test('nananatili ang mga id ng unang labingwalo', () {
    // Naka-key sa id ang tapos na gawain at ang bituin ng bata. Ang pagpapalit
    // ng id ay pagbura ng kasaysayan ng bawat gumagamit ngayon.
    final ids = activities.map((a) => a.id).toSet();

    for (var i = 1; i <= 18; i++) {
      expect(ids, contains('act_${i.toString().padLeft(2, '0')}'));
    }
  });

  group('pag-aayos ayon sa tag ng bata', () {
    /// Halos kalahati ng gumagamit ay wala pang diagnosis.
    test('nakikita pa rin ang lahat ng gawain kapag walang tag', () {
      final (forChild, rest) = splitByFocus(
        activities,
        const [],
        (a) => a.relevantTo,
      );

      expect(forChild, isEmpty);
      expect(rest.length, activities.length);
    });

    test('walang nawawala o nadodoble sa paghahati', () {
      for (final tag in SupportFocus.values) {
        final (forChild, rest) = splitByFocus(activities, [
          tag,
        ], (a) => a.relevantTo);
        final ids = [...forChild, ...rest].map((a) => a.id).toList();

        expect(ids.length, activities.length, reason: tag.name);
        expect(ids.toSet().length, ids.length, reason: tag.name);
      }
    });

    /// Kung walang gawain ang isang tag, walang mangyayari sa magulang na
    /// pumili nito \u2014 at hindi niya malalaman kung bakit.
    test('may kahit isang gawain ang bawat tag na nag-aayos', () {
      for (final tag in tagsThatSort) {
        final (forChild, _) = splitByFocus(activities, [
          tag,
        ], (a) => a.relevantTo);

        expect(forChild, isNotEmpty, reason: 'Walang gawain ang ${tag.name}');
      }
    });

    /// Kapag lahat ay may tag, walang naiiwan sa ibaba at nawawala ang saysay
    /// ng paghahati.
    test('may naiiwang gawaing walang tag', () {
      expect(activities.where((a) => a.relevantTo.isEmpty), isNotEmpty);
    });
  });
}
