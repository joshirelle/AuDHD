import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/hive_service.dart';

class TourStep {
  final GlobalKey targetKey;
  final String title;
  final String body;

  const TourStep({
    required this.targetKey,
    required this.title,
    required this.body,
  });
}

/// Isang beses na paglilibot sa home screen. Hand-rolled para walang
/// dagdag na dependency at para Tagalog ang buong teksto.
class HomeTourGuide {
  static const double _cutoutPadding = 8;
  static const double _cutoutRadius = 16;

  /// Tumatakbo lamang kung hindi pa ito nakikita ng magulang.
  static void showIfNeeded(BuildContext context, List<TourStep> steps) {
    if (HiveService.hasSeen(HiveService.hasSeenHomeTourKey)) return;
    if (steps.isEmpty) return;

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    var isRemoved = false;
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _TourOverlay(
        steps: steps,
        onFinished: () async {
          if (isRemoved) return;
          isRemoved = true;
          entry.remove();
          await HiveService.markSeen(HiveService.hasSeenHomeTourKey);
        },
      ),
    );

    overlay.insert(entry);
  }

  static Rect? rectFor(GlobalKey key) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.attached) return null;

    final origin = renderBox.localToGlobal(Offset.zero);
    return Rect.fromLTWH(
      origin.dx,
      origin.dy,
      renderBox.size.width,
      renderBox.size.height,
    ).inflate(_cutoutPadding);
  }
}

class _TourOverlay extends StatefulWidget {
  final List<TourStep> steps;
  final Future<void> Function() onFinished;

  const _TourOverlay({required this.steps, required this.onFinished});

  @override
  State<_TourOverlay> createState() => _TourOverlayState();
}

class _TourOverlayState extends State<_TourOverlay> {
  int _index = 0;

  void _next() {
    if (_index == widget.steps.length - 1) {
      widget.onFinished();
      return;
    }
    setState(() => _index++);
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[_index];
    final target = HomeTourGuide.rectFor(step.targetKey);
    final screen = MediaQuery.sizeOf(context);
    final isLast = _index == widget.steps.length - 1;

    // Kung nawala ang target, huwag ipilit ang libot kaysa magpakita ng maling turo.
    if (target == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onFinished());
      return const SizedBox.shrink();
    }

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _next,
              child: CustomPaint(
                painter: _CutoutPainter(target: target),
              ),
            ),
          ),
          _buildCard(step, target, screen, isLast),
        ],
      ),
    );
  }

  Widget _buildCard(TourStep step, Rect target, Size screen, bool isLast) {
    // Inilalagay ang paliwanag sa mas maluwag na panig ng na-highlight na bahagi.
    final showBelow = target.center.dy < screen.height / 2;
    final top = showBelow ? target.bottom + 16 : null;
    final bottom = showBelow ? null : screen.height - target.top + 16;

    return Positioned(
      left: 20,
      right: 20,
      top: top,
      bottom: bottom,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              step.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              step.body,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.45,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_index + 1} / ${widget.steps.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                    fontFamily: 'Nunito',
                  ),
                ),
                Row(
                  children: [
                    if (!isLast)
                      TextButton(
                        onPressed: () => widget.onFinished(),
                        child: Text(
                          'Laktawan',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ),
                    ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.logoGreen,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppRadius.button,
                          ),
                        ),
                      ),
                      child: Text(
                        isLast ? 'Nakuha ko!' : 'Susunod',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CutoutPainter extends CustomPainter {
  final Rect target;

  const _CutoutPainter({required this.target});

  @override
  void paint(Canvas canvas, Size size) {
    final screen = Path()..addRect(Offset.zero & size);
    final hole = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          target,
          const Radius.circular(HomeTourGuide._cutoutRadius),
        ),
      );

    canvas.drawPath(
      Path.combine(PathOperation.difference, screen, hole),
      Paint()..color = Colors.black.withValues(alpha: 0.72),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        target,
        const Radius.circular(HomeTourGuide._cutoutRadius),
      ),
      Paint()
        ..color = AppColors.starGold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(_CutoutPainter oldDelegate) =>
      oldDelegate.target != target;
}
