import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/models/schedule_task.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/hive_service.dart';
import '../../../widgets/star_burst_overlay.dart';
import 'schedule_style.dart';

class ScheduleTaskCard extends StatelessWidget {
  final ScheduleTask task;
  final DateTime date;
  final bool isDone;
  final VoidCallback onChanged;

  /// `null` para sa mga default — mga custom lang ang puwedeng burahin.
  final VoidCallback? onOptions;

  const ScheduleTaskCard({
    super.key,
    required this.task,
    required this.date,
    required this.isDone,
    required this.onChanged,
    this.onOptions,
  });

  static const Color _doneTint = AppColors.tintSuccess;
  static const Duration _animation = Duration(milliseconds: 220);

  Future<void> _toggle(BuildContext context) async {
    await HiveService.setScheduleTaskDone(date, task, !isDone);
    if (!isDone) {
      // Pabuya lang sa pagtapos; walang animation kapag inaalis ang tsek.
      unawaited(HapticFeedback.lightImpact());
      if (context.mounted) StarBurstOverlay.show(context, task.starReward);
    }
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final style = ScheduleTimeStyle.of(task.timeOfDay);
    final accent = isDone ? AppColors.logoGreen : style.accent;

    return Semantics(
      button: true,
      checked: isDone,
      label: task.title,
      child: GestureDetector(
        onTap: () => _toggle(context),
        onLongPress: onOptions,
        child: AnimatedContainer(
          duration: _animation,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDone ? _doneTint : style.fill,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: isDone ? AppColors.logoGreen : Colors.transparent,
              width: 2.5,
            ),
          ),
          child: Stack(
            // Kung wala ito, sa topStart napupunta ang Column at kumakaliwa
            // ang mga maiikling pangalan.
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      ScheduleIcons.of(task.iconKey),
                      size: 29,
                      color: accent,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    task.title,
                    textAlign: TextAlign.center,
                    // Tatlo at hindi dalawa: sa tatlong hanay, mga 78dp lang
                    // ang teksto — mga walong letra kada linya.
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.2,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Nunito',
                      color: AppColors.textDark,
                      decoration: isDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  if (task.timeLabel.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      task.timeLabel,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Nunito',
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
              Positioned(
                top: 0,
                right: 0,
                child: AnimatedScale(
                  duration: _animation,
                  curve: Curves.easeOutBack,
                  scale: isDone ? 1 : 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.logoGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: AppColors.surface,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
