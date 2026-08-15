import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/hive_service.dart';
import '../../../widgets/kiko_card.dart';
import '../models/sensory_activity.dart';
import '../services/sensory_recommendation_service.dart';
import '../widgets/activity_detail_sheet.dart';
import '../widgets/checkable_activity_card.dart';
import '../widgets/sensory_progress_banner.dart';
import '../widgets/weekly_date_strip_widget.dart';

class HomeActivitiesScreen extends StatefulWidget {
  const HomeActivitiesScreen({super.key});

  @override
  State<HomeActivitiesScreen> createState() => _HomeActivitiesScreenState();
}

class _HomeActivitiesScreenState extends State<HomeActivitiesScreen> {
  static const Map<String, Color> _domainColors = {
    'proprioceptive': AppColors.mintGreen,
    'vestibular': AppColors.skyBlue,
    'tactile': AppColors.butterYellow,
    'visual': AppColors.skyBlueLight,
    'auditory': AppColors.coralPeach,
  };

  static const Map<String, String> _profileLabels = {
    SensoryRecommendationService.profileSeeking:
        'Para sa Mahilig sa Galaw at Input',
    SensoryRecommendationService.profileAvoiding:
        'Para sa Sensitibo sa Ingay at Hawak',
    SensoryRecommendationService.profileRegulation:
        'Pampakalma at Pag-regulate',
  };

  late DateTime _selectedDate;
  List<SensoryActivity> _daily = [];
  List<SensoryActivity> _all = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _load();
  }

  Future<void> _load() async {
    // Ang pinakahuling sensory result ang batayan; kung wala pa, balanseng pili.
    final results = HiveService.getAllSensoryResults();
    final profile = results.isEmpty
        ? SensoryRecommendationService.profileMixed
        : results.first.primaryProfile;

    try {
      final daily = await SensoryRecommendationService.getDailyRecommendations(
        userProfileResult: profile,
        date: _selectedDate,
      );
      final all = await SensoryRecommendationService.loadAll();
      if (!mounted) return;
      setState(() {
        _daily = daily;
        _all = all;
        _isLoading = false;
      });
    } catch (error) {
      // Kung tatahimik lang ito, blangko ang screen nang walang paliwanag.
      debugPrint('HomeActivitiesScreen: $error');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _onDateSelected(DateTime date) {
    if (date == _selectedDate) return;
    setState(() {
      _selectedDate = date;
      _isLoading = true;
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Activities'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: _hasError ? _buildErrorState() : _buildContent(),
    );
  }

  Widget _buildContent() {
    final completedCount = HiveService.countCompletedOn(
      _selectedDate,
      _daily.map((activity) => activity.id).toList(),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        WeeklyDateStripWidget(
          selectedDate: _selectedDate,
          onDateSelected: _onDateSelected,
        ),
        const SizedBox(height: 18),

        if (_isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator()),
          )
        else ...[
          SensoryProgressBanner(
            completedCount: completedCount,
            totalCount: _daily.length,
          ),
          const SizedBox(height: 20),

          _buildSectionHeader(
            icon: Icons.sports_esports_rounded,
            title: 'Mga Larong Sensory Ngayong Araw',
          ),
          const SizedBox(height: 12),
          for (final activity in _daily) ...[
            CheckableActivityCard(
              activity: activity,
              date: _selectedDate,
              isCompleted:
                  HiveService.isActivityCompleted(_selectedDate, activity.id),
              onToggled: () => setState(() {}),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 14),

          _buildSectionHeader(
            icon: Icons.grid_view_rounded,
            title: 'Lahat ng Gawain',
          ),
          for (final entry in _profileLabels.entries) ...[
            const SizedBox(height: 18),
            Text(
              entry.value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
                letterSpacing: 0.3,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 10),
            for (final activity
                in _all.where((a) => a.targetProfile == entry.key)) ...[
              _buildCatalogueTile(activity),
              const SizedBox(height: 10),
            ],
          ],
        ],
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: KikoCard(
          backgroundColor: AppColors.butterYellow,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFF7A5C00),
                size: 36,
              ),
              const SizedBox(height: 12),
              const Text(
                'Hindi mabuksan ang listahan ng mga gawain.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textDark,
                  fontFamily: 'Nunito',
                ),
              ),
              const SizedBox(height: 8),
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
                  style: TextStyle(
                    color: Color(0xFF7A5C00),
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.mintGreen,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF1E5631), size: 22),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              fontFamily: 'Nunito',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCatalogueTile(SensoryActivity activity) {
    final color = _domainColors[activity.domain] ?? AppColors.skyBlueLight;

    return KikoCard(
      backgroundColor: color,
      padding: const EdgeInsets.all(14),
      onTap: () => ActivityDetailSheet.show(context, activity),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
                  '${activity.estimatedMinutes} mins - ${activity.domainLabel}',
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
