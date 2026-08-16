import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/models/mood_type.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/hive_service.dart';
import '../../widgets/app_branding_header.dart';
import '../../widgets/kiko_card.dart';
import '../mood/screens/mood_log_screen.dart';
import '../profile/profile_screen.dart';
import '../sensory/screens/home_activities_screen.dart';
import 'widgets/behavior_log_card.dart';
import 'widgets/doctor_report_card.dart';
import 'widgets/home_tour_guide.dart';
import 'widgets/milestones_card.dart';
import 'widgets/screening_card.dart';
import 'widgets/sensory_profile_card.dart';
import 'widgets/star_badge_widget.dart';
import 'widgets/visual_schedule_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey _starKey = GlobalKey();
  final GlobalKey _screeningKey = GlobalKey();
  final GlobalKey _navKey = GlobalKey();

  int _selectedNavIndex = 0;
  // `null` ang ibig sabihin ay wala pang sagot ngayong araw.
  String? _selectedMood;

  @override
  void initState() {
    super.initState();
    _selectedMood = HiveService.getMood(DateTime.now());
    WidgetsBinding.instance.addPostFrameCallback((_) => _startTour());
  }

  void _startTour() {
    if (!mounted) return;
    HomeTourGuide.showIfNeeded(context, [
      TourStep(
        targetKey: _starKey,
        title: 'Ang bituin ni Kiko',
        body:
            'Tumataas ito sa bawat larong natapos at milestone na naabot. '
            'Pindutin para makita ang mga mungkahing pabuya sa bata.',
      ),
      TourStep(
        targetKey: _screeningKey,
        title: 'Simulan sa pagsusuri',
        body:
            'Dito matatagpuan ang M-CHAT-R at Vanderbilt. Isang tanong bawat '
            'pahina, may larawan at halimbawa kung paano ito sa bahay.',
      ),
      TourStep(
        targetKey: _navKey,
        title: 'Tatlong pangunahing bahagi',
        body:
            'Bahay para sa buod, Activity para sa mga larong sensory, at '
            'Profile para sa detalye ng bata at sa PIN lock.',
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top App Bar Header
              _buildHeader(),
              const SizedBox(height: 20),

              // 2. Greeting Banner Card (Soft Sky Blue)
              _buildGreetingBanner(),
              const SizedBox(height: 24),

              // 3. Section Title
              const Text(
                'PANGUNAHING MGA GAWAIN',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  fontFamily: 'Nunito',
                ),
              ),
              const SizedBox(height: 14),

              // 4. Two-Column Grid Cards (Screening & Milestones)
              Row(
                children: [
                  Expanded(child: ScreeningCard(key: _screeningKey)),
                  const SizedBox(width: 14),
                  const Expanded(child: MilestonesCard()),
                ],
              ),
              const SizedBox(height: 16),

              // 5. Visual Schedule Full-Width Card
              const VisualScheduleCard(),
              const SizedBox(height: 16),

              // 6. Behavior Log Full-Width Card
              const BehaviorLogCard(),
              const SizedBox(height: 16),

              // 7. Sensory Profile Checklist Card
              const SensoryProfileCard(),
              const SizedBox(height: 16),

              // 8. Progress Report Full-Width Card
              const DoctorReportCard(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      // 6. Bottom Navigation Bar
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Umuurong sa halip na mag-overflow sa makikitid na screen.
        const Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Text(
                  'AuDHD',
                  style: TextStyle(
                    color: AppColors.logoGreen,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Fredoka',
                  ),
                ),
                SizedBox(width: 8),
                AppPhoneticBadge(),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        StarBadgeWidget(key: _starKey),
      ],
    );
  }

  Widget _buildGreetingBanner() {
    return KikoCard(
      backgroundColor: AppColors.skyBlue,
      padding: const EdgeInsets.all(18),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nakikinig sa box para agad magbago kapag naitala o pinalitan ang bata.
              ValueListenableBuilder<Box>(
                valueListenable: HiveService.getProfileBox().listenable(),
                builder: (context, box, child) {
                  final name = HiveService.getChildProfile()?.displayName.trim();
                  final hasName = name != null && name.isNotEmpty;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Magandang\naraw,\n${hasName ? name : 'Magulang'}!',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                          fontFamily: 'Nunito',
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Kumusta ang pakiramdam\n'
                        '${hasName ? 'ni $name' : 'ng iyong anak'} ngayon?',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textDark,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildMoodRow(),
            ],
          ),
          // Positioned Kiko Image on the top right
          Positioned(
            right: -10,
            top: -10,
            child: SizedBox(
              height: 110,
              width: 110,
              child: Image.asset(
                'assets/images/kiko_waving.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openMoodLog() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MoodLogScreen()),
    );
    if (!mounted) return;
    setState(() => _selectedMood = HiveService.getMood(DateTime.now()));
  }

  Widget _buildMoodRow() {
    final stored = _selectedMood;
    final mood = MoodType.fromName(stored);

    return GestureDetector(
      onTap: _openMoodLog,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        child: Row(
          children: [
            Text(
              mood?.emoji ?? '\u{1F4DD}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                stored == null
                    ? 'Itala ang mood ngayong araw'
                    : MoodType.labelFor(stored),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  fontFamily: 'Nunito',
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.textDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      key: _navKey,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home_rounded, 'Bahay'),
          _buildNavItem(1, Icons.sports_esports_rounded, 'Laro'),
          _buildNavItem(2, Icons.person_rounded, 'Profile'),
        ],
      ),
    );
  }

  Future<void> _onNavTap(int index) async {
    setState(() => _selectedNavIndex = index);
    if (index == 0) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => index == 1
            ? const HomeActivitiesScreen()
            : const ProfileScreen(),
      ),
    );

    // Nasa Bahay ang user pagkabalik, kaya doon dapat bumalik ang highlight.
    if (mounted) setState(() => _selectedNavIndex = 0);
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isActive = _selectedNavIndex == index;
    const Color activeColor = AppColors.accentBlue;

    return GestureDetector(
      onTap: () => _onNavTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? activeColor : Colors.grey.shade400,
            size: 26,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? activeColor : Colors.grey.shade500,
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
    );
  }
}