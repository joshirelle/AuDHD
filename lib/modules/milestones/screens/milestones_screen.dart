import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/milestone_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/hive_service.dart';
import '../../../widgets/kiko_card.dart';
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

  static const Color _achievedTint = Color(0xFFE7F6EC);
  static const Color _achievedGreen = Color(0xFF1E7145);

  /// `null` ang ibig sabihin ay "Lahat".
  MilestoneDomain? _filter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developmental Milestones'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
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
          _buildChip('Lahat', null),
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
          color: isSelected ? AppColors.logoGreen : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.button),
          border: Border.all(
            color: isSelected ? AppColors.logoGreen : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppColors.textDark,
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
            '$achieved sa $total na Milestones ang Naabot',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _filter == null ? 'Lahat ng domain' : _filter!.label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
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
                    backgroundColor: Colors.white,
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
      backgroundColor: isAchieved ? _achievedTint : Colors.white,
      borderColor: isAchieved ? _achievedGreen : Colors.grey.shade200,
      padding: const EdgeInsets.all(14),
      onTap: () => _toggle(milestone, isAchieved),
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
                  milestone.titleTagalog,
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
                    'Naabot noong ${_formatDate(achievedDate)}',
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
      label: milestone.titleTagalog,
      child: InkWell(
        onTap: () => _toggle(milestone, isAchieved),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isAchieved ? _achievedGreen : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isAchieved ? _achievedGreen : Colors.grey.shade400,
              width: 2,
            ),
          ),
          child: isAchieved
              ? const Icon(Icons.check_rounded, size: 20, color: Colors.white)
              : null,
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

  Future<void> _toggle(Milestone milestone, bool isAchieved) {
    return HiveService.setMilestoneAchieved(milestone.id, !isAchieved);
  }

  static String _formatDate(DateTime date) {
    const months = [
      'Enero',
      'Pebrero',
      'Marso',
      'Abril',
      'Mayo',
      'Hunyo',
      'Hulyo',
      'Agosto',
      'Setyembre',
      'Oktubre',
      'Nobyembre',
      'Disyembre',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
