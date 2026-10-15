import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../widgets/components.dart';

class LoginScreen extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final List<GlobalKey> sectionKeys;
  final TextEditingController email, password;
  final VoidCallback onBack, onSubmit, onForgot, onRegister;
  final bool busy;
  const LoginScreen({
    super.key,
    required this.formKey,
    required this.sectionKeys,
    required this.email,
    required this.password,
    required this.onBack,
    required this.onSubmit,
    required this.onForgot,
    required this.onRegister,
    required this.busy,
  });
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool obscure = true;
  static const accent = Color(0xFFB84E06);
  Widget section(int index, Widget child) =>
      KeyedSubtree(key: widget.sectionKeys[index], child: child);

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final largeText = MediaQuery.textScalerOf(context).scale(14) > 20;
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: CustomPaint(
            painter: const _CreamBackdrop(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 10, 22, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton.filledTonal(
                    onPressed: widget.busy ? null : widget.onBack,
                    tooltip: 'Back to welcome',
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFF3E7D6),
                    ),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  section(
                    0,
                    const Center(
                      child: SizedBox(
                        width: 255,
                        height: 66,
                        child: _ReferenceArt(
                          source: Rect.fromLTWH(232, 185, 474, 110),
                          label: 'FurYou and WHELPS. We love them like you do.',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  section(
                    1,
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(text: 'Welcome back,\n'),
                          TextSpan(
                            text: 'animal lover.',
                            style: const TextStyle(color: accent),
                          ),
                        ],
                      ),
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(fontSize: 31),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Your next chapter with a little friend starts here. 🧡',
                    style: TextStyle(fontSize: 13, height: 1.5),
                  ),
                  SizedBox(
                    height: largeText ? 166 : 140,
                    child: Stack(
                      children: [
                        Positioned(
                          right: -8,
                          bottom: 0,
                          width: constraints.maxWidth < 350 ? 178 : 220,
                          height: constraints.maxWidth < 350 ? 122 : 142,
                          child: ExcludeSemantics(
                            child: ShaderMask(
                              blendMode: BlendMode.dstIn,
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.white,
                                  Colors.white,
                                  Colors.transparent,
                                ],
                                stops: [0, .1, .93, 1],
                              ).createShader(bounds),
                              child: ShaderMask(
                                blendMode: BlendMode.dstIn,
                                shaderCallback: (bounds) =>
                                    const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.white,
                                        Colors.white,
                                        Colors.transparent,
                                      ],
                                      stops: [0, .06, .92, 1],
                                    ).createShader(bounds),
                                child: const _ReferenceArt(
                                  source: Rect.fromLTWH(443, 508, 436, 280),
                                  label: 'A dog cuddling a cat',
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Positioned(
                          left: 4,
                          bottom: 23,
                          child: RotationTransition(
                            turns: AlwaysStoppedAnimation(-.055),
                            child: Text(
                              'Better homes.\nHappier tails.',
                              style: TextStyle(
                                fontFamily: 'Fraunces',
                                fontStyle: FontStyle.italic,
                                fontSize: 12,
                                color: Color(0xFFAA9076),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Form(
                    key: widget.formKey,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(18, 22, 18, 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .94),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0C795A3B),
                            blurRadius: 26,
                            offset: Offset(0, 9),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          section(
                            3,
                            TextFormField(
                              controller: widget.email,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.email],
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Email address',
                                hintText: 'you@example.com',
                                prefixIcon: Icon(Icons.mail_outline_rounded),
                              ),
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Please enter email address.'
                                  : !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                        .hasMatch(v.trim())
                                  ? 'Enter a valid email address.'
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 20),
                          section(
                            4,
                            TextFormField(
                              controller: widget.password,
                              obscureText: obscure,
                              autofillHints: const [AutofillHints.password],
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) =>
                                  widget.busy ? null : widget.onSubmit(),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(
                                  Icons.lock_outline_rounded,
                                ),
                                suffixIcon: IconButton(
                                  tooltip: obscure
                                      ? 'Show password'
                                      : 'Hide password',
                                  onPressed: () =>
                                      setState(() => obscure = !obscure),
                                  icon: Icon(
                                    obscure
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                ),
                              ),
                              validator: (v) => (v?.length ?? 0) < 8
                                  ? 'Use at least 8 characters.'
                                  : null,
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: widget.busy ? null : widget.onForgot,
                              style: TextButton.styleFrom(
                                foregroundColor: accent,
                              ),
                              child: const Text('Forgot password?'),
                            ),
                          ),
                          const SizedBox(height: 4),
                          section(
                            6,
                            FurUPress(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFE68B22),
                                      Color(0xFFC4580A),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(17),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x25C4580A),
                                      blurRadius: 15,
                                      offset: Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: FilledButton.icon(
                                    onPressed: widget.busy
                                        ? null
                                        : widget.onSubmit,
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      shadowColor: Colors.transparent,
                                    ),
                                    iconAlignment: IconAlignment.end,
                                    icon: const Icon(
                                      Icons.arrow_forward_rounded,
                                    ),
                                    label: const Text('Sign in'),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              children: [
                                Expanded(child: Divider()),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text('or'),
                                ),
                                Expanded(child: Divider()),
                              ],
                            ),
                          ),
                          Center(
                            child: TextButton(
                              onPressed: widget.busy ? null : widget.onRegister,
                              style: TextButton.styleFrom(
                                foregroundColor: accent,
                              ),
                              child: const Text(
                                'New here? Create an account',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Icon(
                      Icons.pets_rounded,
                      color: Color(0xFFD9B184),
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'ADOPT  ·  CARE  ·  BRIGHTER TOMORROWS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 1.3,
                        color: FurUColors.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

/// Reuses only the supplied artwork; all controls and text are native widgets.
/// Source pixels remain untouched, and the device frame is never rendered.
class _ReferenceArt extends StatefulWidget {
  final Rect source;
  final String label;
  const _ReferenceArt({required this.source, required this.label});
  @override
  State<_ReferenceArt> createState() => _ReferenceArtState();
}

class _ReferenceArtState extends State<_ReferenceArt> {
  ImageStream? stream;
  ImageInfo? info;
  late final listener = ImageStreamListener((image, _) {
    if (!mounted) {
      image.dispose();
      return;
    }
    setState(() {
      info?.dispose();
      info = image;
    });
  });
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (stream != null) return;
    stream = const AssetImage('assets/brand/login-reference.png')
        .resolve(createLocalImageConfiguration(context));
    stream!.addListener(listener);
  }

  @override
  void dispose() {
    stream?.removeListener(listener);
    info?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: widget.label,
    child: CustomPaint(
      painter: info == null ? null : _ArtPainter(info!, widget.source),
    ),
  );
}

class _ArtPainter extends CustomPainter {
  final ImageInfo info;
  final Rect source;
  _ArtPainter(this.info, this.source);
  @override
  void paint(Canvas canvas, Size size) => canvas.drawImageRect(
    info.image,
    source,
    Offset.zero & size,
    Paint()..filterQuality = FilterQuality.high,
  );
  @override
  bool shouldRepaint(_ArtPainter old) =>
      info != old.info || source != old.source;
}

class _CreamBackdrop extends CustomPainter {
  const _CreamBackdrop();
  @override
  void paint(Canvas canvas, Size size) {
    final paw = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(Icons.pets_rounded.codePoint),
        style: TextStyle(
          fontFamily: Icons.pets_rounded.fontFamily,
          fontSize: 30,
          color: const Color(0x33D9B184),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    paw.paint(canvas, Offset(size.width - 41, 93));
    final paint = Paint()..color = const Color(0xFFF5E7D3);
    final path = Path()
      ..moveTo(0, size.height - 62)
      ..cubicTo(
        size.width * .2,
        size.height - 60,
        size.width * .2,
        size.height,
        size.width * .38,
        size.height,
      )
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
    canvas.drawPath(
      Path()
        ..moveTo(size.width, size.height - 84)
        ..quadraticBezierTo(
          size.width * .83,
          size.height - 85,
          size.width * .69,
          size.height,
        )
        ..lineTo(size.width, size.height)
        ..close(),
      paint,
    );
  }

  @override
  bool shouldRepaint(_CreamBackdrop old) => false;
}
