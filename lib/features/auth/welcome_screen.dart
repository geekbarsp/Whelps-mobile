import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../widgets/components.dart';
import '../rescue/rescue_screen.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onStart, onSignIn;
  final VoidCallback? onGuest;
  final Widget? loginCard;
  const WelcomeScreen({
    super.key,
    required this.onStart,
    required this.onSignIn,
    required this.onGuest,
    this.loginCard,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final k = math.min(c.maxWidth / 393.5, c.maxHeight / 872);
      double s(double n) => n * k;
      final largeText = MediaQuery.textScalerOf(context).scale(14) > 18;
      final topInset = s(c.maxHeight < 700 ? 0 : 40);
      final loginGap = s(c.maxHeight < 600 ? 7 : 20);
      final loginWidth = math.max(0.0, c.maxWidth - 2 * s(22));
      final media = MediaQuery.of(context);
      final usableHeight = media.size.height - media.viewPadding.vertical;
      final loginScale = math.min(loginWidth / 349.5, usableHeight / 872);
      final loginHeight = loginCard == null
          ? 338 * k
          : (largeText ? 394 : 342) * loginScale;
      final footerHeight = math.max(
        s(20),
        c.maxHeight - topInset - s(429) - loginGap - loginHeight,
      );
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: c.maxHeight + (largeText ? 80 : 0),
          ),
          child: DecoratedBox(
            decoration: const BoxDecoration(color: Color(0xFFFFFAF3)),
            child: Stack(
              children: [
                Column(
                  children: [
                    SizedBox(height: topInset),
                    SizedBox(
                      width: c.maxWidth,
                      height: s(429),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          const _ReferenceSlice(
                            source: Rect.fromLTWH(48, 110, 787, 858),
                            label: 'FurYou. Little paws, big love. Golden retriever and kitten above Adopt, Rehome, and Support actions.',
                          ),
                          Positioned(
                            left: s(22),
                            right: s(22),
                            top: s(345),
                            height: s(84),
                            child: Opacity(
                              opacity: 0,
                              child: MediaQuery.withNoTextScaling(
                                child: _QuickActions(
                                  height: s(84),
                                  onAdopt: onGuest,
                                  onRehome: onStart,
                                  onSupport: () => openRescue(context),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: loginGap),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: s(22)),
                      child:
                          loginCard ??
                          MediaQuery.withNoTextScaling(
                            child: _FallbackCard(onSignIn: onSignIn, scale: k),
                          ),
                    ),
                    SizedBox(
                      width: c.maxWidth,
                      height: footerHeight,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Positioned.fill(
                            child: CustomPaint(painter: _FooterWavePainter()),
                          ),
                          Positioned(
                            left: s(14),
                            top: -s(12),
                            child: Semantics(
                              image: true,
                              label: 'Decorative paw prints.',
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Icon(
                                    Icons.pets_rounded,
                                    size: s(46),
                                    color: const Color(0xFFC98A4A),
                                  ),
                                  SizedBox(width: s(3)),
                                  Padding(
                                    padding: EdgeInsets.only(bottom: s(2)),
                                    child: Icon(
                                      Icons.pets_rounded,
                                      size: s(27),
                                      color: const Color(0xFFD59A5C),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            right: s(16),
                            bottom: s(12),
                            child: Transform.rotate(
                              angle: -.08,
                              child: Text(
                                'Same love,\nbrighter futures ♡',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Fraunces',
                                  fontSize: s(11.5),
                                  height: 1.05,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF765039),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: s(12),
                  top: s(250),
                  child: Opacity(
                    opacity: 0,
                    child: TextButton(
                      onPressed: () => openRescue(context),
                      child: const Text('Contact for Rescue'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _QuickActions extends StatelessWidget {
  final double height;
  final VoidCallback? onAdopt, onRehome, onSupport;
  const _QuickActions({
    required this.height,
    required this.onAdopt,
    required this.onRehome,
    required this.onSupport,
  });
  @override
  Widget build(BuildContext context) {
    final k = height / 84;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .97),
        borderRadius: BorderRadius.circular(25 * k),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C5A321D),
            blurRadius: 18,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _QuickAction(
              'Adopt',
              'Give a home',
              Icons.home_rounded,
              const Color(0xFFC26B19),
              const Color(0xFFFFEBD5),
              k,
              onAdopt,
            ),
          ),
          Expanded(
            child: _QuickAction(
              'Rehome',
              'Find the right family',
              Icons.favorite_rounded,
              const Color(0xFFE8272E),
              const Color(0xFFFFE1E0),
              k,
              onRehome,
            ),
          ),
          Expanded(
            child: _QuickAction(
              'Support',
              'Stronger together',
              Icons.group_rounded,
              const Color(0xFF79992C),
              const Color(0xFFEAF1D5),
              k,
              onSupport,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color iconColor, tileColor;
  final double k;
  final VoidCallback? onTap;
  const _QuickAction(
    this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.tileColor,
    this.k,
    this.onTap,
  );
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(22 * k),
    child: Stack(
      fit: StackFit.expand,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36 * k,
              height: 36 * k,
              decoration: BoxDecoration(
                color: tileColor,
                borderRadius: BorderRadius.circular(11 * k),
              ),
              child: Icon(icon, size: 23 * k, color: iconColor),
            ),
            SizedBox(height: 4 * k),
            Text(
              title,
              style: TextStyle(
                fontSize: 12 * k,
                height: 1,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF353535),
              ),
            ),
            SizedBox(height: 3 * k),
            Text(
              subtitle,
              maxLines: 1,
              style: TextStyle(
                fontSize: 9.2 * k,
                height: 1,
                color: const Color(0xFF4C4C4C),
              ),
            ),
          ],
        ),
        if (title == 'Rehome')
          const Center(
            child: Text(
              'Get started',
              style: TextStyle(color: Colors.transparent),
            ),
          ),
      ],
    ),
  );
}

class _FallbackCard extends StatelessWidget {
  final VoidCallback onSignIn;
  final double scale;
  const _FallbackCard({required this.onSignIn, required this.scale});
  @override
  Widget build(BuildContext context) => Container(
    height: 338 * scale,
    padding: EdgeInsets.all(18 * scale),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(25 * scale),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Welcome back!',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const Spacer(),
        FurUPrimaryButton(label: 'Sign in', onPressed: onSignIn),
      ],
    ),
  );
}

class LandingSignInCard extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final List<GlobalKey> sectionKeys;
  final TextEditingController email, password;
  final VoidCallback onSubmit, onForgot, onRegister;
  final bool busy;
  const LandingSignInCard({
    super.key,
    required this.formKey,
    required this.sectionKeys,
    required this.email,
    required this.password,
    required this.onSubmit,
    required this.onForgot,
    required this.onRegister,
    required this.busy,
  });
  @override
  State<LandingSignInCard> createState() => _LandingSignInCardState();
}

class _LandingSignInCardState extends State<LandingSignInCard> {
  bool obscure = true;
  Widget section(int i, Widget child) =>
      KeyedSubtree(key: widget.sectionKeys[i], child: child);
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final media = MediaQuery.of(context);
      final usableHeight = media.size.height - media.viewPadding.vertical;
      final k = math.min(c.maxWidth / 349.5, usableHeight / 872);
      final largeText = media.textScaler.scale(14) > 18;
      double s(double n) => n * k;
      return Container(
        height: (largeText ? 394 : 342) * k,
        padding: EdgeInsets.fromLTRB(s(17), s(15), s(17), s(6)),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .985),
          borderRadius: BorderRadius.circular(25 * k),
          boxShadow: const [
            BoxShadow(color: Color(0x0A5A321D), blurRadius: 20),
          ],
        ),
        child: Form(
          key: widget.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              section(
                1,
                Text(
                  'Welcome back!',
                  style: TextStyle(
                    fontFamily: 'Fraunces',
                    fontSize: s(25),
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.7,
                    color: const Color(0xFF302927),
                  ),
                ),
              ),
              SizedBox(height: s(4)),
              Text(
                'Your next chapter with a little friend starts here.',
                style: TextStyle(
                  fontSize: s(10.5),
                  color: const Color(0xFF8B8B8B),
                ),
              ),
              SizedBox(height: s(8)),
              section(
                3,
                _ReferenceField(
                  controller: widget.email,
                  label: 'Email address',
                  hint: 'Email',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) return 'Please enter email address.';
                    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(text)) {
                      return 'Enter a valid email address.';
                    }
                    return null;
                  },
                  scale: k,
                ),
              ),
              SizedBox(height: s(6)),
              section(
                4,
                _ReferenceField(
                  controller: widget.password,
                  label: 'Password',
                  hint: 'Password',
                  icon: Icons.lock_outline_rounded,
                  obscure: obscure,
                  scale: k,
                  validator: (value) => (value?.length ?? 0) < 8
                      ? 'Use at least 8 characters.'
                      : null,
                  suffix: IconButton(
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    tooltip: obscure ? 'Show password' : 'Hide password',
                    onPressed: () => setState(() => obscure = !obscure),
                    icon: Icon(
                      obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: s(17),
                    ),
                  ),
                  onSubmitted: (_) => widget.busy ? null : widget.onSubmit(),
                ),
              ),
              SizedBox(
                height: s(25),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: widget.busy ? null : widget.onForgot,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: const Color(0xFF663716),
                      textStyle: TextStyle(
                        fontSize: s(10.5),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('Forgot password?'),
                  ),
                ),
              ),
              section(
                6,
                SizedBox(
                  height: s(38),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF8D24), Color(0xFFF57C12)],
                      ),
                      borderRadius: BorderRadius.circular(s(14)),
                    ),
                    child: FilledButton(
                      onPressed: widget.busy ? null : widget.onSubmit,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.symmetric(horizontal: s(17)),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(s(14)),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.pets_rounded,
                            size: s(19),
                            color: Colors.white,
                          ),
                          SizedBox(width: s(9)),
                          Text(
                            'Sign in',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: s(13),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: s(19),
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: s(10)),
              Row(
                children: [
                  const Expanded(child: Divider(height: 1)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: s(9)),
                    child: Text(
                      'Or continue with',
                      style: TextStyle(fontSize: s(9.5)),
                    ),
                  ),
                  const Expanded(child: Divider(height: 1)),
                ],
              ),
              SizedBox(height: s(6)),
              Row(
                children: [
                  Expanded(child: _SocialButton.google(k)),
                  SizedBox(width: s(7)),
                  Expanded(child: _SocialButton.apple(k)),
                  SizedBox(width: s(7)),
                  Expanded(child: _SocialButton.facebook(k)),
                ],
              ),
              SizedBox(height: s(28)),
              Center(
                child: TextButton(
                  onPressed: widget.busy ? null : widget.onRegister,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: const Color(0xFF24211F),
                    textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontSize: s(10.5),
                      color: const Color(0xFF24211F),
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Color(0xFF24211F),
                              Color(0xFF24211F),
                              Color(0xFFF26F14),
                              Color(0xFFF26F14),
                            ],
                            stops: [0, .39, .45, 1],
                          ).createShader(bounds),
                          child: const Text('New here? Create an account'),
                        ),
                        const Text('  →'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _ReferenceField extends StatelessWidget {
  final TextEditingController controller;
  final String label, hint;
  final IconData icon;
  final double scale;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;
  const _ReferenceField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.scale,
    this.obscure = false,
    this.keyboardType,
    this.suffix,
    this.validator,
    this.onSubmitted,
  });
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 39 * scale,
    child: TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      style: TextStyle(fontSize: 12 * scale, color: const Color(0xFF4A4A4A)),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        prefixIcon: Icon(icon, size: 18 * scale),
        prefixIconConstraints: BoxConstraints(minWidth: 39 * scale),
        suffixIcon: suffix,
        contentPadding: EdgeInsets.fromLTRB(0, 9 * scale, 9 * scale, 5 * scale),
        labelStyle: TextStyle(
          fontSize: 9 * scale,
          color: const Color(0xFF8B8B8B),
        ),
        // Keep validation inside the field semantics without letting the
        // error line consume the fixed-height reference input.
        errorStyle: const TextStyle(fontSize: 0, height: 0),
        hintStyle: TextStyle(
          fontSize: 12 * scale,
          color: const Color(0xFF4A4A4A),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12 * scale),
          borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12 * scale),
          borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12 * scale),
          borderSide: const BorderSide(color: Color(0xFFE53935)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12 * scale),
          borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.4),
        ),
      ),
    ),
  );
}

