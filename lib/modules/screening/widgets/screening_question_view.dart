import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/step_progress_header.dart';
import 'screening_category.dart';

class ScreeningChoice {
  final String label;
  final Color color;
  final Color textColor;
  final bool isSelected;
  final VoidCallback onPressed;

  const ScreeningChoice({
    required this.label,
    required this.color,
    required this.textColor,
    required this.isSelected,
    required this.onPressed,
  });
}

/// Iisang layout para sa M-CHAT-R at Vanderbilt; ang pagpipilian lang ang naiiba.
class ScreeningQuestionView extends StatelessWidget {
  final int currentIndex;
  final int totalCount;
  final String tagLabel;
  final ScreeningCategory category;
  final String questionText;
  final String questionEnglish;
  final String example;
  final List<ScreeningChoice> choices;
  final VoidCallback onBack;

  const ScreeningQuestionView({
    super.key,
    required this.currentIndex,
    required this.totalCount,
    required this.tagLabel,
    required this.category,
    required this.questionText,
    required this.questionEnglish,
    required this.example,
    required this.choices,
    required this.onBack,
  });

  static const Color _accentBlue = AppColors.accentBlue;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StepProgressHeader(
                currentIndex: currentIndex,
                totalCount: totalCount,
                onBack: onBack,
              ),
              const SizedBox(height: 24),

              Center(
                child: Text(
                  tagLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey.shade600,
                    letterSpacing: 1.0,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Umaakma sa haba ng tanong; kapag mahaba, saka lang mag-i-scroll.
              Flexible(
                child: SingleChildScrollView(
                  child: _buildQuestionCard(context),
                ),
              ),
              const SizedBox(height: 20),

              for (final choice in choices) ...[
                _buildChoiceButton(choice),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.skyBlueLight, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCategoryChip(),
          const SizedBox(height: 18),

          Text(
            questionText,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              height: 1.35,
              fontFamily: 'Nunito',
            ),
          ),
          if (questionEnglish.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              questionEnglish,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.35,
                fontStyle: FontStyle.italic,
                fontFamily: 'Nunito',
              ),
            ),
          ],
          if (example.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildExampleBox(),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: category.color,
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(category.icon, size: 18, color: AppColors.textDark),
          const SizedBox(width: 6),
          Text(
            category.label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.skyBlueLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.home_rounded,
            size: 18,
            color: _accentBlue,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              example,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textDark,
                height: 1.45,
                fontFamily: 'Nunito',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceButton(ScreeningChoice choice) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: choice.color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(
              color: choice.isSelected ? choice.textColor : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        onPressed: choice.onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (choice.isSelected) ...[
              Icon(
                Icons.check_circle_rounded,
                size: 18,
                color: choice.textColor,
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                choice.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: choice.textColor,
                  fontFamily: 'Nunito',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
