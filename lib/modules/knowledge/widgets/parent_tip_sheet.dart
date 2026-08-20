import 'package:flutter/material.dart';

import '../../../core/i18n/language_controller.dart';
import '../../../core/models/guide_card.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/hive_service.dart';

Future<void> showParentTipSheet(BuildContext context, GuideCard card) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => ParentTipSheet(card: card),
  );
}

class ParentTipSheet extends StatefulWidget {
  const ParentTipSheet({super.key, required this.card});

  final GuideCard card;

  @override
  State<ParentTipSheet> createState() => _ParentTipSheetState();
}

class _ParentTipSheetState extends State<ParentTipSheet> {
  late bool _bookmarked = HiveService.isGuideBookmarked(widget.card.id);

  Future<void> _toggleBookmark() async {
    final next = !_bookmarked;
    await HiveService.setGuideBookmarked(widget.card.id, next);
    if (!mounted) return;
    setState(() => _bookmarked = next);
  }

  Future<void> _toggleTip(int index) async {
    final next = !HiveService.isGuideTipDone(widget.card.id, index);
    await HiveService.setGuideTipDone(widget.card.id, index, next);
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    final category = card.category;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: category.background,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(card.icon, color: category.ink, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                          fontFamily: 'Nunito',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        category.label,
                        style: TextStyle(
                          fontSize: 12,
                          color: category.ink,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _toggleBookmark,
                  tooltip: _bookmarked
                      ? tr('Alisin sa naka-save', 'Remove from saved')
                      : tr('I-save', 'Save'),
                  icon: Icon(
                    _bookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: _bookmarked ? AppColors.starGold : AppColors.textMuted,
                    size: 26,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              card.description,
              style: const TextStyle(
                fontSize: 14,
                height: 1.55,
                color: AppColors.textDark,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: category.background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '"${card.quote}"',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  color: category.ink,
                  fontFamily: 'Nunito',
                ),
              ),
            ),
            const SizedBox(height: 26),
            Text(
              tr(
                'Ano ang pwedeng gawin ng magulang?',
                'What can a parent try?',
              ),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              tr(
                'Walang tama o mali dito. Piliin ang kaya mong subukan.',
                'There is no right or wrong here. Pick what you can try.',
              ),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < card.actionTips.length; i++)
              _TipRow(
                text: card.actionTips[i],
                done: HiveService.isGuideTipDone(card.id, i),
                accent: category.ink,
                onTap: () => _toggleTip(i),
              ),
          ],
        ),
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow({
    required this.text,
    required this.done,
    required this.accent,
    required this.onTap,
  });

  final String text;
  final bool done;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              done ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: done ? accent : AppColors.divider,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: done ? AppColors.textMuted : AppColors.textDark,
                  decoration: done ? TextDecoration.lineThrough : null,
                  decorationColor: AppColors.textMuted,
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
