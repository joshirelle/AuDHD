import 'package:flutter/material.dart';
import '../../../core/services/star_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/hive_service.dart';
import '../../../widgets/child_avatar.dart';

class StarRewardDialog extends StatelessWidget {
  const StarRewardDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => const StarRewardDialog(),
    );
  }

  static const List<({int stars, String reward})> _rewards = [
    (stars: 5, reward: '15 minutong dagdag na laro sa labas'),
    (stars: 10, reward: 'Paboritong meryenda'),
    (stars: 15, reward: 'Kwento bago matulog'),
  ];

  @override
  Widget build(BuildContext context) {
    final total = StarService.totalStars();
    final name = HiveService.getChildProfile()?.name.trim();
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
              child: const Text(
                'Gagawaran ng bituin ang bawat natapos na laro at milestone. '
                'Gamitin ito bilang pabuya (Token System) sa totoong buhay!',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textDark,
                  height: 1.4,
                  fontFamily: 'Nunito',
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'MGA HALIMBAWANG PABUYA',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
                letterSpacing: 0.5,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 10),
            for (final tier in _rewards) ...[
              _buildRewardRow(tier.stars, tier.reward, total >= tier.stars),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Ipagpatuloy ang Pag-ipon',
            style: TextStyle(
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
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          name == null
              ? 'May $total na bituin na!'
              : 'May $total na bituin na si $name!',
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

  Widget _buildRewardRow(int stars, String reward, bool isUnlocked) {
    final color = isUnlocked ? AppColors.starGold : Colors.grey.shade400;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isUnlocked ? AppColors.butterYellow : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isUnlocked ? color : Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.star_rounded, size: 18, color: color),
          const SizedBox(width: 4),
          SizedBox(
            width: 26,
            child: Text(
              '$stars',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isUnlocked ? AppColors.textDark : Colors.grey.shade600,
                fontFamily: 'Nunito',
              ),
            ),
          ),
          Expanded(
            child: Text(
              reward,
              style: TextStyle(
                fontSize: 12,
                color: isUnlocked ? AppColors.textDark : Colors.grey.shade600,
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
        ],
      ),
    );
  }
}
