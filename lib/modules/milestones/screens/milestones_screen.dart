import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/milestone_constants.dart';
import '../../../core/i18n/language_controller.dart';
import '../../../core/services/star_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/link_launcher.dart';
import '../../../data/services/hive_service.dart';
import '../../../widgets/cdc_attribution.dart';
import '../../../widgets/how_to_card.dart';
import '../../../widgets/kiko_card.dart';
import '../../../widgets/star_burst_overlay.dart';
import '../../home/widgets/star_badge_widget.dart';
import '../../sensory/screens/sensory_checklist_screen.dart';
import '../models/milestone.dart';

class MilestonesScreen extends StatefulWidget {
  const MilestonesScreen({super.key});

  @override
  State<MilestonesScreen> createState() => _MilestonesScreenState();
}

class _MilestonesScreenState extends State<MilestonesScreen> {
  static const Map<MilestoneDomain, Color> _domainColors = {
    MilestoneDomain.socialEmotional: AppColors.coralPeach,
    MilestoneDomain.language: AppColors.butterYellow,
    MilestoneDomain.cognitive: AppColors.lavender,
    MilestoneDomain.movement: AppColors.mintGreen,
  };

  static const Color _achievedTint = AppColors.tintSuccess;
  static const Color _achievedGreen = AppColors.logoGreen;

  /// `null` ang ibig sabihin ay "Lahat".
  MilestoneDomain? _filter;

  static const String _resetNoticeKey = 'has_seen_milestone_reset_v6';

  bool _noticeSeen = HiveService.hasSeen(_resetNoticeKey);

  /// Nakatali sa lumang `id` ang tsek ng magulang. Hindi natin binubura ang
  /// luma — kaya kung babalikan natin ang dating listahan, babalik din sila.
  /// Pero hindi na ito nababasa ngayon, kaya blangko ang kanyang makikita.
  bool get _hasOrphanedProgress {
    final valid = MilestoneConstants.milestones
        .map((m) => HiveService.milestoneKey(m.id))
        .toSet();
    return HiveService.getMilestoneBox().keys.any(
      (key) => !valid.contains(key),
    );
  }

