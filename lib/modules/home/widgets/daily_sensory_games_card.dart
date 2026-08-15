import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/hive_service.dart';
import '../../../widgets/kiko_card.dart';
import '../../sensory/models/sensory_activity.dart';
import '../../sensory/services/sensory_recommendation_service.dart';

class DailySensoryGamesCard extends StatefulWidget {
  const DailySensoryGamesCard({super.key});

  @override
  State<DailySensoryGamesCard> createState() => _DailySensoryGamesCardState();
}

class _DailySensoryGamesCardState extends State<DailySensoryGamesCard> {
  static const Map<String, Color> _domainColors = {
    'proprioceptive': AppColors.mintGreen,
    'vestibular': AppColors.skyBlue,
    'tactile': AppColors.butterYellow,
    'visual': AppColors.skyBlueLight,
    'auditory': AppColors.coralPeach,
  };

  List<SensoryActivity> _activities = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Ang pinakahuling sensory result ang batayan; kung wala pa, balanseng pili.
    final results = HiveService.getAllSensoryResults();
    final profile = results.isEmpty
        ? SensoryRecommendationService.profileMixed
        : results.first.primaryProfile;

    try {
      final picks = await SensoryRecommendationService.getDailyRecommendations(
        userProfileResult: profile,
      );
      if (!mounted) return;
      setState(() {
        _activities = picks;
        _isLoading = false;
      });
    } catch (error) {
      // Kung tatahimik lang ito, mawawala ang card nang walang paliwanag.
      debugPrint('DailySensoryGamesCard: $error');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _openActivity(SensoryActivity activity) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ActivitySheet(activity: activity),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox.shrink();

    if (_hasError) {
      return KikoCard(
        backgroundColor: AppColors.butterYellow,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFF7A5C00)),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Hindi mabuksan ang mga larong sensory ngayon.',
                style: TextStyle(fontSize: 13, color: AppColors.textDark, fontFamily: 'Nunito'),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _hasError = false;
                });
                _load();
              },
              child: const Text(
                'Subukan ulit',
                style: TextStyle(color: Color(0xFF7A5C00), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }

    if (_activities.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.mintGreen,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.sports_esports_rounded,
                color: Color(0xFF1E5631),
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Mga Larong Sensory Ngayong Araw',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  fontFamily: 'Nunito',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final activity in _activities) ...[
          _buildActivityTile(activity),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _buildActivityTile(SensoryActivity activity) {
    final color = _domainColors[activity.domain] ?? AppColors.skyBlueLight;

    return KikoCard(
      backgroundColor: color,
      padding: const EdgeInsets.all(14),
      onTap: () => _openActivity(activity),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.logoGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.titleTagalog,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    fontFamily: 'Nunito',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${activity.durationLabel}  •  ${activity.domainLabel}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textDark,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textDark),
        ],
      ),
    );
  }
}

class _ActivitySheet extends StatelessWidget {
  final SensoryActivity activity;

  const _ActivitySheet({required this.activity});

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
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${activity.durationLabel}  •  ${activity.domainLabel}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              Text(
                activity.descriptionTagalog,
                style: const TextStyle(fontSize: 14, color: AppColors.textDark, height: 1.4),
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
                            const Text('•  ', style: TextStyle(fontSize: 14, color: AppColors.textDark)),
                            Expanded(
                              child: Text(
                                material,
                                style: const TextStyle(fontSize: 13, color: AppColors.textDark, height: 1.35),
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
                            color: Color(0xFF1E5631),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          activity.stepByStepTagalog[i],
                          style: const TextStyle(fontSize: 14, color: AppColors.textDark, height: 1.4),
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
                    const Icon(Icons.warning_amber_rounded, color: Color(0xFF8A2B12), size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        activity.safetyNoteTagalog,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8A2B12),
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
    );
  }
}
