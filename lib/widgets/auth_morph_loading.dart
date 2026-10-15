import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme.dart';

/// The form's section bounds contract into dots, then orbit together.
class AuthMorphLoading extends StatefulWidget {
  final List<Rect> sections;
  final String label;
  const AuthMorphLoading({
    super.key,
    required this.sections,
    required this.label,
  });
  @override
  State<AuthMorphLoading> createState() => _AuthMorphLoadingState();
}

class _AuthMorphLoadingState extends State<AuthMorphLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController motion = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );
  bool reduced = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    reduced = MediaQuery.disableAnimationsOf(context);
    if (reduced) {
      motion.stop();
    } else if (!motion.isAnimating) {
      motion.repeat();
    }
  }

  @override
  void dispose() {
    motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    child: Semantics(
      label: widget.label,
      liveRegion: true,
      child: AnimatedBuilder(
        animation: motion,
        builder: (context, _) {
          final elapsed =
              motion.lastElapsedDuration?.inMilliseconds.toDouble() ?? 0;
          final gather = reduced ? 1.0 : (elapsed / 750).clamp(0.0, 1.0);
          return Material(
            color: FurUColors.cream.withValues(
              alpha: reduced ? 1 : (elapsed / 260).clamp(0.0, 1.0),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ExcludeSemantics(
                  child: CustomPaint(
                    painter: _MorphPainter(
                      widget.sections,
                      gather,
                      reduced
                          ? 0
                          : math.max(0, elapsed - 750) / 1600 * math.pi * 2,
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 200,
                      left: 24,
                      right: 24,
                    ),
                    child: Opacity(
                      opacity: gather,
                      child: Text(
                        widget.label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: FurUColors.forest,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}

class _MorphPainter extends CustomPainter {
  final List<Rect> sections;
  final double gather, rotation;
  _MorphPainter(this.sections, this.gather, this.rotation);
  @override
  void paint(Canvas canvas, Size size) {
    const count = 12;
    final center = size.center(Offset.zero);
    final paint = Paint()..isAntiAlias = true;
    for (var i = 0; i < count; i++) {
      final t = Curves.easeInOutCubic.transform(
        ((gather - i * .012) / .85).clamp(0.0, 1.0),
      );
      final angle = i * math.pi * 2 / count - math.pi / 2 + rotation;
      final destination =
          center + Offset(math.cos(angle), math.sin(angle)) * 49;
      final source = sections.isEmpty
          ? Rect.fromCenter(
              center: Offset(size.width / 2, 90 + i * 38),
              width: size.width * .7,
              height: 26,
            )
          : sections[i % sections.length];
      final point = Offset.lerp(source.center, destination, t)!;
      final dot = 5.0 + (i / count) * 2;
      final width = source.width * (1 - t) + dot * 2 * t;
      final height = source.height * (1 - t) + dot * 2 * t;
      paint.color = Color.lerp(
        FurUColors.peach.withValues(alpha: .7),
        i.isEven
            ? FurUColors.orange
            : FurUColors.forest.withValues(alpha: .45 + i / count * .5),
        t,
      )!;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: point, width: width, height: height),
          Radius.circular(12 + t * 40),
        ),
        paint,
      );
    }
    if (gather > .9) {
      final icon = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(Icons.pets_rounded.codePoint),
          style: TextStyle(
            fontSize: 30,
            fontFamily: Icons.pets_rounded.fontFamily,
            color: FurUColors.forest,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      icon.paint(canvas, center - Offset(icon.width / 2, icon.height / 2));
    }
  }

  @override
  bool shouldRepaint(_MorphPainter old) =>
      old.gather != gather || old.rotation != rotation;
}