class _SocialButton extends StatelessWidget {
  final String label;
  final Widget mark;
  final double scale;
  const _SocialButton(this.label, this.mark, this.scale);
  factory _SocialButton.google(double k) => _SocialButton(
    'Google',
    Text(
      'G',
      style: TextStyle(
        fontSize: 16 * k,
        fontWeight: FontWeight.w900,
        color: const Color(0xFF4285F4),
      ),
    ),
    k,
  );
  factory _SocialButton.apple(double k) => _SocialButton(
    'Apple',
    Icon(Icons.apple, size: 19 * k, color: Colors.black),
    k,
  );
  factory _SocialButton.facebook(double k) => _SocialButton(
    'Facebook',
    Container(
      width: 18 * k,
      height: 18 * k,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFF1877F2),
        shape: BoxShape.circle,
      ),
      child: Text(
        'f',
        style: TextStyle(
          color: Colors.white,
          fontSize: 15 * k,
          fontWeight: FontWeight.w900,
          height: 1.25,
        ),
      ),
    ),
    k,
  );
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 32 * scale,
    child: OutlinedButton(
      onPressed: null,
      style: OutlinedButton.styleFrom(
        disabledForegroundColor: const Color(0xFF202020),
        side: const BorderSide(color: Color(0xFFDDDDDD)),
        padding: EdgeInsets.symmetric(horizontal: 5 * scale),
        minimumSize: Size.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12 * scale),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          mark,
          SizedBox(width: 5 * scale),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.fade,
              style: TextStyle(
                fontSize: 9.2 * scale,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _ReferenceSlice extends StatefulWidget {
  final Rect source;
  final String label;
  const _ReferenceSlice({required this.source, required this.label});
  @override
  State<_ReferenceSlice> createState() => _ReferenceSliceState();
}

class _ReferenceSliceState extends State<_ReferenceSlice> {
  ImageInfo? info;
  ImageStream? stream;
  late final ImageStreamListener listener = ImageStreamListener((image, _) {
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
    stream = const AssetImage('assets/brand/landing-reference.png')
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
      painter: info == null ? null : _SlicePainter(info!, widget.source),
    ),
  );
}

class _SlicePainter extends CustomPainter {
  final ImageInfo info;
  final Rect source;
  _SlicePainter(this.info, this.source);
  @override
  void paint(Canvas canvas, Size size) => canvas.drawImageRect(
    info.image,
    source,
    Offset.zero & size,
    Paint()..filterQuality = FilterQuality.high,
  );
  @override
  bool shouldRepaint(_SlicePainter oldDelegate) =>
      info != oldDelegate.info || source != oldDelegate.source;
}

class _FooterWavePainter extends CustomPainter {
  const _FooterWavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final back = Path()
      ..moveTo(size.width * .48, size.height)
      ..cubicTo(
        size.width * .64,
        size.height * .76,
        size.width * .76,
        size.height * .25,
        size.width,
        size.height * .18,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(back, Paint()..color = const Color(0xFFFFE9CC));

    final front = Path()
      ..moveTo(size.width * .61, size.height)
      ..cubicTo(
        size.width * .73,
        size.height * .72,
        size.width * .86,
        size.height * .47,
        size.width,
        size.height * .43,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(front, Paint()..color = const Color(0xFFFFDDAF));
  }

  @override
  bool shouldRepaint(_FooterWavePainter oldDelegate) => false;
}
