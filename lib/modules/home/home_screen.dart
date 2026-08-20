import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/i18n/language_controller.dart';
import '../../core/models/mood_type.dart';
import '../../core/services/update_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/hive_service.dart';
import '../../widgets/app_branding_header.dart';
import '../../widgets/kiko_card.dart';
import '../mood/screens/mood_log_screen.dart';
import '../profile/profile_screen.dart';
import '../sensory/screens/home_activities_screen.dart';
import 'widgets/behavior_log_card.dart';
import 'widgets/doctor_report_card.dart';
import 'widgets/home_activities_card.dart';
import 'widgets/home_tour_guide.dart';
import 'widgets/knowledge_card.dart';
import 'widgets/milestones_card.dart';
import 'widgets/quick_links_row.dart';
import 'widgets/sensory_profile_card.dart';
import 'widgets/star_badge_widget.dart';
import 'widgets/thank_you_sheet.dart';
import 'widgets/visual_schedule_card.dart';
import 'widgets/whats_new_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey _starKey = GlobalKey();
  final GlobalKey _quickLinksKey = GlobalKey();
  final GlobalKey _activitiesKey = GlobalKey();
  final GlobalKey _navKey = GlobalKey();

  int _selectedNavIndex = 0;
  // `null` ang ibig sabihin ay wala pang sagot ngayong araw.
  String? _selectedMood;

  @override
  void initState() {
    super.initState();
    _selectedMood = HiveService.getMood(DateTime.now());
    WidgetsBinding.instance.addPostFrameCallback((_) => _startIntro());
  }

  /// Ang tour ay para sa bagong user, ang "ano ang bago" ay para sa lumang
  /// user — magkabukod ang kondisyon, kaya hindi sila magsasabay.
  Future<void> _startIntro() async {
    if (!mounted) return;
    _startTour();
    await WhatsNewSheet.showIfNeeded(context);

    if (!mounted) return;
    await ThankYouSheet.showIfNeeded(context);

    // Panghuli para hindi makasabay ang SnackBar sa tour o sa "ano ang bago".
    if (!mounted) return;
    await UpdateService.checkAndPrompt(context);
  }

  void _startTour() {
    HomeTourGuide.showIfNeeded(context, [
      TourStep(
        targetKey: _starKey,
        title: tr('Ang bituin ni Kiko', "Kiko's stars"),
        body: tr(
          'Tumataas ito sa bawat larong natapos at milestone na naabot. '
          'Pindutin para makita ang mga mungkahing pabuya sa bata.',
          'This goes up with every activity finished and milestone reached. '
          'Tap it to see the rewards you have set for your child.',
        ),
      ),
      TourStep(
        targetKey: _quickLinksKey,
        title: tr('Tatlong maiikling pindutan', 'Three quick buttons'),
        body: tr(
          'Ang Bago ay kung ano ang naidagdag sa app. Ang Grupo ay ang '
          'Facebook ng mga magulang. Ang I-rate ay bubukas sa Play Store.',
          'New shows what was added to the app. Group opens the parents\' '
          'Facebook. Rate opens the Play Store.',
        ),
      ),
      TourStep(
        targetKey: _activitiesKey,
        title: tr('Mga gawain sa bahay', 'Home activities'),
        body: tr(
          'Dito ang mga larong pansensory na kayang gawin araw-araw. May '
          'timer ang bawat isa at may paliwanag kung paano ito ginagawa.',
          'Sensory activities you can do at home every day. Each one has a '
          'timer and step-by-step instructions.',
        ),
      ),
      TourStep(
        targetKey: _navKey,
        title: tr('Tatlong pangunahing bahagi', 'Three main sections'),
        body: tr(
          'Bahay para sa buod, Laro para sa mga gawain sa bahay, at Profile '
          'para sa detalye ng bata at sa PIN lock.',
          'Home for the summary, Activities for things to do at home, and '
          'Profile for your child\'s details and the PIN lock.',
        ),
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
              const SizedBox(height: 14),

              // 2. Tatlong maiikling pindutan sa ilalim ng bituin
              QuickLinksRow(key: _quickLinksKey),
              const SizedBox(height: 20),

              // 3. Greeting Banner Card (Soft Sky Blue)
              _buildGreetingBanner(),
              const SizedBox(height: 24),

              // 4. Section Title
              Text(
                tr('PANGUNAHING MGA GAWAIN', 'MAIN SECTIONS'),
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  fontFamily: 'Nunito',
                ),
              ),
              const SizedBox(height: 14),

              // 4. Two-Column Grid Cards (Home Activities & Milestones)
              // Pinapantay ang taas ng dalawang card para walang puwang sa gilid.
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: HomeActivitiesCard(key: _activitiesKey)),
                    const SizedBox(width: 14),
                    const Expanded(child: MilestonesCard()),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 5. Gabay sa Pag-unawa Full-Width Card
              const KnowledgeCard(),
              const SizedBox(height: 16),

              // 6. Visual Schedule Full-Width Card
              const VisualScheduleCard(),
              const SizedBox(height: 16),

              // 7. Behavior Log Full-Width Card
              const BehaviorLogCard(),
              const SizedBox(height: 16),

              // 8. Sensory Profile Checklist Card
              const SensoryProfileCard(),
              const SizedBox(height: 16),

              // 9. Progress Report Full-Width Card
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
                        tr(
                          'Magandang\naraw,\n${hasName ? name : 'Magulang'}!',
                          'Welcome back,\n${hasName ? name : 'Parent'}!',
                        ),
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
                        tr(
                          'Kumusta ang pakiramdam\n'
                          '${hasName ? 'ni $name' : 'ng iyong anak'} ngayon?',
                          'Let us see how '
                          '${hasName ? name : 'your child'} is doing today.',
                        ),
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
          color: AppColors.surface,
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
                    ? tr('Itala ang mood ngayong araw', "Log today's mood")
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
        color: AppColors.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home_rounded, tr('Bahay', 'Home')),
          _buildNavItem(1, Icons.sports_esports_rounded, tr('Laro', 'Play')),
          _buildNavItem(2, Icons.person_rounded, tr('Profile', 'Profile')),
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
            color: isActive ? activeColor : AppColors.textMuted,
            size: 26,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? activeColor : AppColors.textMuted,
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
    );
  }
}