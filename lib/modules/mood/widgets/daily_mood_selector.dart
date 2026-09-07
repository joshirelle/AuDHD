import 'package:flutter/material.dart';

import '../../../core/i18n/language_controller.dart';
import '../../../core/models/mood_type.dart';
import '../../../core/theme/app_theme.dart';

/// Pagpili ng mood: tono muna, tapos ang mukha.
///
/// Labing-anim na tile sa apat na hanay ay 9px na label — halos hindi mabasa
/// ng magulang na pagod sa gabi, at hindi maituturo ng bata. Tatlong hanay
/// ito ngayon, at ang tono ang nagpapaliit ng listahan nang walang itinatago.
class DailyMoodSelector extends StatefulWidget {
  final MoodType? selected;
  final ValueChanged<MoodType> onSelected;

  const DailyMoodSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<DailyMoodSelector> createState() => _DailyMoodSelectorState();
}

class _DailyMoodSelectorState extends State<DailyMoodSelector> {
  /// `null` = lahat. Sumusunod sa napili na, para hindi maglaho ang tile na
  /// tinitingnan ng magulang pagbalik niya sa screen.
  late MoodTone? _tone = widget.selected?.tone;

  @override
  Widget build(BuildContext context) {
    final moods = MoodType.inTone(_tone);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildToneChip(null),
              for (final tone in MoodTone.values) _buildToneChip(tone),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: 104,
          ),
          itemCount: moods.length,
          itemBuilder: (context, index) => _buildTile(moods[index]),
        ),
      ],
    );
  }

  Widget _buildToneChip(MoodTone? tone) {
    final isSelected = _tone == tone;
    final label = tone?.label ?? tr('Lahat', 'All');

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _tone = tone),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: isSelected
                ? (tone?.ink ?? AppColors.logoGreen)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: Border.all(
              color: isSelected
                  ? (tone?.ink ?? AppColors.logoGreen)
                  : AppColors.divider,
              width: 2,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              fontFamily: 'Nunito',
              color: isSelected ? AppColors.surface : AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTile(MoodType mood) {
    final isSelected = widget.selected == mood;

    return Semantics(
      selected: isSelected,
      button: true,
      label: mood.label,
      child: GestureDetector(
        onTap: () => widget.onSelected(mood),
        child: AnimatedScale(
          scale: isSelected ? 1.04 : 1,
          duration: const Duration(milliseconds: 160),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? mood.tone.fill : AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected ? AppColors.logoGreen : AppColors.divider,
                width: isSelected ? 3 : 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.surface : mood.tone.fill,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(mood.icon, size: 25, color: mood.tone.ink),
                ),
                const SizedBox(height: 7),
                Text(
                  mood.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    height: 1.15,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
