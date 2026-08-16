import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/models/reward.dart';
import '../core/theme/app_theme.dart';
import 'confetti_burst.dart';

/// Panandaliang pagdiriwang sa gitna ng screen kapag may naabot na pabuya.
class GoalAchievedOverlay extends StatefulWidget {
  final List<Reward> rewards;

  const GoalAchievedOverlay({super.key, required this.rewards});

  static Future<void> show(BuildContext context, List<Reward> rewards) {
    unawaited(HapticFeedback.mediumImpact());
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (context) => GoalAchievedOverlay(rewards: rewards),
    );
  }

  @override
  State<GoalAchievedOverlay> createState() => _GoalAchievedOverlayState();
}

class _GoalAchievedOverlayState extends State<GoalAchievedOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    _particles = ConfettiParticle.burst(count: 46, spread: 2.6);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => CustomPaint(
                  painter: ConfettiPainter(
                    particles: _particles,
                    progress: _controller.value,
                    gravity: 420,
                  ),
                ),
              ),
            ),
          ),
          _buildPrizeBox(),
        ],
      ),
    );
  }

  Widget _buildPrizeBox() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 34, 22, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.starGold, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLid(),
          const SizedBox(height: 16),
          const Text(
            'NAABOT ANG LAYUNIN!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: AppColors.textDark,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.rewards.length == 1
                ? 'May nabuksang pabuya.'
                : 'May ${widget.rewards.length} nabuksang pabuya.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textDark,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 18),
          for (final reward in widget.rewards) ...[
            _buildRewardTile(reward),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.logoGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
              ),
              child: const Text(
                'Ayos!',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Nunito',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLid() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.butterYellow,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.starGold, width: 3),
      ),
      child: const Icon(
        Icons.card_giftcard_rounded,
        size: 38,
        color: AppColors.starGold,
      ),
    );
  }

  Widget _buildRewardTile(Reward reward) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.butterYellow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.starGold, width: 2),
      ),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, size: 20, color: AppColors.starGold),
          const SizedBox(width: 6),
          Text(
            '${reward.stars}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              reward.label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
                height: 1.3,
                fontFamily: 'Nunito',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
