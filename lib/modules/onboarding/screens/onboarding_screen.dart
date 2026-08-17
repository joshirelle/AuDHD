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

  /// Kongkretong magagawa — dito nakikita agad ng magulang ang laman ng app.
  final List<String> highlights;

  const OnboardingSlide({
    required this.icon,
    required this.background,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.highlights,
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
      icon: Icons.volunteer_activism_rounded,
      background: AppColors.mintGreen,
      iconColor: AppColors.logoGreen,
      title: 'Gabay sa\nBahay',
      body:
          'Para sa magulang na gustong gabayan ang anak araw-araw, kahit malayo '
          'o mahal ang therapy center.',
      highlights: [
        'Buo ang gamit kahit walang internet',
        'May paliwanag sa bawat bahagi kung ano ang gagawin',
        'Tulong sa pag-obserba, hindi paraan ng pag-diagnose',
      ],
    ),
    OnboardingSlide(
      icon: Icons.checklist_rounded,
      background: AppColors.butterYellow,
      iconColor: AppColors.butterInk,
      title: 'Iskedyul at\nDamdamin',
      body:
          'Ipaalam sa bata kung ano ang susunod, at itala kung ano ang '
          'nararamdaman niya ngayong araw.',
      highlights: [
        'Visual schedule ng pang-araw-araw na gawain',
        'Magdagdag ka ng sarili mong routine',
        '16 na damdamin, isang tapik lang',
      ],
    ),
    OnboardingSlide(
      icon: Icons.psychology_rounded,
      background: AppColors.skyBlue,
      iconColor: AppColors.skyInk,
      title: 'Sensory at\nUgali',
      body:
          'Alamin kung ano ang nag-uudyok ng meltdown, at kung anong laro ang '
          'nakakatulong sa bata.',
      highlights: [
        'Sensory profile sa 5 uri ng pandama',
        'Mga larong pambahay na may timer',
        'Tala ng insidente gamit ang ABC model',
      ],
    ),
    OnboardingSlide(
      icon: Icons.emoji_events_rounded,
      background: AppColors.coralPeach,
      iconColor: AppColors.coralInk,
      title: 'Milestones\nat Bituin',
      body:
          'Subaybayan ang paglaki, at gawing pabuya sa totoong buhay ang bawat '
          'tagumpay.',
      highlights: [
        'Milestones sa 4 na bahagi ng paglaki',
        'Bituin kada natapos na gawain',
        'Ikaw ang magtatakda ng mga pabuya',
      ],
    ),
    OnboardingSlide(
      icon: Icons.verified_user_rounded,
      background: AppColors.lavender,
      iconColor: AppColors.autismPurple,
      title: 'Ulat at\nPrivacy',
      body:
          'Isang PDF na dala mo sa konsulta — at datos na hindi umaalis sa '
          'telepono mo.',
      highlights: [
        'Kumpletong ulat para sa Developmental Pediatrician',
        'Walang account at walang internet na kailangan',
        'Protektado ng PIN o fingerprint',
      ],
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
              // Nananatili ang puwang para hindi tumalon ang layout sa dulo.
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isLast ? 0 : 1,
                child: TextButton(
                  onPressed: isLast ? null : _finish,
                  child: const Text(
                    'Laktawan',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Nunito',
                    ),
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
    // Mas mahaba na ang laman kaysa dati, kaya kailangang kayang mag-scroll
    // sa maiikling screen.
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 8, 32, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 116,
              height: 116,
              decoration: BoxDecoration(
                color: slide.background,
                shape: BoxShape.circle,
              ),
              child: Icon(slide.icon, size: 52, color: slide.iconColor),
            ),
          ),
          const SizedBox(height: 28),
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
          const SizedBox(height: 12),
          Text(
            slide.body,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textMuted,
              height: 1.5,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 20),
          for (final highlight in slide.highlights) ...[
            _buildHighlight(slide, highlight),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _buildHighlight(OnboardingSlide slide, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 1),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: slide.background,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_rounded,
            size: 13,
            color: slide.iconColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textDark,
              height: 1.4,
              fontWeight: FontWeight.w600,
              fontFamily: 'Nunito',
            ),
          ),
        ),
      ],
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
                  : AppColors.divider,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}
