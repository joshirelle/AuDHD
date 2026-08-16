import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'confetti_burst.dart';

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
  late final List<ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    _particles = ConfettiParticle.burst(count: 8 + widget.stars * 6);
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
                    painter: ConfettiPainter(
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
