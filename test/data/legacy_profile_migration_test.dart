import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:kiko_app/core/models/schedule_task.dart';
import 'package:kiko_app/data/models/behavior_log.dart';
import 'package:kiko_app/data/models/child_profile.dart';
import 'package:kiko_app/data/models/sensory_profile_result.dart';
import 'package:kiko_app/data/services/hive_service.dart';

/// Ang profile na na-save bago ang multi-child ay walang `id`.
///
/// Kapag nagkaiba ang id sa dalawang pagbukas ng app, ang lahat ng datos na
/// naka-susi sa lumang id ay hindi na mahahanap — mga milestone, iskedyul,
/// tala ng ugali. Tahimik iyon at hindi na maibabalik, kaya dito ito hinuhuli.
void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('audhd_legacy_profile');
    Hive.init(tempDir.path);
    Hive.registerAdapter(BehaviorLogAdapter());
    Hive.registerAdapter(SensoryProfileResultAdapter());
    Hive.registerAdapter(ScheduleTaskAdapter());
    Hive.registerAdapter(ScheduleTimeOfDayAdapter());
    await Hive.openBox('child_profile');
    await Hive.openBox('child_profiles');
    await Hive.openBox<String>('app_prefs');
    await Hive.openBox<bool>('app_settings');
    await Hive.openBox<int>('milestone_progress');
    await Hive.openBox<String>('daily_mood');
    await Hive.openBox<BehaviorLog>('behavior_logs');
    await Hive.openBox<SensoryProfileResult>('sensory_profiles');
    await Hive.openBox<bool>('sensory_completion_box');
    await Hive.openBox<ScheduleTask>('schedule_box');
    await Hive.openBox<int>('schedule_completion');
    await Hive.openBox<int>('schedule_order');
    await Hive.openBox<bool>('schedule_hidden');
    await Hive.openBox<int>('custom_rewards');
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  setUp(() async {
    await Hive.box('child_profile').clear();
    await Hive.box('child_profiles').clear();
    await Hive.box<String>('app_prefs').clear();
    await Hive.box<bool>('app_settings').clear();
    await Hive.box<int>('milestone_progress').clear();
    await Hive.box<String>('daily_mood').clear();
  });

  /// Eksaktong hugis ng isinusulat ng v6: walang `id`, walang `supportFocus`.
  Map<String, dynamic> v6Profile() => {
    'name': 'Miguel',
    'birthDate': DateTime(2021, 5, 2).toIso8601String(),
    'gender': 'male',
    'nickname': 'Migs',
    'photoFileName': 'child_abc.jpg',
  };

  Future<void> saveV6() => Hive.box('child_profile').put('child', v6Profile());

  /// Basa nang diretso sa lumang box: ang `getChildProfile` ay dumadaan na sa
  /// `child_profiles`, at hindi pa iyon ang sinusukat dito.
  ChildProfile legacyChild() =>
      ChildProfile.fromMap(Hive.box('child_profile').get('child') as Map);

  test('a profile saved before multi-child is given an id', () async {
    await saveV6();

    await HiveService.assignIdToLegacyProfile();

    expect(legacyChild().id, isNotEmpty);
  });

  test('the id is the same on the next launch', () async {
    await saveV6();

    await HiveService.assignIdToLegacyProfile();
    final first = legacyChild().id;

    await HiveService.assignIdToLegacyProfile();
    final second = legacyChild().id;

    expect(second, first);
  });

  test('nothing else about the child is lost', () async {
    await saveV6();

    await HiveService.assignIdToLegacyProfile();

    final child = legacyChild();
    expect(child.name, 'Miguel');
    expect(child.birthDate, DateTime(2021, 5, 2));
    expect(child.gender, Gender.male);
    expect(child.nickname, 'Migs');
    expect(child.photoFileName, 'child_abc.jpg');
    expect(child.supportFocus, isEmpty);
  });

  test('an empty box is left alone', () async {
    await HiveService.assignIdToLegacyProfile();

    expect(Hive.box('child_profile').get('child'), isNull);
  });

  test('reading a profile with no id and no replacement throws', () {
    expect(() => ChildProfile.fromMap(v6Profile()), throwsArgumentError);
  });

  group('support focus', () {
    test('the chosen tags survive save and load', () async {
      await HiveService.saveChildProfile(
        ChildProfile(
          id: 'c1',
          name: 'Sofia',
          birthDate: DateTime(2022, 1, 1),
          supportFocus: const [SupportFocus.adhd, SupportFocus.asd],
        ),
      );

      // Sinusunod ang pagkakasunod ng enum, hindi ang pagkakasulat.
      expect(HiveService.getChildProfile()!.supportFocus, [
        SupportFocus.asd,
        SupportFocus.adhd,
      ]);
    });

    test('a tag removed from the app is ignored, not fatal', () {
      final child = ChildProfile.fromMap({
        ...v6Profile(),
        'id': 'c1',
        'supportFocus': ['asd', 'wala_na_ito'],
      });

      expect(child.supportFocus, [SupportFocus.asd]);
    });
  });

  group('moving to many children', () {
    test('the single child becomes the first and active one', () async {
      await saveV6();
      await HiveService.assignIdToLegacyProfile();

      await HiveService.migrateToMultiProfile();

      final children = HiveService.getChildProfiles();
      expect(children, hasLength(1));
      expect(children.single.name, 'Miguel');
      expect(HiveService.getActiveChildId(), children.single.id);
    });

    test('running it twice does not make a second copy', () async {
      await saveV6();
      await HiveService.assignIdToLegacyProfile();

      await HiveService.migrateToMultiProfile();
      await HiveService.migrateToMultiProfile();

      expect(HiveService.getChildProfiles(), hasLength(1));
    });

    /// Ang pinakamadaling maling bantay ay ang laman ng box. Kapag ganoon,
    /// babalik ang binurang bata sa susunod na pagbukas ng app.
    test('a deleted child does not come back on the next launch', () async {
      await saveV6();
      await HiveService.assignIdToLegacyProfile();
      await HiveService.migrateToMultiProfile();

      await HiveService.deleteChildProfile();
      await HiveService.migrateToMultiProfile();

      expect(HiveService.getChildProfiles(), isEmpty);
      expect(HiveService.getActiveChild(), isNull);
    });

    test('an app with no child at all stays empty', () async {
      await HiveService.migrateToMultiProfile();

      expect(HiveService.getChildProfiles(), isEmpty);
      expect(HiveService.getActiveChildId(), isNull);
    });
  });

  group('switching and removing', () {
    Future<void> addThree() async {
      for (final entry in {
        'a': 'Andres',
        'b': 'Miguel',
        'c': 'Sofia',
      }.entries) {
        await HiveService.saveChild(
          ChildProfile(
            id: entry.key,
            name: entry.value,
            birthDate: DateTime(2021, 1, 1),
          ),
        );
      }
    }

    test('the first child added becomes the active one', () async {
      await addThree();

      expect(HiveService.getActiveChildId(), 'a');
    });

    test('the list is sorted by name, not by when they were added', () async {
      await addThree();

      expect(HiveService.getChildProfiles().map((c) => c.name), [
        'Andres',
        'Miguel',
        'Sofia',
      ]);
    });

    test('removing the active child hands over to another', () async {
      await addThree();
      await HiveService.setActiveChild('b');

      await HiveService.removeChild('b');

      expect(HiveService.getActiveChildId(), isNot('b'));
      expect(HiveService.getActiveChild(), isNotNull);
    });

    test('removing a different child leaves the active one alone', () async {
      await addThree();
      await HiveService.setActiveChild('b');

      await HiveService.removeChild('c');

      expect(HiveService.getActiveChildId(), 'b');
    });

    test('removing the last child leaves nobody active', () async {
      await HiveService.saveChild(
        ChildProfile(id: 'a', name: 'Andres', birthDate: DateTime(2021, 1, 1)),
      );

      await HiveService.removeChild('a');

      expect(HiveService.getActiveChildId(), isNull);
      expect(HiveService.getActiveChild(), isNull);
    });

    /// Puwedeng mawala ang aktibo nang hindi dumadaan sa `removeChild` —
    /// halimbawa sa restore. Hindi dapat magmukhang walang bata ang app.
    test('a dangling active id falls back to the first child', () async {
      await addThree();
      await HiveService.setActiveChild('wala_na_ito');

      expect(HiveService.getActiveChild()!.name, 'Andres');
    });
  });

  group('carrying the old data over', () {
    /// Ang buong punto ng paglipat: ang natapos na milestone at naitalang
    /// damdamin ng magulang ay dapat nasa unang bata pagkatapos.
    test(
      'what the parent already recorded belongs to the first child',
      () async {
        await saveV6();
        await HiveService.assignIdToLegacyProfile();
        // Isinusulat nang walang prefix, gaya ng v6.
        await Hive.box<int>(
          'milestone_progress',
        ).put('cdc_24_se_1_achieved', 1);
        await Hive.box<String>('daily_mood').put('mood_2026-08-16', 'masaya');

        await HiveService.migrateToMultiProfile();

        expect(HiveService.getMilestoneBox().get('cdc_24_se_1_achieved'), 1);
        expect(HiveService.getMoodBox().get('mood_2026-08-16'), 'masaya');
      },
    );

    test('the v6 keys are kept, not moved', () async {
      await saveV6();
      await HiveService.assignIdToLegacyProfile();
      await Hive.box<int>('milestone_progress').put('cdc_24_se_1_achieved', 1);

      await HiveService.migrateToMultiProfile();

      // Kopya, hindi paglilipat: may mababalikan kung may masira.
      expect(
        Hive.box<int>('milestone_progress').get('cdc_24_se_1_achieved'),
        1,
      );
    });

    test('a second child does not see the first one data', () async {
      await saveV6();
      await HiveService.assignIdToLegacyProfile();
      await Hive.box<int>('milestone_progress').put('cdc_24_se_1_achieved', 1);
      await HiveService.migrateToMultiProfile();

      await HiveService.saveChild(
        ChildProfile(id: 'b', name: 'Sofia', birthDate: DateTime(2022, 1, 1)),
      );
      await HiveService.setActiveChild('b');

      expect(HiveService.getMilestoneBox().get('cdc_24_se_1_achieved'), isNull);
      expect(HiveService.getMilestoneBox().length, 0);
    });
  });

  group('deleting a child', () {
    test('nothing of theirs is left behind', () async {
      await HiveService.saveChild(
        ChildProfile(id: 'a', name: 'Andres', birthDate: DateTime(2021, 1, 1)),
      );
      await HiveService.setActiveChild('a');
      await HiveService.setMilestoneAchieved('cdc_24_se_1', true);
      await HiveService.saveMood(DateTime(2026, 8, 16), 'masaya');

      await HiveService.deleteChildData('a');
      await HiveService.removeChild('a');

      expect(Hive.box<int>('milestone_progress').keys, isEmpty);
      expect(Hive.box<String>('daily_mood').keys, isEmpty);
      expect(HiveService.getChildProfiles(), isEmpty);
    });

    test('the other children keep everything', () async {
      for (final id in ['a', 'b']) {
        await HiveService.saveChild(
          ChildProfile(id: id, name: id, birthDate: DateTime(2021, 1, 1)),
        );
        await HiveService.setActiveChild(id);
        await HiveService.setMilestoneAchieved('cdc_24_se_1', true);
      }

      await HiveService.deleteChildData('a');
      await HiveService.removeChild('a');

      await HiveService.setActiveChild('b');
      expect(HiveService.getMilestoneBox().length, 1);
    });
  });
}
