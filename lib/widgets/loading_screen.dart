import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'components.dart';

/// The journey follows initialization progress; the gait is decorative only.
class FurULoadingScreen extends StatefulWidget {
  final double progress;
  const FurULoadingScreen({super.key, required this.progress});

  @override
  State<FurULoadingScreen> createState() => _FurULoadingScreenState();
}

class _FurULoadingScreenState extends State<FurULoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController gait = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 550),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      gait.stop();
    } else {
      gait.repeat();
    }
  }

  @override
  void dispose() {
    gait.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FittedBox(fit: BoxFit.scaleDown, child: Brand()),
                const SizedBox(height: 36),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: widget.progress.clamp(0, 1)),
                  duration: motionDuration(
                    context,
                    const Duration(milliseconds: 1600),
                  ),
                  curve: Curves.easeInOutCubic,
                  builder: (context, progress, _) => Column(
                    children: [
                      ExcludeSemantics(
                        child: AnimatedBuilder(
                          animation: gait,
                          builder: (context, _) => SizedBox(
                            height: 210,
                            width: double.infinity,
                            child: CustomPaint(
                              painter: _JourneyPainter(progress, gait.value),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'On our way home',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'A little closer to a forever friend.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(8),
                        backgroundColor: FurUColors.sage,
                        semanticsLabel: 'Loading FurU',
                      ),
                      const SizedBox(height: 12),
                      Text(
                        progress >= 1
                            ? 'Ready to meet you!'
                            : 'Getting everything ready · ${(progress * 100).round()}%',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _JourneyPainter extends CustomPainter {
  final double progress, phase;
  _JourneyPainter(this.progress, this.phase);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 360, size.height / 210);
    final paint = Paint()..isAntiAlias = true;
    void oval(Rect rect, Color color) {
      canvas.drawOval(rect, paint..color = color);
    }

    void line(Offset a, Offset b, Color color, double width) {
      canvas.drawLine(
        a,
        b,
        Paint()
          ..color = color
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round,
      );
    }

    oval(const Rect.fromLTWH(8, 18, 340, 177), FurUColors.sage);
    oval(const Rect.fromLTWH(17, 172, 333, 20), const Color(0xFFD2DECD));
    oval(const Rect.fromLTWH(48, 45, 35, 16), Colors.white);
    oval(const Rect.fromLTWH(63, 35, 28, 25), Colors.white);
    oval(const Rect.fromLTWH(77, 44, 30, 17), Colors.white);
    // Warm timber house, dark doorway, and a little paw over the entrance.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(253, 96, 86, 82),
        const Radius.circular(5),
      ),
      paint..color = FurUColors.peach,
    );
    final roof = Path()
      ..moveTo(243, 101)
      ..lineTo(296, 54)
      ..lineTo(348, 101)
      ..close();
    canvas.drawPath(roof, paint..color = FurUColors.forest);
    canvas.drawRRect(
      const BorderRadius.vertical(top: Radius.circular(21))
          .toRRect(const Rect.fromLTWH(277, 125, 38, 53)),
      paint..color = const Color(0xFF654B3C),
    );
    oval(const Rect.fromLTWH(292, 104, 9, 7), FurUColors.forest);
    for (var i = 0; i < 3; i++) {
      oval(Rect.fromLTWH(290 + i * 5, 99, 4, 4), FurUColors.forest);
    }
    final x = 37 + progress * 193;
    final stride = math.sin(phase * math.pi * 2) * (progress < 1 ? 1 : 0);
    oval(Rect.fromLTWH(x - 20, 174, 63, 9), const Color(0xFFBACBB5));
    canvas.save();
    canvas.translate(x, 149 - stride.abs() * 4);
    const fur = Color(0xFFBD7B45);
    const dark = Color(0xFF8C5735);
    // Alternating legs and a wagging tail create a looping running gait.
    for (var i = 0; i < 4; i++) {
      final hip = i < 2 ? -10.0 : 20.0;
      final swing = stride * (i.isEven ? 13 : -13);
      line(Offset(hip, 5), Offset(hip + swing, 24), i.isEven ? dark : fur, 7);
      line(
        Offset(hip + swing, 24),
        Offset(hip + swing + 7, 24),
        i.isEven ? dark : fur,
        6,
      );
    }
    line(const Offset(-19, -3), Offset(-33, -20 + stride * 6), fur, 8);
    oval(const Rect.fromLTWH(-24, -15, 58, 31), fur);
    oval(const Rect.fromLTWH(16, -35, 30, 34), fur);
    oval(const Rect.fromLTWH(31, -23, 24, 16), const Color(0xFFE6B783));
    oval(Rect.fromLTWH(14, -35 + stride * 2, 14, 28), dark);
    oval(const Rect.fromLTWH(48, -24, 8, 7), FurUColors.ink);
    oval(const Rect.fromLTWH(35, -29, 4, 5), FurUColors.ink);
    line(const Offset(22, -5), const Offset(36, -9), FurUColors.forest, 5);
    oval(const Rect.fromLTWH(30, -3, 5, 7), const Color(0xFFE4B953));
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(_JourneyPainter oldDelegate) =>
      progress != oldDelegate.progress || phase != oldDelegate.phase;
}
