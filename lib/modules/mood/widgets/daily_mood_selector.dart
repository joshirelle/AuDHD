import 'package:flutter/material.dart';
import '../../../core/models/mood_type.dart';
import '../../../core/theme/app_theme.dart';

class DailyMoodSelector extends StatelessWidget {
  final MoodType? selected;
  final ValueChanged<MoodType> onSelected;

  const DailyMoodSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  static const Map<MoodTone, Color> _toneColors = {
    MoodTone.positive: AppColors.mintGreen,
    MoodTone.neutral: AppColors.skyBlueLight,
    MoodTone.negative: AppColors.coralPeach,
  };

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.82,
      ),
      itemCount: MoodType.values.length,
      itemBuilder: (context, index) => _buildTile(MoodType.values[index]),
    );
  }

  Widget _buildTile(MoodType mood) {
    final isSelected = selected == mood;
    final tone = _toneColors[mood.tone]!;

    return GestureDetector(
      onTap: () => onSelected(mood),
      child: AnimatedScale(
        scale: isSelected ? 1.06 : 1,
        duration: const Duration(milliseconds: 160),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? tone : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.logoGreen : Colors.grey.shade300,
              width: isSelected ? 3 : 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFace(mood),
              const SizedBox(height: 6),
              Text(
                mood.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFace(MoodType mood) {
    // Emoji ang laging gamit; papalitan lang kapag may naidagdag na larawan.
    return Image.asset(
      mood.assetPath,
      width: 30,
      height: 30,
      errorBuilder: (context, error, stackTrace) =>
          Text(mood.emoji, style: const TextStyle(fontSize: 26)),
    );
  }
}
