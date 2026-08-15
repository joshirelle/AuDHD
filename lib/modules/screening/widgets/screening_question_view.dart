import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/step_progress_header.dart';

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
  final String imageAsset;
  final String questionText;
  final String example;
  final List<ScreeningChoice> choices;
  final VoidCallback onBack;

  const ScreeningQuestionView({
    super.key,
    required this.currentIndex,
    required this.totalCount,
    required this.tagLabel,
    required this.imageAsset,
    required this.questionText,
    required this.example,
    required this.choices,
    required this.onBack,
  });

  static const Color _accentBlue = Color(0xFF2A80B9);

  void _showExampleDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.help_outline_rounded, color: AppColors.logoGreen),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Paano ito sa bahay?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          example,
          style: const TextStyle(fontSize: 14, fontFamily: 'Nunito'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Nakuha ko!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.logoGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

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

              Expanded(child: _buildQuestionCard(context)),
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
        children: [
          Expanded(
            flex: 5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                imageAsset,
                fit: BoxFit.contain,
                // Bumabalik sa default kapag wala pang larawan ang tanong.
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/images/kiko_pointing.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Umaangkop kapag mahaba ang tanong sa halip na mag-overflow.
          Flexible(
            flex: 6,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    questionText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                      height: 1.3,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  if (example.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.skyBlue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () => _showExampleDialog(context),
                      icon: const Icon(
                        Icons.help_outline_rounded,
                        size: 18,
                        color: _accentBlue,
                      ),
                      label: const Text(
                        'Paano ito sa bahay?',
                        style: TextStyle(
                          color: _accentBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ),
                  ],
                ],
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
