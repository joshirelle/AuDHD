import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/kiko_card.dart';
import '../profile/profile_screen.dart';
import '../screening/screens/screening_home_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedNavIndex = 0;
  String _selectedMood = 'Kalmado';

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

              // 4. Two-Column Grid Cards (Screening & Activities)
              Row(
                children: [
                  Expanded(
                    child: _buildGridCard(
                      title: 'PAGSUSURI\n(SCREENING)',
                      subtitle: 'Alamin ang developmental milestone ng bata.',
                      iconData: Icons.fact_check_rounded,
                      backgroundColor: AppColors.mintGreen,
                      iconBgColor: Colors.white,
                      iconColor: AppColors.logoGreen,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ScreeningHomeScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildGridCard(
                      title: 'HOME\nACTIVITIES',
                      subtitle: 'Mga simpleng home therapy at sensory games.',
                      iconData: Icons.extension_rounded,
                      backgroundColor: AppColors.butterYellow,
                      iconBgColor: Colors.white,
                      iconColor: const Color(0xFFD9A000),
                      onTap: () {
                        // Action for Activities
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 5. Progress Report Full-Width Card
              _buildProgressReportCard(),
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
              const Text(
                'Magandang\naraw,\nPamilya Santos!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  fontFamily: 'Nunito',
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Kumusta ang pakiramdam\nni Kiko ngayon?',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textDark,
                  fontFamily: 'Nunito',
                ),
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
    final bool isSelected = _selectedMood == label.split(' ').last;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMood = label.split(' ').last;
        });
      },
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

  Widget _buildGridCard({
    required String title,
    required String subtitle,
    required IconData iconData,
    required Color backgroundColor,
    required Color iconBgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: KikoCard(
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: iconColor, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
                fontFamily: 'Nunito',
                height: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textDark,
                fontFamily: 'Nunito',
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressReportCard() {
    return KikoCard(
      backgroundColor: AppColors.skyBlueLight,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bar_chart_rounded,
              color: Color(0xFF2A80B9),
              size: 32,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PROGRESS REPORT FOR DOCTOR',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    fontFamily: 'Nunito',
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Tingnan at i-export ang summary report para sa DevPed.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textDark,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ),
        ],
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

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isActive = _selectedNavIndex == index;
    final Color activeColor = const Color(0xFF2A80B9);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedNavIndex = index;
        });
        if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        }
      },
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