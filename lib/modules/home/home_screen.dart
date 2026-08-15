import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/hive_service.dart';
import '../../widgets/kiko_card.dart';
import '../profile/profile_screen.dart';
import '../sensory/screens/home_activities_screen.dart';
import 'widgets/behavior_log_card.dart';
import 'widgets/doctor_report_card.dart';
import 'widgets/milestones_card.dart';
import 'widgets/screening_card.dart';
import 'widgets/sensory_profile_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedNavIndex = 0;
  // `null` ang ibig sabihin ay wala pang sagot ngayong araw.
  String? _selectedMood;

  @override
  void initState() {
    super.initState();
    _selectedMood = HiveService.getMood(DateTime.now());
  }

  Future<void> _selectMood(String mood) async {
    await HiveService.saveMood(DateTime.now(), mood);
    if (!mounted) return;
    setState(() => _selectedMood = mood);
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
              const Row(
                children: [
                  Expanded(child: ScreeningCard()),
                  SizedBox(width: 14),
                  Expanded(child: MilestonesCard()),
                ],
              ),
              const SizedBox(height: 16),

              // 5. Behavior Log Full-Width Card
              const BehaviorLogCard(),
              const SizedBox(height: 16),

              // 6. Sensory Profile Checklist Card
              const SensoryProfileCard(),
              const SizedBox(height: 16),

              // 7. Progress Report Full-Width Card
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
        const Text(
          'AuDHD',
          style: TextStyle(
            color: AppColors.logoGreen,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'Fredoka',
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.skyBlueLight,
                border: Border.all(color: Colors.white, width: 2),
                image: const DecorationImage(
                  image: AssetImage('assets/images/kiko_waving.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Kiko',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
                fontFamily: 'Nunito',
              ),
            ),
          ],
        ),
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
                  final name = HiveService.getChildProfile()?.name.trim();
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
              // Mood Chips Row
              Row(
                children: [
                  _buildMoodChip('🟢 Kalmado'),
                  const SizedBox(width: 6),
                  _buildMoodChip('🟡 Masigla'),
                  const SizedBox(width: 6),
                  _buildMoodChip('🔵 Pagod'),
                ],
              ),
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

  Widget _buildMoodChip(String label) {
    final mood = label.split(' ').last;
    final bool isSelected = _selectedMood == mood;
    return GestureDetector(
      onTap: () => _selectMood(mood),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.textDark : Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppColors.textDark,
            fontFamily: 'Nunito',
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
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
          _buildNavItem(1, Icons.star_rounded, 'Activity'),
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
    final Color activeColor = const Color(0xFF2A80B9);

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