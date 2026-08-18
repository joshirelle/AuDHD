import 'package:flutter_test/flutter_test.dart';
import 'package:kiko_app/core/enums/skill_area.dart';
import 'package:kiko_app/modules/sensory/services/sensory_recommendation_service.dart';

void main() {
  // Kailangan ng binding para mabasa ang asset sa `rootBundle`.
  TestWidgetsFlutterBinding.ensureInitialized();

  test('isang gawain kada bahagi ng paglaki', () async {
    final picks = await SensoryRecommendationService.getDailyRecommendations(
      userProfileResult: 'Sensory Seeking',
      date: DateTime(2026, 8, 19),
    );

    expect(picks.length, SkillArea.values.length);
    expect(
      picks.map((a) => a.skillArea).toSet().length,
      SkillArea.values.length,
    );
  });

  /// Kung magbabago ang pili sa loob ng araw, mawawala sa listahan ang gawaing
  /// natapos na ng bata at mukhang nabura ang bituin niya.
  test('hindi nagbabago ang pili sa loob ng iisang araw', () async {
    final first = await SensoryRecommendationService.getDailyRecommendations(
      userProfileResult: 'Sensory Seeking',
      date: DateTime(2026, 8, 19),
    );
    final second = await SensoryRecommendationService.getDailyRecommendations(
      userProfileResult: 'Sensory Seeking',
      date: DateTime(2026, 8, 19),
    );

    expect(
      first.map((a) => a.id).toList(),
      second.map((a) => a.id).toList(),
    );
  });

  test('nagbabago ang pili kapag ibang araw', () async {
    final today = await SensoryRecommendationService.getDailyRecommendations(
      userProfileResult: 'Sensory Seeking',
      date: DateTime(2026, 8, 19),
    );

    // Sinusuri ang isang linggo: maaaring magkatulad ang dalawang magkasunod
    // na araw dahil sa tsansa, pero hindi ang pito.
    var changed = false;
    for (var day = 20; day <= 26; day++) {
      final other = await SensoryRecommendationService.getDailyRecommendations(
        userProfileResult: 'Sensory Seeking',
        date: DateTime(2026, 8, day),
      );
      if (other.map((a) => a.id).join() != today.map((a) => a.id).join()) {
        changed = true;
        break;
      }
    }

    expect(changed, isTrue);
  });

  test('may laman pa rin kahit walang resulta ng checklist', () async {
    final picks = await SensoryRecommendationService.getDailyRecommendations(
      userProfileResult: '',
      date: DateTime(2026, 8, 19),
    );

    expect(picks.length, SkillArea.values.length);
  });
}
