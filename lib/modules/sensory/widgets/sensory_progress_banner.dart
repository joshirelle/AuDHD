import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/kiko_card.dart';

class SensoryProgressBanner extends StatelessWidget {
  final int completedCount;
  final int totalCount;

  const SensoryProgressBanner({
    super.key,
    required this.completedCount,
    required this.totalCount,
  });

  static const Color _bannerBackground = AppColors.tintBlue;
  static const Color _warmYellow = AppColors.starGoldLight;

  @override
  Widget build(BuildContext context) {
    final double progress =
        totalCount == 0 ? 0 : completedCount / totalCount;
    final int percent = (progress * 100).round();

    return KikoCard(
      backgroundColor: _bannerBackground,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMascot(),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$completedCount sa $totalCount na gawain ang natapos ngayon!',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    height: 1.3,
                    fontFamily: 'Nunito',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          backgroundColor: Colors.white,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            _warmYellow,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$percent%',
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
          ),
        ],
      ),
    );
  }

  Widget _buildMascot() {
    return SizedBox(
      width: 64,
      height: 64,
      child: Image.asset(
        'assets/images/kiko_waving.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.emoji_emotions_rounded,
            color: AppColors.logoGreen,
            size: 32,
          ),
        ),
      ),
    );
  }
}
