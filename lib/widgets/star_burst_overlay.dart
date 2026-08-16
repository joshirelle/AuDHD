import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Panandaliang "+N" at confetti sa ibabaw ng natapos na item.
/// Nasa Overlay ito para hindi magbago ang taas ng listahan habang tumatakbo.
class StarBurstOverlay {
  static const Duration duration = Duration(milliseconds: 2400);

  /// Ang `context` ay dapat galing sa mismong pinindot para tumapat ang lugar.
  static void show(BuildContext context, int stars) {
    final overlay = Overlay.maybeOf(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    if (overlay == null || renderBox == null || !renderBox.attached) return;

    final origin = renderBox.localToGlobal(
      renderBox.size.center(Offset.zero),
    );

    var isRemoved = false;
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => IgnorePointer(
        child: _StarBurst(
          origin: origin,
          stars: stars,
          onDone: () {
            if (isRemoved) return;
            isRemoved = true;
            entry.remove();
          },
        ),
      ),
    );

    overlay.insert(entry);
  }
}

class _StarBurst extends StatefulWidget {
  final Offset origin;
  final int stars;
  final VoidCallback onDone;

  const _StarBurst({
    required this.origin,
    required this.stars,
    required this.onDone,
  });

  @override
  State<_StarBurst> createState() => _StarBurstState();
}

class _StarBurstState extends State<_StarBurst>
    with SingleTickerProviderStateMixin {
  static const double _boxSize = 220;

  late final AnimationController _controller;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _particles = _Particle.burst(count: 8 + widget.stars * 6);
    _controller = AnimationController(
      vsync: this,
      duration: StarBurstOverlay.duration,
    )..forward().whenComplete(widget.onDone);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: widget.origin.dx - _boxSize / 2,
          top: widget.origin.dy - _boxSize / 2,
          width: _boxSize,
          height: _boxSize,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final t = _controller.value;
              return Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size.square(_boxSize),
                    painter: _ConfettiPainter(
                      particles: _particles,
                      progress: t,
                    ),
                  ),
                  _buildLabel(t),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(double t) {
    // Pop muna, lumulutang, tapos kumukupas sa huling bahagi.
    final scale = t < 0.18
        ? Curves.easeOutBack.transform(t / 0.18)
        : 1.0;
    final rise = Curves.easeOut.transform(t) * 76;
    final opacity = t < 0.55
        ? 1.0
        : (1 - (t - 0.55) / 0.45).clamp(0.0, 1.0);

    return Transform.translate(
      offset: Offset(0, -rise),
      child: Opacity(
        opacity: opacity,
        child: Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.butterYellow,
              borderRadius: BorderRadius.circular(AppRadius.button),
              border: Border.all(color: AppColors.starGold, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 20,
                  color: AppColors.starGold,
                ),
                const SizedBox(width: 4),
                Text(
                  '+${widget.stars}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
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

class _Particle {
  final double angle;
  final double speed;
  final double size;
  final double spin;
  final Color color;

  const _Particle({
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

  static List<_Particle> burst({required int count}) {
    final random = Random();
    return List<_Particle>.generate(count, (index) {
      return _Particle(
        angle: random.nextDouble() * 2 * pi,
        speed: 60 + random.nextDouble() * 70,
        size: 5 + random.nextDouble() * 5,
        spin: (random.nextDouble() - 0.5) * 8,
        color: _palette[random.nextInt(_palette.length)],
      );
    });
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  const _ConfettiPainter({required this.particles, required this.progress});

  static const double _gravity = 150;

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
          _gravity * progress * progress;

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
  bool shouldRepaint(_ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