  Future<void> _dismissNotice() async {
    await HiveService.markSeen(_resetNoticeKey);
    if (!mounted) return;
    setState(() => _noticeSeen = true);
  }

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
              if (!_noticeSeen && _hasOrphanedProgress) ...[
                _buildResetNotice(),
                const SizedBox(height: 18),
              ],
              // Nauuna sa paliwanag: isang nurse na sumubok ng app ang hindi
              // nakapansin na hati na ito, kaya hindi rin ito makikita ng
              // magulang kung nasa ilalim pa ng mahabang teksto.
              _buildFilterChips(),
              const SizedBox(height: 18),
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
              _buildCdcNotice(),
              const SizedBox(height: 18),
              _buildProgressCard(achieved, visible.length),
              const SizedBox(height: 20),
              for (final group in _groupedByAge(visible).entries) ...[
                _buildAgeHeader(group.value.first, group.value.length),
                const SizedBox(height: 10),
                if (MilestoneConstants.screeningNotice(group.key)
                    case final notice?) ...[
                  _buildScreeningNotice(notice),
                  const SizedBox(height: 12),
                ],
                for (final milestone in group.value) ...[
                  _buildMilestoneCard(milestone),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 14),
              _buildSensoryBridge(),
            ],
          );
        },
      ),
    );
  }

  /// Card at hindi modal: apat na modal na ang sumasalubong sa dating
  /// gumagamit sa v6, at dito lang naman nakikita ang problema.
  Widget _buildResetNotice() {
    return KikoCard(
      backgroundColor: AppColors.tintTeal,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.autorenew_rounded,
                size: 18,
                color: AppColors.skyInk,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  tr('Bagong listahan ng milestone', 'A new milestone list'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.skyInk,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            tr(
              'Pinalitan namin ang lumang 16 na milestone ng mas kumpletong '
                  'listahan — 72 na ngayon, at umaabot hanggang 5 '
                  'taon.\n\nHindi nabawasan ang bituin ninyo. Pero kailangan '
                  'mong markahan muli ang mga nagagawa na ng anak mo, dahil '
                  'bago na ang listahan.',
              'We replaced the old 16 milestones with a fuller list '
                  '— there are 72 now, reaching up to 5 years.\n\nYour stars '
                  'were not reduced. But you will need to tick again what '
                  'your child can already do, because the list is new.',
            ),
            style: const TextStyle(
              fontSize: 12,
              height: 1.45,
              color: AppColors.textDark,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: _dismissNotice,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: AppColors.skyInk,
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
                child: Text(
                  tr('Naiintindihan ko', 'I understand'),
                  style: const TextStyle(
                    fontSize: 12,
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
    );
  }

  /// Kundisyon ng CDC ang apat na bahaging ito, kaya walang naka-collapse:
  /// dapat nakikita agad, hindi kailangang pindutin.
  Widget _buildCdcNotice() {
    return KikoCard(
      backgroundColor: AppColors.tintGold,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: AppColors.warning,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  CdcAttribution.notice,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    color: AppColors.textDark,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.card - 10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(CdcAttribution.citation, style: _sourceStyle),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => LinkLauncher.open(
                    context,
                    CdcAttribution.linkUri,
                    tr(
                      'Hindi mabuksan ang browser. Bisitahin ang '
                          'cdc.gov/ActEarly.',
                      'Could not open the browser. Please visit '
                          'cdc.gov/ActEarly.',
                    ),
                  ),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        CdcAttribution.linkLabel,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentBlue,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.accentBlue,
                          fontFamily: 'Nunito',
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.open_in_new_rounded,
                        size: 11,
                        color: AppColors.accentBlue,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(CdcAttribution.endorsement, style: _sourceStyle),
                const SizedBox(height: 8),
                Text(CdcAttribution.free, style: _sourceStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const TextStyle _sourceStyle = TextStyle(
    fontSize: 10,
    height: 1.45,
    color: AppColors.textMuted,
    fontFamily: 'Nunito',
  );

  /// Naka-sunod-sunod na ang magkakaedad sa `MilestoneConstants`, kaya ang
  /// pagkakasunod ng pagpasok dito ang mismong pagkakasunod sa pantalan.
  Map<int, List<Milestone>> _groupedByAge(List<Milestone> items) {
    final groups = <int, List<Milestone>>{};
    for (final item in items) {
      groups.putIfAbsent(item.targetAgeMonths, () => []).add(item);
    }
    return groups;
  }

  /// Hindi ito panukat kundi paalala kung kailan hihingi sa doktor — kaya
  /// asul at hindi pula, at walang tsek na kasama.
  Widget _buildScreeningNotice(String notice) {
    return KikoCard(
      backgroundColor: AppColors.tintBlue,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.event_available_rounded,
            size: 18,
            color: AppColors.accentBlue,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr(
                    'Oras na para sa screening na pag-unlad',
                    'Time for developmental screening',
                  ),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    fontFamily: 'Nunito',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  notice,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    color: AppColors.textDark,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Sinusunod ang pananalita ng CDC: "karaniwan", hindi "dapat". May 1 sa 4
  /// na batang hindi pa ito nagagawa at normal pa rin.
  Widget _buildAgeHeader(Milestone first, int count) {
    return Row(
      children: [
        Expanded(
          child: Text(
            tr(
              'Ginagawa ng karamihan ng mga bata sa ${first.ageLabel}',
              'What most children do by ${first.ageLabel}',
            ),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              fontFamily: 'Nunito',
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.tintGold,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              fontFamily: 'Nunito',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('Bahagi ng paglaki', 'Part of growing up'),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textMuted,
            fontFamily: 'Nunito',
          ),
        ),
        const SizedBox(height: 8),
        // `Wrap` at hindi horizontal scroll: sa makitid na telepono, ang mga
        // chip na hindi kasya ay tahimik na nawawala sa gilid.
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip(tr('Lahat', 'All'), null),
            for (final domain in MilestoneDomain.values)
              _buildChip(domain.label, domain),
          ],
        ),
      ],
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

  /// Ang pandama ay hindi kasama sa apat na bahagi rito — nasa sariling
  /// bahagi ito ng app, at hindi ito nakikita ng magulang na nasa listahang
  /// ito lang tumitingin.
  Widget _buildSensoryBridge() {
    return KikoCard(
      backgroundColor: AppColors.tintTeal,
      padding: const EdgeInsets.all(18),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SensoryChecklistScreen()),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.skyInk.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.spa_rounded,
              color: AppColors.skyInk,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('Paano naman ang pandama?', 'What about the senses?'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    fontFamily: 'Nunito',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tr(
                    'Hindi kasama ang pandama sa apat sa itaas. May sariling '
                        'checklist ito para sa ingay, hipo, at paggalaw.',
                    'The senses are not part of the four above. They have their '
                        'own checklist for sound, touch, and movement.',
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: AppColors.textDark,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textDark),
        ],
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
    final domainColor =
        _domainColors[milestone.domain] ?? AppColors.skyBlueLight;

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
                if (milestone.note != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.translate_rounded,
                        size: 13,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          milestone.note!,
                          style: const TextStyle(
                            fontSize: 11,
                            height: 1.35,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textMuted,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                _buildBadge(milestone.domain.label, domainColor),
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
                ? const Icon(
                    Icons.check_rounded,
                    size: 20,
                    color: AppColors.surface,
                  )
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
