import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/kiko_card.dart';
import '../models/sensory_activity.dart';
import '../screens/activity_timer_screen.dart';

class ActivityDetailSheet extends StatelessWidget {
  final SensoryActivity activity;
  final DateTime date;

  const ActivityDetailSheet({
    super.key,
    required this.activity,
    required this.date,
  });

  static Future<void> show(
    BuildContext context,
    SensoryActivity activity,
    DateTime date,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          ActivityDetailSheet(activity: activity, date: date),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                activity.titleTagalog,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  fontFamily: 'Nunito',
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${activity.durationLabel} - ${activity.domainLabel}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontFamily: 'Nunito',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                activity.descriptionTagalog,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textDark,
                  height: 1.4,
                  fontFamily: 'Nunito',
                ),
              ),
              const SizedBox(height: 24),

              _sectionTitle('Mga Kakailanganin'),
              const SizedBox(height: 10),
              KikoCard(
                backgroundColor: AppColors.skyBlueLight,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final material in activity.materialsNeeded)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '\u2022  ',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textDark,
                                fontFamily: 'Nunito',
                              ),
                            ),
                            Expanded(
                              child: Text(
                                material,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textDark,
                                  height: 1.35,
                                  fontFamily: 'Nunito',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _sectionTitle('Hakbang-Hakbang'),
              const SizedBox(height: 10),
              for (int i = 0; i < activity.stepByStepTagalog.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.mintGreen,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.mintInk,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          activity.stepByStepTagalog[i],
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textDark,
                            height: 1.4,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),

              _sectionTitle('Paalala sa Kaligtasan'),
              const SizedBox(height: 10),
              KikoCard(
                backgroundColor: AppColors.coralPeach,
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.coralInk,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        activity.safetyNoteTagalog,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.coralInk,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => _startTimer(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.logoGreen,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.button),
                    ),
                  ),
                  icon: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                  label: Text(
                    'Simulan (${activity.estimatedMinutes} min)',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _startTimer(BuildContext context) {
    // Kinukuha bago mag-pop dahil hindi na magagamit ang context pagkatapos.
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.push(
      MaterialPageRoute(
        builder: (context) =>
            ActivityTimerScreen(activity: activity, date: date),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
        fontFamily: 'Nunito',
      ),
    );
  }
}
