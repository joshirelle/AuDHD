import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/enums/skill_area.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/hive_service.dart';
import '../../../widgets/how_to_card.dart';
import '../../../widgets/kiko_card.dart';
import '../../../widgets/weekly_date_strip.dart';
import '../../home/widgets/star_badge_widget.dart';
import '../models/sensory_activity.dart';
import '../services/sensory_recommendation_service.dart';
import '../widgets/checkable_activity_card.dart';
import '../widgets/sensory_progress_banner.dart';
import '../widgets/skill_area_info_sheet.dart';

class HomeActivitiesScreen extends StatefulWidget {
  const HomeActivitiesScreen({super.key});

  @override
  State<HomeActivitiesScreen> createState() => _HomeActivitiesScreenState();
}

class _HomeActivitiesScreenState extends State<HomeActivitiesScreen> {
  /// `null` ang ibig sabihin ay "Lahat".
  SkillArea? _skillFilter;

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
        title: const Text('Mga Gawain sa Bahay'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(child: StarBadgeWidget()),
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: _hasError
          ? _buildErrorState()
          : ValueListenableBuilder<Box<bool>>(
              // Kung hindi ito nakikinig, luma ang tsek pagbalik mula sa timer.
              valueListenable: HiveService.getCompletionBox().listenable(),
              builder: (context, box, _) => _buildContent(),
            ),
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
        const HowToCard(
          steps: [
            'Pindutin ang gawain para mabasa ang paliwanag at ang paalala sa '
                'kaligtasan bago kayo magsimula.',
            'May timer ang bawat gawain, kaya hindi mo na kailangang bantayan '
                'ang oras. Samahan mo lang ang bata.',
            'Kapag tapos na, matsetsek ito at may bituing madadagdag sa bata.',
          ],
          footnote:
              'Hindi kailangang matapos lahat sa isang araw. Mas malaki ang '
              'naitutulong ng maikli pero tuloy-tuloy kaysa sa mahaba pero '
              'paminsan-minsan.',
        ),
        const SizedBox(height: 16),

        WeeklyDateStrip(
          selectedDate: _selectedDate,
          onDateSelected: _onDateSelected,
          progressSource: HiveService.getCompletionBox().listenable(),
          hasProgress: HiveService.hasAnyCompletionOn,
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
            title: 'Mga Gawain Ngayong Araw',
            durationLabel: _remainingLabel(_daily),
          ),
          const SizedBox(height: 12),
          for (final activity in _daily) ...[
            _buildActivityCard(activity),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 14),

          _buildSectionHeader(
            icon: Icons.grid_view_rounded,
            title: 'Lahat ng Gawain',
            durationLabel: _remainingLabel(_filteredActivities()),
          ),
          const SizedBox(height: 12),
          _buildSkillFilterHeader(),
          const SizedBox(height: 10),
          _buildSkillFilters(),
          const SizedBox(height: 14),
          for (final activity in _filteredActivities()) ...[
            _buildActivityCard(activity),
            const SizedBox(height: 10),
          ],
        ],
      ],
    );
  }

  List<SensoryActivity> _filteredActivities() => _skillFilter == null
      ? _all
      : _all.where((a) => a.skillArea == _skillFilter).toList();

  Widget _buildActivityCard(SensoryActivity activity) {
    return CheckableActivityCard(
      activity: activity,
      date: _selectedDate,
      isCompleted: HiveService.isActivityCompleted(_selectedDate, activity.id),
      onToggled: () => setState(() {}),
    );
  }

  Widget _buildSkillFilterHeader() {
    return Row(
      children: [
        const Text(
          'Anong Natututuhan?',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
            fontFamily: 'Nunito',
          ),
        ),
        const SizedBox(width: 4),
        InkWell(
          onTap: () => showSkillAreaInfoSheet(context),
          borderRadius: BorderRadius.circular(20),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(
              Icons.info_outline_rounded,
              size: 18,
              color: AppColors.accentBlue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterChip('Lahat', null, Icons.apps_rounded, AppColors.logoGreen),
          for (final area in SkillArea.values) ...[
            const SizedBox(width: 8),
            _buildFilterChip(area.label, area, area.icon, area.ink),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    SkillArea? area,
    IconData icon,
    Color color,
  ) {
    final isSelected = _skillFilter == area;

    return GestureDetector(
      onTap: () => setState(() => _skillFilter = area),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.button),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textDark,
                fontFamily: 'Nunito',
              ),
            ),
          ],
        ),
      ),
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
                color: AppColors.butterInk,
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
                    color: AppColors.butterInk,
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

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    String? durationLabel,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.mintGreen,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.mintInk, size: 22),
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
        if (durationLabel != null) _buildDurationPill(durationLabel),
      ],
    );
  }

  Widget _buildDurationPill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.tintTeal,
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.schedule_rounded,
            size: 13,
            color: AppColors.skyInk,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.skyInk,
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
    );
  }

  int _totalMinutes(List<SensoryActivity> activities) =>
      activities.fold(0, (sum, a) => sum + a.estimatedMinutes);

  /// Ang tanong ng magulang ay hindi "gaano katagal lahat" kundi "gaano pa
  /// katagal bago kami matapos", kaya ang natitira ang ipinapakita.
  String _remainingLabel(List<SensoryActivity> activities) {
    final remaining = activities
        .where((a) => !HiveService.isActivityCompleted(_selectedDate, a.id))
        .toList();

    if (remaining.isEmpty) return 'Tapos na';
    return '${_formatMinutes(_totalMinutes(remaining))} pa';
  }

  String _formatMinutes(int minutes) {
    if (minutes < 60) return '$minutes minuto';

    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    return rest == 0 ? '$hours oras' : '$hours oras $rest min';
  }
}
