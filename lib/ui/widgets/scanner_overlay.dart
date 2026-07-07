import 'package:flutter/material.dart';

import '../app_colors.dart';

/// Dims everything outside a centered square frame and draws accent-colored
/// corner brackets plus an animated scanline inside it, matching the scan
/// screen mockup.
class ScannerOverlay extends StatefulWidget {
  const ScannerOverlay({super.key, this.frameSize = 244});

  final double frameSize;

  @override
  State<ScannerOverlay> createState() => _ScannerOverlayState();
}

class _ScannerOverlayState extends State<ScannerOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final center = Offset(constraints.maxWidth / 2, constraints.maxHeight * 0.46);
        final frameRect = Rect.fromCenter(center: center, width: widget.frameSize, height: widget.frameSize);

        return IgnorePointer(
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(painter: _ScrimPainter(frameRect)),
              ),
              Positioned(
                left: frameRect.left,
                top: frameRect.top,
                width: frameRect.width,
                height: frameRect.height,
                child: Stack(
                  children: [
                    const _CornerBracket(alignment: Alignment.topLeft),
                    const _CornerBracket(alignment: Alignment.topRight),
                    const _CornerBracket(alignment: Alignment.bottomLeft),
                    const _CornerBracket(alignment: Alignment.bottomRight),
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) {
                        final t = _controller.value;
                        final opacity = t < .12
                            ? t / .12
                            : t > .88
                                ? (1 - t) / .12
                                : 1.0;
                        return Positioned(
                          left: 14,
                          right: 14,
                          top: 6 + t * (widget.frameSize - 12),
                          child: Opacity(
                            opacity: opacity.clamp(0, 1),
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                gradient: const LinearGradient(
                                  colors: [Colors.transparent, AppColors.accent, Colors.transparent],
                                ),
                                boxShadow: const [
                                  BoxShadow(color: AppColors.accent, blurRadius: 14, spreadRadius: 2),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CornerBracket extends StatelessWidget {
  const _CornerBracket({required this.alignment});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final isTop = alignment.y < 0;
    final isLeft = alignment.x < 0;
    const side = BorderSide(color: AppColors.accent, width: 4);
    const radius = Radius.circular(22);

    return Align(
      alignment: alignment,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          border: Border(
            top: isTop ? side : BorderSide.none,
            bottom: !isTop ? side : BorderSide.none,
            left: isLeft ? side : BorderSide.none,
            right: !isLeft ? side : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft: isTop && isLeft ? radius : Radius.zero,
            topRight: isTop && !isLeft ? radius : Radius.zero,
            bottomLeft: !isTop && isLeft ? radius : Radius.zero,
            bottomRight: !isTop && !isLeft ? radius : Radius.zero,
          ),
        ),
      ),
    );
  }
}

class _ScrimPainter extends CustomPainter {
  _ScrimPainter(this.hole);

  final Rect hole;

  @override
  void paint(Canvas canvas, Size size) {
    final outer = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final inner = Path()..addRRect(RRect.fromRectAndRadius(hole, const Radius.circular(30)));
    final path = Path.combine(PathOperation.difference, outer, inner);
    canvas.drawPath(path, Paint()..color = const Color.fromRGBO(15, 20, 19, .34));
  }

  @override
  bool shouldRepaint(covariant _ScrimPainter oldDelegate) => oldDelegate.hole != hole;
}
