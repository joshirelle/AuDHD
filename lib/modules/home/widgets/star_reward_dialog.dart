import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/i18n/language_controller.dart';
import '../../../core/models/reward.dart';
import '../../../core/services/reward_service.dart';
import '../../../core/services/star_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/hive_service.dart';
import '../../../widgets/child_avatar.dart';
import 'add_reward_dialog.dart';

class StarRewardDialog extends StatelessWidget {
  const StarRewardDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => const StarRewardDialog(),
    );
  }

  Future<void> _addReward(BuildContext context) async {
    final reward = await AddRewardDialog.show(context);
    if (reward == null) return;
    await RewardService.addCustom(reward.label, reward.stars);
  }

  @override
  Widget build(BuildContext context) {
    final total = StarService.totalStars();
    final name = HiveService.getChildProfile()?.displayName.trim();
    final hasName = name != null && name.isNotEmpty;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.background,
      contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: _buildHeader(total, hasName ? name : null)),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.skyBlueLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                tr(
                  'Gagawaran ng bituin ang bawat natapos na laro, gawain sa '
                      'iskedyul, at milestone. Ipunin ito, tapos ipagpalit sa '
                      'isang pabuya sa totoong buhay.',
                  'Stars are given for every finished game, schedule task, and '
                      'milestone. Save them up, then trade them for a '
                      'real-life reward.',
                ),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textDark,
                  height: 1.4,
                  fontFamily: 'Nunito',
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              tr('MGA PABUYA', 'REWARDS'),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
                letterSpacing: 0.5,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 10),
            ValueListenableBuilder<Box<int>>(
              valueListenable: HiveService.getRewardBox().listenable(),
              builder: (context, box, _) {
                final rewards = RewardService.all();
                if (rewards.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      tr(
                        'Wala ka pang pabuya. Ikaw ang magpapasya kung ano ang '
                            'makukuha niya sa mga bituin.',
                        'No rewards yet. You decide what your child gets for '
                            'the stars.',
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: AppColors.textDark,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final reward in rewards) ...[
                      _buildRewardRow(reward, total >= reward.stars),
                      const SizedBox(height: 8),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 4),
            TextButton.icon(
              onPressed: () => _addReward(context),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.logoGreen,
                minimumSize: const Size.fromHeight(44),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(
                tr('Magdagdag ng sariling pabuya', 'Add your own reward'),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Nunito',
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            tr('Ipagpatuloy ang Pag-ipon', 'Keep collecting'),
            style: const TextStyle(
              color: AppColors.logoGreen,
              fontWeight: FontWeight.bold,
              fontFamily: 'Nunito',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(int total, String? name) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            const ChildAvatar(size: 76),
            Positioned(
              right: -6,
              bottom: -4,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.starGold,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 2),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  size: 20,
                  color: AppColors.surface,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          name == null
              ? tr('May $total na bituin na!', '$total stars so far!')
              : tr(
                  'May $total na bituin na si $name!',
                  '$name has $total stars now!',
                ),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
            fontFamily: 'Nunito',
          ),
        ),
      ],
    );
  }

  Widget _buildRewardRow(Reward reward, bool isUnlocked) {
    final color = isUnlocked ? AppColors.starGold : AppColors.textMuted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isUnlocked ? AppColors.butterYellow : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isUnlocked ? color : AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.star_rounded, size: 18, color: color),
          const SizedBox(width: 4),
          SizedBox(
            width: 26,
            child: Text(
              '${reward.stars}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isUnlocked ? AppColors.textDark : AppColors.textMuted,
                fontFamily: 'Nunito',
              ),
            ),
          ),
          Expanded(
            child: Text(
              reward.label,
              style: TextStyle(
                fontSize: 12,
                color: isUnlocked ? AppColors.textDark : AppColors.textMuted,
                height: 1.3,
                fontFamily: 'Nunito',
              ),
            ),
          ),
          if (isUnlocked)
            const Icon(
              Icons.check_circle_rounded,
              size: 18,
              color: AppColors.logoGreen,
            ),
          if (reward.isCustom)
            GestureDetector(
              onTap: () => RewardService.deleteCustom(reward.label),
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: AppColors.danger,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
