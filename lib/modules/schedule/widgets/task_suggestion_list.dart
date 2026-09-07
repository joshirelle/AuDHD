import 'package:flutter/material.dart';

import '../../../core/i18n/language_controller.dart';
import '../../../core/models/schedule_task.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/support_focus_split.dart';
import '../../../data/services/hive_service.dart';
import '../../../widgets/kiko_card.dart';
import '../data/task_suggestions.dart';
import 'schedule_style.dart';

/// Mga handang gawaing maaaring idagdag ng magulang.
///
/// Nag-aayos ang tag ng bata, hindi nagtatago: nasa ibaba pa rin ang lahat.
class TaskSuggestionList extends StatelessWidget {
  const TaskSuggestionList({super.key, required this.onPick});

  final ValueChanged<TaskSuggestion> onPick;

  @override
  Widget build(BuildContext context) {
    final child = HiveService.getActiveChild();
    final (forChild, rest) = splitByFocus(
      TaskSuggestions.all,
      child?.supportFocus ?? const [],
      (suggestion) => suggestion.relevantTo,
    );

    final showsSplit = child != null && forChild.isNotEmpty && rest.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNote(),
        const SizedBox(height: 16),
        if (!showsSplit)
          ..._buildByTime(TaskSuggestions.all)
        else ...[
          _buildHeader(
            tr(
              'PARA KAY ${child.displayName.toUpperCase()}',
              'FOR ${child.displayName.toUpperCase()}',
            ),
            note: tr(
              'Nakabatay sa mga tag sa profile niya. Nakikita mo pa rin ang '
                  'lahat sa ibaba.',
              'Based on the tags on their profile. Everything is still below.',
            ),
          ),
          const SizedBox(height: 14),
          ..._buildByTime(forChild),
          const SizedBox(height: 6),
          _buildHeader(tr('IBA PANG MUNGKAHI', 'MORE SUGGESTIONS')),
          const SizedBox(height: 14),
          ..._buildByTime(rest),
        ],
      ],
    );
  }

  /// Ang mungkahing walang paliwanag ay utos. Sinasabi rin nito kung ano ang
  /// hindi mangyayari: walang pumapasok sa araw hangga't hindi pinipindot.
  Widget _buildNote() {
    return KikoCard(
      backgroundColor: AppColors.tintGold,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: AppColors.warning,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              tr(
                'Wala sa mga ito ang papasok sa araw ni anak hangga\'t hindi mo '
                    'pinipindot. Piliin lang ang bagay sa inyo — hindi ito '
                    'listahan ng dapat gawin.',
                'None of these go into your child\'s day until you tap them. '
                    'Take only what fits your family — this is not a list of '
                    'things you must do.',
              ),
              style: const TextStyle(
                fontSize: 11.5,
                height: 1.45,
                color: AppColors.textDark,
                fontFamily: 'Nunito',
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildByTime(List<TaskSuggestion> suggestions) {
    final widgets = <Widget>[];

    for (final time in ScheduleTimeOfDay.values) {
      final inTime = suggestions.where((s) => s.timeOfDay == time).toList();
      if (inTime.isEmpty) continue;

      widgets
        ..add(_buildTimeHeader(time))
        ..add(const SizedBox(height: 10));
      for (final suggestion in inTime) {
        widgets
          ..add(_buildSuggestion(suggestion))
          ..add(const SizedBox(height: 10));
      }
      widgets.add(const SizedBox(height: 8));
    }

    return widgets;
  }

  Widget _buildTimeHeader(ScheduleTimeOfDay time) {
    final style = ScheduleTimeStyle.of(time);

    return Row(
      children: [
        Icon(style.icon, size: 16, color: style.accent),
        const SizedBox(width: 8),
        Text(
          time.displayLabel.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.6,
            color: AppColors.textMuted,
            fontFamily: 'Nunito',
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestion(TaskSuggestion suggestion) {
    final style = ScheduleTimeStyle.of(suggestion.timeOfDay);
    // Nasa iskedyul na. Kasama ang pagtatago sa tsek: ang gawaing nakatago ay
    // wala sa araw ng bata, kaya hindi ito dapat magmukhang nandoon na.
    final isAdded =
        HiveService.getScheduleBox().containsKey(suggestion.id) &&
        !HiveService.isScheduleTaskHidden(suggestion.id);

    return KikoCard(
      backgroundColor: AppColors.surface,
      padding: const EdgeInsets.all(14),
      borderColor: isAdded ? AppColors.logoGreen : null,
      onTap: isAdded ? null : () => onPick(suggestion),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: style.fill,
              shape: BoxShape.circle,
            ),
            child: Icon(
              ScheduleIcons.of(suggestion.iconKey),
              size: 21,
              color: ScheduleIcons.inkOf(suggestion.iconKey),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  suggestion.title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    fontFamily: 'Nunito',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  suggestion.why,
                  style: const TextStyle(
                    fontSize: 11.5,
                    height: 1.45,
                    color: AppColors.textMuted,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Icon(
            isAdded ? Icons.check_circle_rounded : Icons.add_circle_rounded,
            size: 26,
            color: isAdded ? AppColors.logoGreen : style.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String label, {String? note}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            color: AppColors.textDark,
            fontFamily: 'Nunito',
          ),
        ),
        if (note != null) ...[
          const SizedBox(height: 4),
          Text(
            note,
            style: const TextStyle(
              fontSize: 11,
              height: 1.4,
              color: AppColors.textMuted,
              fontFamily: 'Nunito',
            ),
          ),
        ],
        const SizedBox(height: 8),
        const SizedBox(
          height: 1,
          width: double.infinity,
          child: ColoredBox(color: AppColors.divider),
        ),
      ],
    );
  }
}
