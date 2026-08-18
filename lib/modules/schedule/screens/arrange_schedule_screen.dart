import 'package:flutter/material.dart';

import '../../../core/models/schedule_task.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/hive_service.dart';
import '../../../widgets/how_to_card.dart';
import '../widgets/schedule_style.dart';

/// Pag-aayos ng sariling iskedyul: pagkakasunod-sunod at pagtatago.
///
/// Hiwalay ang listahan kada bahagi ng araw. Ang paglipat ng umaga papuntang
/// gabi ay hindi pag-aayos kundi pagpapalit ng gawain, kaya hindi ito dito.
class ArrangeScheduleScreen extends StatefulWidget {
  const ArrangeScheduleScreen({super.key});

  @override
  State<ArrangeScheduleScreen> createState() => _ArrangeScheduleScreenState();
}

class _ArrangeScheduleScreenState extends State<ArrangeScheduleScreen> {
  late List<ScheduleTask> _tasks = HiveService.getAllScheduleTasks();

  List<ScheduleTask> _inBucket(ScheduleTimeOfDay time) =>
      _tasks.where((task) => task.timeOfDay == time).toList();

  Future<void> _reorder(
    ScheduleTimeOfDay time,
    int oldIndex,
    int newIndex,
  ) async {
    final bucket = _inBucket(time);
    if (newIndex > oldIndex) newIndex--;
    bucket.insert(newIndex, bucket.removeAt(oldIndex));

    final rebuilt = <ScheduleTask>[];
    for (final value in ScheduleTimeOfDay.values) {
      rebuilt.addAll(value == time ? bucket : _inBucket(value));
    }

    setState(() => _tasks = rebuilt);
    await HiveService.saveScheduleOrder(rebuilt);
  }

  Future<void> _toggleHidden(ScheduleTask task) async {
    await HiveService.setScheduleTaskHidden(
      task.id,
      !HiveService.isScheduleTaskHidden(task.id),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ayusin ang Iskedyul'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          const HowToCard(
            steps: [
              'Hilahin ang ☰ para baguhin ang pagkakasunod-sunod.',
              'Pindutin ang mata para itago ang gawaing hindi ninyo ginagawa.',
              'Ang nakatago ay hindi mabubura — maibabalik mo ito anumang oras.',
            ],
            footnote:
                'Sa loob lang ng bawat bahagi ng araw ang paghila. Kung mali '
                'ang oras ng isang gawain, burahin ito at gumawa ng bago.',
          ),
          const SizedBox(height: 20),
          for (final time in ScheduleTimeOfDay.values) ...[
            _buildBucketHeader(time),
            const SizedBox(height: 8),
            _buildBucket(time),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildBucketHeader(ScheduleTimeOfDay time) {
    final style = ScheduleTimeStyle.of(time);

    return Row(
      children: [
        Icon(style.icon, size: 18, color: style.accent),
        const SizedBox(width: 8),
        Text(
          time.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
            fontFamily: 'Nunito',
          ),
        ),
      ],
    );
  }

  Widget _buildBucket(ScheduleTimeOfDay time) {
    final bucket = _inBucket(time);

    if (bucket.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Wala pang gawain dito.',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
            fontFamily: 'Nunito',
          ),
        ),
      );
    }

    return ReorderableListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      onReorder: (oldIndex, newIndex) => _reorder(time, oldIndex, newIndex),
      children: [
        for (var index = 0; index < bucket.length; index++)
          _buildRow(bucket[index], index),
      ],
    );
  }

  Widget _buildRow(ScheduleTask task, int index) {
    final hidden = HiveService.isScheduleTaskHidden(task.id);
    final style = ScheduleTimeStyle.of(task.timeOfDay);

    return Container(
      key: ValueKey(task.id),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: hidden ? AppColors.background : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hidden ? AppColors.divider : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: index,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                Icons.drag_handle_rounded,
                color: AppColors.textMuted,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            ScheduleIcons.of(task.iconKey),
            size: 22,
            color: hidden ? AppColors.textMuted : style.accent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.titleTagalog,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: hidden ? AppColors.textMuted : AppColors.textDark,
                    decoration: hidden ? TextDecoration.lineThrough : null,
                    decorationColor: AppColors.textMuted,
                    fontFamily: 'Nunito',
                  ),
                ),
                if (task.timeLabel.isNotEmpty)
                  Text(
                    task.timeLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontFamily: 'Nunito',
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: hidden ? 'Ibalik sa iskedyul' : 'Itago sa iskedyul',
            onPressed: () => _toggleHidden(task),
            icon: Icon(
              hidden
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              size: 20,
              color: hidden ? AppColors.textMuted : AppColors.logoGreen,
            ),
          ),
        ],
      ),
    );
  }
}
