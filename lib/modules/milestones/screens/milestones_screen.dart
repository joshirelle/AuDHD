import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/milestone_constants.dart';
import '../../../core/i18n/language_controller.dart';
import '../../../core/services/star_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/services/hive_service.dart';
import '../../../widgets/how_to_card.dart';
import '../../../widgets/kiko_card.dart';
import '../../../widgets/star_burst_overlay.dart';
import '../../home/widgets/star_badge_widget.dart';
import '../models/milestone.dart';

class MilestonesScreen extends StatefulWidget {
  const MilestonesScreen({super.key});

  @override
  State<MilestonesScreen> createState() => _MilestonesScreenState();
}

class _MilestonesScreenState extends State<MilestonesScreen> {
  static const Map<MilestoneDomain, Color> _domainColors = {
    MilestoneDomain.grossMotor: AppColors.mintGreen,
    MilestoneDomain.fineMotor: AppColors.skyBlue,
    MilestoneDomain.speechLanguage: AppColors.butterYellow,
    MilestoneDomain.socialEmotional: AppColors.coralPeach,
  };

  static const Color _achievedTint = AppColors.tintSuccess;
  static const Color _achievedGreen = AppColors.logoGreen;

  /// `null` ang ibig sabihin ay "Lahat".
  MilestoneDomain? _filter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('Mga Milestone ng Paglaki', 'Growth Milestones')),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(child: StarBadgeWidget()),
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: ValueListenableBuilder<Box<int>>(
        valueListenable: HiveService.getMilestoneBox().listenable(),
        builder: (context, box, _) {
          final visible = MilestoneConstants.inDomain(_filter);
          final achieved = visible
              .where((m) => HiveService.isMilestoneAchieved(m.id))
              .length;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              HowToCard(
                steps: [
                  tr(
                    'Piliin sa itaas kung aling bahagi ng paglaki ang gusto mong '
                        'tingnan.',
                    'Choose above which part of growing up you want to look at.',
                  ),
                  tr(
                    'Tsekan lamang ang mga nagagawa na ng bata nang kusa, hindi '
                        'ang mga natutulungan mo pa.',
                    'Tick only what the child already does on their own, not '
                        'what you still help with.',
                  ),
                  tr(
                    'Balikan ito paminsan-minsan. Nagbabago ang kakayahan ng bata '
                        'sa paglipas ng panahon.',
                    'Come back to this now and then. What a child can do keeps '
                        'changing over time.',
                  ),
                ],
                footnote: tr(
                  'Hindi ito paligsahan. Magkakaiba ang bilis ng bawat bata, '
                      'at ang hindi pa natsetsekan ay hindi kabiguan.',
                  'This is not a race. Every child moves at their own pace, and '
                      'an unticked box is not a failure.',
                ),
              ),
              const SizedBox(height: 18),
              _buildFilterChips(),
              const SizedBox(height: 18),
              _buildProgressCard(achieved, visible.length),
              const SizedBox(height: 20),
              for (final milestone in visible) ...[
                _buildMilestoneCard(milestone),
                const SizedBox(height: 10),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChip(tr('Lahat', 'All'), null),
          for (final domain in MilestoneDomain.values) ...[
            const SizedBox(width: 8),
            _buildChip(domain.label, domain),
          ],
        ],
      ),
    );
  }

  Widget _buildChip(String label, MilestoneDomain? domain) {
    final isSelected = _filter == domain;

    return GestureDetector(
      onTap: () => setState(() => _filter = domain),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.logoGreen : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.button),
          border: Border.all(
            color: isSelected ? AppColors.logoGreen : AppColors.divider,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? AppColors.surface : AppColors.textDark,
            fontFamily: 'Nunito',
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard(int achieved, int total) {
    final progress = total == 0 ? 0.0 : achieved / total;

    return KikoCard(
      backgroundColor: AppColors.skyBlueLight,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr(
              '$achieved sa $total na Milestones ang Naabot',
              '$achieved of $total Milestones Reached',
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
            _filter == null
                ? tr('Lahat ng bahagi', 'All areas')
                : _filter!.label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: AppColors.surface,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.logoGreen,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  fontFamily: 'Nunito',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneCard(Milestone milestone) {
    final isAchieved = HiveService.isMilestoneAchieved(milestone.id);
    final achievedDate = HiveService.milestoneAchievedDate(milestone.id);
    final domainColor = _domainColors[milestone.domain] ?? AppColors.skyBlueLight;

    return KikoCard(
      backgroundColor: isAchieved ? _achievedTint : AppColors.surface,
      borderColor: isAchieved ? _achievedGreen : AppColors.divider,
      padding: const EdgeInsets.all(14),
      onTap: () => _toggle(context, milestone, isAchieved),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCheckbox(milestone, isAchieved),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    height: 1.3,
                    fontFamily: 'Nunito',
                    decoration: isAchieved
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _buildBadge(milestone.targetAgeLabel, domainColor),
                    if (_filter == null)
                      _buildBadge(milestone.domain.label, domainColor),
                  ],
                ),
                if (achievedDate != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    tr(
                      'Naabot noong ${DateFormatter.longDate(achievedDate)}',
                      'Reached on ${DateFormatter.longDate(achievedDate)}',
                    ),
                    style: const TextStyle(
                      fontSize: 11,
                      color: _achievedGreen,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox(Milestone milestone, bool isAchieved) {
    return Semantics(
      checked: isAchieved,
      label: milestone.title,
      // Sariling context para tumapat ang burst sa mismong checkbox.
      child: Builder(
        builder: (context) => InkWell(
          onTap: () => _toggle(context, milestone, isAchieved),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isAchieved ? _achievedGreen : AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: isAchieved ? _achievedGreen : AppColors.textMuted,
                width: 2,
              ),
            ),
            child: isAchieved
                ? const Icon(Icons.check_rounded, size: 20, color: AppColors.surface)
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color background) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
          fontFamily: 'Nunito',
        ),
      ),
    );
  }

  Future<void> _toggle(
    BuildContext tapContext,
    Milestone milestone,
    bool isAchieved,
  ) async {
    await HiveService.setMilestoneAchieved(milestone.id, !isAchieved);
    if (!isAchieved && tapContext.mounted) {
      // Pabuya lang sa pag-abot; walang animation kapag inaalis ang tsek.
      StarBurstOverlay.show(tapContext, StarService.starsPerMilestone);
    }
  }
}
