import 'package:flutter/material.dart';
import '../../../core/i18n/language_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/hive_service.dart';
import '../../../widgets/app_branding_header.dart';
import '../../../widgets/community_link.dart';
import '../../../widgets/language_chips.dart';
import '../../../widgets/medical_disclaimer_sheet.dart';
import '../../home/widgets/thank_you_sheet.dart';
import '../../home/widgets/whats_new_sheet.dart';

class OnboardingSlide {
  final IconData icon;
  final Color background;
  final Color iconColor;
  final String _titleFil;
  final String _titleEng;
  final String _bodyFil;
  final String _bodyEng;

  /// Kongkretong magagawa — dito nakikita agad ng magulang ang laman ng app.
  final List<String> _highlightsFil;
  final List<String> _highlightsEng;

  const OnboardingSlide({
    required this.icon,
    required this.background,
    required this.iconColor,
    required String titleFil,
    required String titleEng,
    required String bodyFil,
    required String bodyEng,
    required List<String> highlightsFil,
    required List<String> highlightsEng,
  }) : _titleFil = titleFil,
       _titleEng = titleEng,
       _bodyFil = bodyFil,
       _bodyEng = bodyEng,
       _highlightsFil = highlightsFil,
       _highlightsEng = highlightsEng;

  String get title => tr(_titleFil, _titleEng);

  String get body => tr(_bodyFil, _bodyEng);

