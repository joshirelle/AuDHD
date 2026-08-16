import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/hive_service.dart';
import '../../../widgets/app_branding_header.dart';

class OnboardingSlide {
  final IconData icon;
  final Color background;
  final Color iconColor;
  final String title;
  final String body;

  const OnboardingSlide({
    required this.icon,
    required this.background,
    required this.iconColor,
    required this.title,
    required this.body,
  });
}

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinished;

  const OnboardingScreen({super.key, required this.onFinished});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const List<OnboardingSlide> _slides = [
    OnboardingSlide(
      icon: Icons.flag_rounded,
      background: AppColors.butterYellow,
      iconColor: Color(0xFFD9A000),
      title: 'Developmental\nMilestones',
      body:
          'Subaybayan ang paglaki ng bata sa 4 na domains (Motor, Speech, Social) '
          'mula sa bahay.',
    ),
    OnboardingSlide(
      icon: Icons.fact_check_rounded,
      background: AppColors.mintGreen,
      iconColor: AppColors.logoGreen,
      title: 'Clinical\nScreening',
      body:
          'M-CHAT-R para sa Autism at Vanderbilt para sa ADHD — handa para sa '
          'doktor.',
    ),
    OnboardingSlide(
      icon: Icons.psychology_rounded,
      background: AppColors.skyBlue,
      iconColor: Color(0xFF16537E),
      title: 'Behavior at\nSensory Engine',
      body:
          'Pang-araw-araw na tala ng mood, sensory games, at triggers gamit ang '
          'ABC model.',
    ),
    OnboardingSlide(
      icon: Icons.picture_as_pdf_rounded,
      background: AppColors.coralPeach,
      iconColor: Color(0xFF8A2B12),
      title: '360° Doctor PDF\nat Star Points',
      body:
          'I-export ang kumpletong ulat para sa DevPed at magbigay ng Star Points '
          'bilang pabuya.',
    ),
  ];

  final PageController _controller = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await HiveService.markSeen(HiveService.hasSeenOnboardingKey);
    widget.onFinished();
  }

  void _next() {
    if (_currentIndex == _slides.length - 1) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentIndex == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: AppBrandingHeader(),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: isLast ? null : _finish,
                child: Text(
                  isLast ? '' : 'Laktawan',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (index) =>
                    setState(() => _currentIndex = index),
                itemBuilder: (context, index) => _buildSlide(_slides[index]),
              ),
            ),
            const SizedBox(height: 12),
            _buildIndicators(),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                height: 54,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.logoGreen,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.button),
                    ),
                  ),
                  child: Text(
                    isLast ? 'Magsimula Na' : 'Susunod',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(OnboardingSlide slide) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 148,
              height: 148,
              decoration: BoxDecoration(
                color: slide.background,
                shape: BoxShape.circle,
              ),
              child: Icon(slide.icon, size: 64, color: slide.iconColor),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            slide.title,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              height: 1.25,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 14),
          Text(
            slide.body,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < _slides.length; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == _currentIndex ? 22 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == _currentIndex
                  ? AppColors.logoGreen
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}
