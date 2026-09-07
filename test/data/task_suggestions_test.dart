import 'package:flutter_test/flutter_test.dart';
import 'package:kiko_app/core/models/schedule_task.dart';
import 'package:kiko_app/core/utils/support_focus_split.dart';
import 'package:kiko_app/data/models/child_profile.dart';
import 'package:kiko_app/modules/schedule/data/task_suggestions.dart';
import 'package:kiko_app/modules/schedule/widgets/schedule_style.dart';

void main() {
  final suggestions = TaskSuggestions.all;

  test('no two suggestions share an id', () {
    final ids = suggestions.map((s) => s.id).toList();

    expect(ids.toSet().length, ids.length);
  });

  /// Nagiging `ScheduleTask.id` ang mga ito. Ang pagsalubong sa isang
  /// `default_*` ay magpapalit ng gawaing ginagawa na ng bata.
  test('no suggestion can collide with a default task', () {
    final defaults = ScheduleTask.defaults.map((t) => t.id).toSet();

    for (final suggestion in suggestions) {
      expect(defaults, isNot(contains(suggestion.id)), reason: suggestion.id);
    }
  });

  test('every suggestion uses a real icon', () {
    for (final suggestion in suggestions) {
      expect(
        ScheduleIcons.all,
        contains(suggestion.iconKey),
        reason: suggestion.id,
      );
    }
  });

  /// Ang mungkahing walang paliwanag ay utos, hindi gabay.
  test('every suggestion says why it helps', () {
    for (final suggestion in suggestions) {
      expect(suggestion.whyFil.trim(), isNotEmpty, reason: suggestion.id);
      expect(suggestion.whyEn.trim(), isNotEmpty, reason: suggestion.id);
    }
  });

  test('every part of the day has suggestions', () {
    for (final time in ScheduleTimeOfDay.values) {
      expect(
        TaskSuggestions.inTime(time),
        isNotEmpty,
        reason: 'Blangko ang ${time.name}',
      );
    }
  });

  test('the task it becomes keeps the same id', () {
    for (final suggestion in suggestions) {
      expect(suggestion.toTask().id, suggestion.id);
      expect(suggestion.toTask().timeOfDay, suggestion.timeOfDay);
    }
  });

  group('pag-aayos ayon sa tag ng bata', () {
    test('nakikita pa rin ang lahat kapag walang tag', () {
      final (forChild, rest) = splitByFocus(
        suggestions,
        const [],
        (s) => s.relevantTo,
      );

      expect(forChild, isEmpty);
      expect(rest.length, suggestions.length);
    });

    test('walang nawawala o nadodoble', () {
      for (final tag in SupportFocus.values) {
        final (forChild, rest) = splitByFocus(suggestions, [
          tag,
        ], (s) => s.relevantTo);
        final ids = [...forChild, ...rest].map((s) => s.id).toList();

        expect(ids.length, suggestions.length, reason: tag.name);
        expect(ids.toSet().length, ids.length, reason: tag.name);
      }
    });

    /// Bawat tag ay dapat may mungkahi sa bawat bahagi ng araw — iyon ang
    /// hiningi: umaga, hapon, at gabi na naaayon sa bata.
    test('may mungkahi ang bawat tag sa bawat bahagi ng araw', () {
      for (final tag in tagsThatSort) {
        final (forChild, _) = splitByFocus(suggestions, [
          tag,
        ], (s) => s.relevantTo);

        for (final time in ScheduleTimeOfDay.values) {
          expect(
            forChild.where((s) => s.timeOfDay == time),
            isNotEmpty,
            reason: 'Walang ${time.name} para sa ${tag.name}',
          );
        }
      }
    });

    /// Kapag lahat ay may tag, walang laman ang "Iba Pang Mungkahi".
    test('may mungkahing walang tag', () {
      expect(suggestions.where((s) => s.relevantTo.isEmpty), isNotEmpty);
    });
  });
}