  List<String> get highlights =>
      LanguageController.isEnglish ? _highlightsEng : _highlightsFil;
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
      titleFil: 'Gabay sa\nBahay',
      titleEng: 'Support at\nHome',
      bodyFil:
          'Para sa magulang na gustong gabayan ang anak araw-araw, kahit malayo '
          'o mahal ang therapy center.',
      bodyEng:
          'For parents who want to guide their child every day, even when a '
          'therapy center is far away or costly.',
      highlightsFil: [
        'Buo ang gamit kahit walang internet',
        'May paliwanag sa bawat bahagi kung ano ang gagawin',
        'Tulong sa pag-obserba, hindi paraan ng pag-diagnose',
      ],
      highlightsEng: [
        'Everything works without internet',
        'Every section explains what to do',
        'A way to observe, not a way to diagnose',
      ],
    ),
    OnboardingSlide(
      icon: Icons.checklist_rounded,
      background: AppColors.butterYellow,
      iconColor: AppColors.butterInk,
      titleFil: 'Iskedyul at\nDamdamin',
      titleEng: 'Schedule and\nFeelings',
      bodyFil:
          'Ipaalam sa bata kung ano ang susunod, at itala kung ano ang '
          'nararamdaman niya ngayong araw.',
      bodyEng:
          'Show your child what comes next, and record how they feel today.',
      highlightsFil: [
        'Visual schedule ng pang-araw-araw na gawain',
        'Magdagdag ka ng sarili mong routine',
        '16 na damdamin, isang tapik lang',
      ],
      highlightsEng: [
        'A visual schedule for daily routines',
        'Add your own routines',
        '16 feelings, one tap away',
      ],
    ),
    OnboardingSlide(
      icon: Icons.psychology_rounded,
      background: AppColors.skyBlue,
      iconColor: AppColors.skyInk,
      titleFil: 'Sensory at\nUgali',
      titleEng: 'Sensory and\nBehavior',
      bodyFil:
          'Alamin kung ano ang nag-uudyok ng meltdown, at kung anong laro ang '
          'nakakatulong sa bata.',
      bodyEng:
          'Find out what sets off a meltdown, and which activities help your '
          'child.',
      highlightsFil: [
        'Sensory profile sa 5 uri ng pandama',
        'Mga larong pambahay na may timer',
        'Tala ng insidente gamit ang ABC model',
      ],
      highlightsEng: [
        'A sensory profile across 5 senses',
        'Home activities with a timer',
        'Incident notes using the ABC model',
      ],
    ),
    OnboardingSlide(
      icon: Icons.emoji_events_rounded,
      background: AppColors.coralPeach,
      iconColor: AppColors.coralInk,
      titleFil: 'Milestones\nat Bituin',
      titleEng: 'Milestones\nand Stars',
      bodyFil:
          'Subaybayan ang paglaki, at gawing pabuya sa totoong buhay ang bawat '
          'tagumpay.',
      bodyEng:
          'Track how your child grows, and turn each win into a real-life '
          'reward.',
      highlightsFil: [
        'Milestones sa 4 na bahagi ng paglaki',
        'Bituin kada natapos na gawain',
        'Ikaw ang magtatakda ng mga pabuya',
      ],
      highlightsEng: [
        'Milestones across 4 areas of development',
        'A star for every finished task',
        'You decide the rewards',
      ],
    ),
    OnboardingSlide(
      icon: Icons.verified_user_rounded,
      background: AppColors.lavender,
      iconColor: AppColors.autismPurple,
      titleFil: 'Ulat at\nPrivacy',
      titleEng: 'Reports and\nPrivacy',
      bodyFil:
          'Isang PDF na dala mo sa konsulta — at datos na hindi umaalis sa '
          'telepono mo.',
      bodyEng:
          'One PDF to bring to the consultation — and data that never leaves '
          'your phone.',
      highlightsFil: [
        'Kumpletong ulat para sa Developmental Pediatrician',
        'Walang account at walang internet na kailangan',
        'Protektado ng PIN o fingerprint',
      ],
      highlightsEng: [
        'A complete report for the Developmental Pediatrician',
        'No account and no internet needed',
        'Protected by PIN or fingerprint',
      ],
    ),
  ];

  final PageController _controller = PageController();
  int _currentIndex = 0;

  /// Ang paalalang pangkalusugan ang huling pahina, kaya isa itong dagdag sa
  /// bilang ng slide.
  int get _pageCount => _slides.length + 1;

  bool get _isDisclaimerPage => _currentIndex == _pageCount - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await HiveService.markSeen(HiveService.hasSeenOnboardingKey);
    await HiveService.markSeen(MedicalDisclaimerSheet.seenKey);
    // Bago sa kanya ang lahat, kaya walang saysay ang "ano ang bago" at ang
    // pasasalamat sa matagal nang gumagamit. Ang tour lang ang makikita niya.
    await HiveService.markSeen(WhatsNewSheet.seenKey);
    await HiveService.markSeen(ThankYouSheet.seenKey);
    widget.onFinished();
  }

  /// Nilalaktawan ang paglilibot sa mga tampok, hindi ang paalala.
  void _skipToDisclaimer() {
    _controller.animateToPage(
      _pageCount - 1,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOut,
    );
  }

  void _next() {
    if (_isDisclaimerPage) {
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
    final isLast = _isDisclaimerPage;

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
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Hindi kumukupas sa dulo tulad ng "Laktawan": ang huling
                  // pahina ay ang paalalang pangkalusugan, at iyon ang
                  // pinakadapat mabasa sa sariling wika.
                  const LanguageChips(),
                  // Nananatili ang puwang para hindi tumalon ang layout sa
                  // dulo.
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: isLast ? 0 : 1,
                    child: TextButton(
                      onPressed: isLast ? null : _skipToDisclaimer,
                      child: Text(
                        tr('Laktawan', 'Skip'),
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pageCount,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemBuilder: (context, index) => index == _slides.length
                    ? _buildDisclaimerPage()
                    : _buildSlide(
                        _slides[index],
                        // Huling slide ng tampok, hindi ang huling pahina —
                        // dito pa rin dapat lumabas ang imbitasyon sa grupo.
                        isLast: index == _slides.length - 1,
                      ),
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
                    isLast
                        ? MedicalDisclaimerSheet.acknowledgeLabel
                        : tr('Susunod', 'Next'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.surface,
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

  Widget _buildSlide(OnboardingSlide slide, {required bool isLast}) {
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
          // Sa dulo lang: bago nito, hindi pa alam ng magulang kung para saan
          // ang app na sasalihan niya ang grupo.
          if (isLast) ...[const SizedBox(height: 12), _buildCommunityInvite()],
        ],
      ),
    );
  }

  Widget _buildCommunityInvite() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.tintWarm,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.groups_rounded,
                size: 20,
                color: AppColors.coralInk,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  tr(
                    'Hindi ka nag-iisa — may grupo ng mga magulang na dumaraan '
                        'din dito.',
                    'You are not alone — there is a group of parents going '
                        'through this too.',
                  ),
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: AppColors.textDark,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => openAudhdGroup(context),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.coralInk,
                padding: EdgeInsets.zero,
              ),
              icon: const Icon(Icons.open_in_new_rounded, size: 15),
              label: Text(
                tr('Tingnan ang grupo', 'Visit the group'),
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Nunito',
                ),
              ),
            ),
          ),
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
          child: Icon(Icons.check_rounded, size: 13, color: slide.iconColor),
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

  Widget _buildDisclaimerPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [MedicalDisclaimerBody()],
      ),
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < _pageCount; i++)
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
