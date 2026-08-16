import 'dart:math';

import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class ConfettiParticle {
  final double angle;
  final double speed;
  final double size;
  final double spin;
  final Color color;

  const ConfettiParticle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.spin,
    required this.color,
  });

  static const List<Color> _palette = [
    AppColors.starGold,
    AppColors.mintGreen,
    AppColors.skyBlue,
    AppColors.coralPeach,
    AppColors.logoGreen,
  ];

  /// Itaas ang `spread` para sa mas malaking lugar gaya ng buong screen.
  static List<ConfettiParticle> burst({
    required int count,
    double spread = 1.0,
  }) {
    final random = Random();
    return List<ConfettiParticle>.generate(count, (index) {
      return ConfettiParticle(
        angle: random.nextDouble() * 2 * pi,
        speed: (60 + random.nextDouble() * 70) * spread,
        size: (5 + random.nextDouble() * 5) * (spread > 1 ? 1.4 : 1.0),
        spin: (random.nextDouble() - 0.5) * 8,
        color: _palette[random.nextInt(_palette.length)],
      );
    });
  }
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;
  final double gravity;

  const ConfettiPainter({
    required this.particles,
    required this.progress,
    this.gravity = 150,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress >= 1) return;

    final center = size.center(Offset.zero);
    // Mabilis sa umpisa, bumabagal habang bumabagsak.
    final travel = Curves.easeOutCubic.transform(progress);
    final opacity = (1 - progress).clamp(0.0, 1.0);
    final paint = Paint();

    for (final particle in particles) {
      final dx = cos(particle.angle) * particle.speed * travel;
      final dy = sin(particle.angle) * particle.speed * travel +
          gravity * progress * progress;

      paint.color = particle.color.withValues(alpha: opacity);

      canvas.save();
      canvas.translate(center.dx + dx, center.dy + dy);
      canvas.rotate(particle.spin * progress);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size * 0.6,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
