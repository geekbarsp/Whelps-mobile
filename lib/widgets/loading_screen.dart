import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'components.dart';

/// The puppy's journey follows real initialization progress, never a timer.
class FurULoadingScreen extends StatefulWidget {
  final double progress;
  const FurULoadingScreen({super.key, required this.progress});
  @override
  State<FurULoadingScreen> createState() => _FurULoadingScreenState();
}

class _FurULoadingScreenState extends State<FurULoadingScreen>
    with SingleTickerProviderStateMixin {
  bool _arrived = false;
  late final AnimationController _motion = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncMotion();
  }

  @override
  void didUpdateWidget(covariant FurULoadingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.progress < 1) _arrived = false;
    _syncMotion();
  }

  void _syncMotion() {
    if (MediaQuery.disableAnimationsOf(context) ||
        (_arrived && widget.progress >= 1)) {
      _motion.stop();
    } else if (!_motion.isAnimating) {
      _motion.repeat();
    }
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;
    final target = widget.progress.isFinite
        ? widget.progress.clamp(0.0, 1.0)
        : 0.0;
    final reduced = MediaQuery.disableAnimationsOf(context);
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: dark
                ? const [Color(0xFF241811), Color(0xFF130E0B)]
                : const [Color(0xFFFFFAF2), Color(0xFFF7EEDD)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, bounds) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: bounds.maxHeight),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 460),
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Brand(small: true),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'SMALL PAWS. BIG POSSIBILITIES.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.8,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 24),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: target),
                          onEnd: () {
                            if (target >= 1) {
                              _arrived = true;
                              _syncMotion();
                            }
                          },
                          duration: reduced
                              ? Duration.zero
                              : const Duration(milliseconds: 900),
                          curve: Curves.easeInOutCubic,
                          builder: (context, progress, _) => Column(
                            children: [
                              ExcludeSemantics(
                                child: RepaintBoundary(
                                  child: AspectRatio(
                                    aspectRatio: 380 / 310,
                                    child: AnimatedBuilder(
                                      animation: _motion,
                                      builder: (context, _) => CustomPaint(
                                        painter: _HomeJourneyPainter(
                                          progress: progress,
                                          phase: reduced || progress >= 1
                                              ? 0
                                              : _motion.value,
                                          dark: dark,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'A little closer\nto home.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headlineLarge
                                    ?.copyWith(
                                      fontSize: 36,
                                      height: 1.08,
                                      letterSpacing: -1.2,
                                    ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Good things come on little paws.\nYour FurU world is almost ready.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.6,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 28),
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: dark
                                      ? const Color(0xFF30221A)
                                      : Colors.white.withValues(alpha: .78),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: dark
                                        ? colors.outlineVariant
                                        : const Color(0xFFF0E3D2),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            target >= 1
                                                ? 'Welcome home'
                                                : target >= .5
                                                ? 'Getting your space ready'
                                                : 'Finding your companions',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 13,
                                              color: colors.onSurface,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          '${(progress * 100).round()}%',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: colors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 7,
                                      borderRadius: BorderRadius.circular(10),
                                      color: colors.primary,
                                      backgroundColor: dark
                                          ? const Color(0xFF4B3526)
                                          : const Color(0xFFF0E6D7),
                                      semanticsLabel: 'Loading FurU',
                                      semanticsValue:
                                          '${(progress * 100).round()}',
                                    ),
                                    const SizedBox(height: 14),
                                    Row(
                                      children: [
                                        Icon(
                                          target >= 1
                                              ? Icons.check_circle_rounded
                                              : Icons.favorite_rounded,
                                          size: 14,
                                          color: colors.primary,
                                        ),
                                        const SizedBox(width: 7),
                                        Expanded(
                                          child: Text(
                                            target >= 1
                                                ? 'Everything is ready for you.'
                                                : 'A new beginning is worth the wait.',
                                            style: TextStyle(
                                              fontSize: 11,
                                              height: 1.4,
                                              color: colors.onSurfaceVariant,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.pets_rounded,
                              size: 13,
                              color: colors.primary.withValues(alpha: .65),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Every paw deserves a place to call home.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10,
                                  height: 1.5,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Layered vector art stays crisp on phones and can animate without bitmap frames.
class _HomeJourneyPainter extends CustomPainter {
  final double progress, phase;
  final bool dark;
  const _HomeJourneyPainter({
    required this.progress,
    required this.phase,
    required this.dark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 380, size.height / 310);
    final ink = Paint()..isAntiAlias = true;
    void oval(double x, double y, double w, double h, Color c) =>
        canvas.drawOval(Rect.fromLTWH(x, y, w, h), ink..color = c);
    void round(Rect rect, double radius, Color c) => canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      ink..color = c,
    );
    void stroke(Path path, Color c, double width) => canvas.drawPath(
      path,
      Paint()
        ..color = c
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    void line(Offset a, Offset b, Color c, double width) => stroke(
      Path()
        ..moveTo(a.dx, a.dy)
        ..lineTo(b.dx, b.dy),
      c,
      width,
    );
    void heart(Offset at, double scale, Color c) {
      canvas.save();
      canvas.translate(at.dx, at.dy);
      canvas.scale(scale);
      canvas.drawPath(
        Path()
          ..moveTo(0, 5)
          ..cubicTo(-18, -6, -11, -17, 0, -9)
          ..cubicTo(11, -17, 18, -6, 0, 5)
          ..close(),
        ink..color = c,
      );
      canvas.restore();
    }

    void cloud(double x, double y, double scale) {
      canvas.save();
      canvas.translate(x, y);
      canvas.scale(scale);
      final c = dark ? const Color(0xFF62554D) : const Color(0xFFFFFCF5);
      oval(0, 14, 56, 17, c);
      oval(10, 4, 27, 25, c);
      oval(28, 9, 22, 22, c);
      canvas.restore();
    }

    final sky = RRect.fromRectAndCorners(
      const Rect.fromLTWH(25, 12, 330, 253),
      topLeft: const Radius.circular(165),
      topRight: const Radius.circular(165),
      bottomLeft: const Radius.circular(34),
      bottomRight: const Radius.circular(34),
    );
    canvas.save();
    canvas.clipRRect(sky);
    canvas.drawRect(
      const Rect.fromLTWH(25, 12, 330, 253),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: dark
              ? const [Color(0xFF4C3B36), Color(0xFF2C3028)]
              : const [Color(0xFFF5DFC4), Color(0xFFFBF0DD)],
        ).createShader(const Rect.fromLTWH(25, 12, 330, 253)),
    );
    oval(
      111,
      46,
      61,
      61,
      (dark ? const Color(0xFFE9D6AA) : const Color(0xFFFFCF80)).withValues(
        alpha: .24,
      ),
    );
    oval(
      119,
      54,
      45,
      45,
      dark ? const Color(0xFFF3DDB0) : const Color(0xFFF7C873),
    );
    if (dark) oval(129, 48, 39, 39, const Color(0xFF4C3B36));
    cloud(48 + math.sin(phase * math.pi * 2) * 2, 102, .8);
    cloud(245, 68, .65);
    oval(
      -28,
      185,
      280,
      125,
      dark ? const Color(0xFF3B493C) : const Color(0xFFD5DDC3),
    );
    oval(
      150,
      184,
      285,
      140,
      dark ? const Color(0xFF344133) : const Color(0xFFE4E7CD),
    );
    oval(
      -20,
      234,
      430,
      90,
      dark ? const Color(0xFF29382B) : const Color(0xFFC5D1B1),
    );
    canvas.restore();
    // A gently curved path and a trail of little paw prints.
    canvas.drawPath(
      Path()
        ..moveTo(26, 263)
        ..quadraticBezierTo(168, 222, 347, 255)
        ..quadraticBezierTo(312, 293, 60, 282)
        ..close(),
      ink..color = (dark ? const Color(0xFF59483A) : const Color(0xFFEAD3AE)),
    );
    stroke(
      Path()
        ..moveTo(48, 273)
        ..quadraticBezierTo(170, 251, 327, 264),
      dark ? const Color(0xFF74604B) : const Color(0xFFF7E6CA),
      2,
    );
    for (var i = 0; i < 5; i++) {
      final x = 86.0 + i * 32;
      final y = 271.0 - (i.isEven ? 3 : 0);
      final c = (dark ? const Color(0xFFAD8760) : const Color(0xFFBD9367))
          .withValues(alpha: .38);
      oval(x, y, 6, 5, c);
      oval(x - 1, y - 4, 3, 3, c);
      oval(x + 3, y - 5, 3, 3, c);
      oval(x + 6, y - 2, 3, 3, c);
    }
    // Fence and garden frame the scene without competing with the puppy.
    const wood = Color(0xFFF1DFC5);
    for (var i = 0; i < 5; i++) {
      round(
        Rect.fromLTWH(40 + i * 15, 190, 6, 49),
        3,
        dark ? const Color(0xFF847464) : wood,
      );
    }
    line(
      const Offset(38, 206),
      const Offset(108, 206),
      dark ? const Color(0xFF96816C) : const Color(0xFFFFF2DC),
      4,
    );
    line(
      const Offset(38, 224),
      const Offset(108, 224),
      dark ? const Color(0xFF96816C) : const Color(0xFFFFF2DC),
      4,
    );
    void plant(double x, double y, double scale) {
      canvas.save();
      canvas.translate(x, y);
      canvas.scale(scale);
      const leaf = Color(0xFF819A70);
      line(Offset.zero, const Offset(0, -43), const Color(0xFF667F58), 3);
      canvas.save();
      canvas.rotate(-.6);
      oval(-17, -38, 17, 29, leaf);
      canvas.restore();
      canvas.save();
      canvas.rotate(.65);
      oval(0, -30, 15, 26, const Color(0xFFA0B18A));
      canvas.restore();
      canvas.restore();
    }

    plant(32, 255, .85);
    plant(352, 253, .9);
    // Cottage: roof edging, timber seams, a window and a glowing arched doorway.
    oval(244, 247, 107, 15, Colors.black.withValues(alpha: .09));
    round(const Rect.fromLTWH(253, 153, 91, 98), 9, const Color(0xFFEFC08A));
    round(const Rect.fromLTWH(260, 153, 77, 96), 4, const Color(0xFFF8D8AA));
    for (var y = 170.0; y < 245; y += 17) {
      line(Offset(262, y), Offset(336, y), const Color(0xFFEBC79C), 1);
    }
    round(const Rect.fromLTWH(319, 112, 13, 39), 3, const Color(0xFFB86D41));
    final roof = Path()
      ..moveTo(242, 159)
      ..lineTo(298, 105)
      ..lineTo(355, 159)
      ..close();
    canvas.drawPath(roof, ink..color = const Color(0xFFA35B35));
    stroke(
      Path()
        ..moveTo(240, 157)
        ..lineTo(298, 103)
        ..lineTo(357, 157),
      const Color(0xFF754126),
      7,
    );
    stroke(
      Path()
        ..moveTo(251, 158)
        ..lineTo(298, 114)
        ..lineTo(345, 158),
      const Color(0xFFD49A68),
      2,
    );
    round(const Rect.fromLTWH(278, 194, 42, 58), 20, const Color(0xFFCF9D6E));
    final doorway = const BorderRadius.vertical(top: Radius.circular(18))
        .toRRect(const Rect.fromLTWH(282, 198, 34, 55));
    canvas.drawRRect(doorway, ink..color = const Color(0xFF69432E));
    round(const Rect.fromLTWH(277, 246, 45, 6), 2, const Color(0xFFC59260));
    oval(289, 166, 19, 19, const Color(0xFFA6754D));
    oval(292, 169, 13, 13, const Color(0xFFFFEDB5));
    line(
      const Offset(299, 169),
      const Offset(299, 182),
      const Color(0xFFA6754D),
      2,
    );
    line(
      const Offset(292, 176),
      const Offset(305, 176),
      const Color(0xFFA6754D),
      2,
    );
    // Puppy: articulated gait, soft muzzle, floppy ears and a little collar tag.
    final stride = math.sin(phase * math.pi * 2) * (progress < 1 ? 1 : 0);
    final x = 68 + progress * 185;
    oval(x - 26, 246, 67, 9, Colors.black.withValues(alpha: .11));
    canvas.save();
    canvas.translate(x, 225 - stride.abs() * 3);
    const fur = Color(0xFFCB8B4B),
        shade = Color(0xFFA46836),
        light = Color(0xFFF0C48B);
    for (var i = 0; i < 4; i++) {
      final hip = i < 2 ? -14.0 : 19.0;
      final swing = stride * (i.isEven ? 10 : -10);
      stroke(
        Path()
          ..moveTo(hip, 5)
          ..lineTo(hip + swing * .7, 16)
          ..lineTo(hip + swing, 24)
          ..lineTo(hip + swing + 6, 24),
        i.isEven ? shade : fur,
        7,
      );
    }
    stroke(
      Path()
        ..moveTo(-24, -3)
        ..quadraticBezierTo(-44, -13, -39, -27 + stride * 6),
      fur,
      8,
    );
    oval(-29, -17, 66, 35, fur);
    oval(-12, -11, 38, 20, const Color(0xFFD99C59));
    oval(13, -41, 35, 41, fur);
    oval(27, -26, 29, 23, light);
    oval(49, -27, 10, 8, const Color(0xFF3C2C23));
    canvas.save();
    canvas.translate(18, -37);
    canvas.rotate(-.15 + stride * .12);
    oval(-5, -1, 17, 33, shade);
    oval(-2, 2, 10, 25, const Color(0xFFB3743C));
    canvas.restore();
    oval(37, -34, 5, 6, const Color(0xFF35261E));
    oval(38, -34, 1.5, 1.5, Colors.white);
    stroke(
      Path()
        ..moveTo(43, -13)
        ..quadraticBezierTo(48, -9, 51, -14),
      const Color(0xFF9C6139),
      1.5,
    );
    oval(43, -9, 6, 9, const Color(0xFFD78979));
    line(
      const Offset(22, -4),
      const Offset(38, -8),
      const Color(0xFF668A72),
      5,
    );
    oval(31, -3, 6, 8, const Color(0xFFFFD278));
    canvas.restore();
    heart(
      Offset(218, 132 + math.sin(phase * math.pi * 2) * 3),
      .8,
      const Color(0xFFD38E6D).withValues(alpha: .75),
    );
    if (progress > .92) {
      heart(const Offset(298, 94), .6, const Color(0xFFE7AD65));
    }
    // Tiny glints give the illustration a warm storybook finish.
    for (final p in [const Offset(77, 61), const Offset(331, 91)]) {
      line(
        p - const Offset(3, 0),
        p + const Offset(3, 0),
        const Color(0xFFCFA477),
        1.5,
      );
      line(
        p - const Offset(0, 3),
        p + const Offset(0, 3),
        const Color(0xFFCFA477),
        1.5,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_HomeJourneyPainter old) =>
      progress != old.progress || phase != old.phase || dark != old.dark;
}
