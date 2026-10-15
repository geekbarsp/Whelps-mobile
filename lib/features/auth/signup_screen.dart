import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Functional signup controls over the approved mobile art direction.
/// The crop removes the mock phone bezel and status bar so Android owns them.
class SignupScreen extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final List<GlobalKey> sectionKeys;
  final TextEditingController name;
  final TextEditingController email;
  final TextEditingController password;
  final TextEditingController confirmPassword;
  final bool busy;
  final VoidCallback onBack;
  final VoidCallback onSubmit;

  const SignupScreen({
    super.key,
    required this.formKey,
    required this.sectionKeys,
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.busy,
    required this.onBack,
    required this.onSubmit,
  });

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  static const designWidth = 393.5;
  static const designHeight = 793.0;
  bool hidePassword = true;
  bool hideConfirmation = true;

  Widget section(int index, Widget child) =>
      KeyedSubtree(key: widget.sectionKeys[index], child: child);

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => ColoredBox(
      color: const Color(0xFFFFFBF5),
      child: ClipRect(
        child: Transform.scale(
          scaleX: constraints.maxWidth / designWidth,
          scaleY: constraints.maxHeight / designHeight,
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: designWidth,
            height: designHeight,
            child: Stack(
              children: [
                const Positioned.fill(child: _ApprovedBackground()),
                Positioned(
                  left: 19,
                  top: 4,
                  width: 52,
                  height: 48,
                  child: IconButton(
                    onPressed: widget.busy ? null : widget.onBack,
                    tooltip: 'Back to landing page',
                    color: Colors.transparent,
                    highlightColor: const Color(0x14F28A2B),
                    icon: const SizedBox.expand(),
                  ),
                ),
                Positioned(
                  left: 27,
                  right: 27,
                  top: 244,
                  child: Form(
                    key: widget.formKey,
                    child: Column(
                      children: [
                        section(
                          2,
                          _SignupField(
                            controller: widget.name,
                            label: 'Full name',
                            icon: Icons.person_outline_rounded,
                          ),
                        ),
                        const SizedBox(height: 11),
                        section(
                          3,
                          _SignupField(
                            controller: widget.email,
                            label: 'Email address',
                            icon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              final text = value?.trim() ?? '';
                              if (text.isEmpty) {
                                return 'Please enter email address.';
                              }
                              if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                  .hasMatch(text)) {
                                return 'Enter a valid email address.';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 11),
                        section(
                          4,
                          _SignupField(
                            controller: widget.password,
                            label: 'Password',
                            icon: Icons.lock_outline_rounded,
                            obscure: hidePassword,
                            validator: (value) => (value?.length ?? 0) < 8
                                ? 'Use at least 8 characters.'
                                : null,
                            suffix: _VisibilityButton(
                              hidden: hidePassword,
                              onPressed: () =>
                                  setState(() => hidePassword = !hidePassword),
                            ),
                          ),
                        ),
                        const SizedBox(height: 11),
                        section(
                          5,
                          _SignupField(
                            controller: widget.confirmPassword,
                            label: 'Confirm password',
                            icon: Icons.lock_outline_rounded,
                            obscure: hideConfirmation,
                            validator: (value) => value != widget.password.text
                                ? 'The passwords do not match.'
                                : null,
                            suffix: _VisibilityButton(
                              hidden: hideConfirmation,
                              onPressed: () => setState(
                                () => hideConfirmation = !hideConfirmation,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 25,
                  right: 25,
                  top: 487,
                  height: 49,
                  child: section(
                    6,
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF9B31), Color(0xFFFF8B28)],
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: FilledButton(
                        onPressed: widget.busy ? null : widget.onSubmit,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          disabledBackgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: widget.busy
                            ? const SizedBox.square(
                                dimension: 21,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF27302E),
                                ),
                              )
                            : const Stack(
                                fit: StackFit.expand,
                                children: [
                                  Center(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        'Create account',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF24302F),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 23,
                                      color: Color(0xFF24302F),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 110,
                  right: 110,
                  top: 590,
                  height: 42,
                  child: TextButton(
                    onPressed: widget.busy ? null : widget.onBack,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF8D3F17),
                      overlayColor: Colors.transparent,
                      splashFactory: NoSplash.splashFactory,
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Opacity(
                      opacity: 0,
                      child: Text(
                        'Back to sign in',
                        style: TextStyle(fontSize: 13.5),
                      ),
                    ),
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

class _SignupField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final String? Function(String?)? validator;

  const _SignupField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
    this.suffix,
    this.validator,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 48,
    child: TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator:
          validator ??
          (value) {
            if ((value ?? '').trim().isEmpty) {
              return 'Please enter ${label.toLowerCase()}.';
            }
            return null;
          },
      style: const TextStyle(fontSize: 14, color: Color(0xFF7C6E69)),
      decoration: InputDecoration(
        hintText: label,
        prefixIcon: Icon(icon, size: 23, color: const Color(0xFF998881)),
        prefixIconConstraints: const BoxConstraints(minWidth: 55),
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.fromLTRB(0, 13, 13, 12),
        hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF97847C)),
        errorStyle: const TextStyle(fontSize: 0, height: 0),
        filled: true,
        fillColor: const Color(0xFFFEFEFE),
        border: _border(const Color(0xFFE1DEDD)),
        enabledBorder: _border(const Color(0xFFE1DEDD)),
        focusedBorder: _border(const Color(0xFFF08A2A), 1.4),
        errorBorder: _border(const Color(0xFFE53935), 1.3),
        focusedErrorBorder: _border(const Color(0xFFE53935), 1.4),
      ),
    ),
  );

  static OutlineInputBorder _border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(color: color, width: width),
      );
}

class _VisibilityButton extends StatelessWidget {
  final bool hidden;
  final VoidCallback onPressed;
  const _VisibilityButton({required this.hidden, required this.onPressed});

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: hidden ? 'Show password' : 'Hide password',
    onPressed: onPressed,
    padding: EdgeInsets.zero,
    visualDensity: VisualDensity.compact,
    icon: Icon(
      hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
      size: 23,
      color: const Color(0xFF998881),
    ),
  );
}

class _ApprovedBackground extends StatefulWidget {
  const _ApprovedBackground();
  @override
  State<_ApprovedBackground> createState() => _ApprovedBackgroundState();
}

class _ApprovedBackgroundState extends State<_ApprovedBackground> {
  ImageStream? stream;
  ui.Image? image;
  late final ImageStreamListener listener = ImageStreamListener((info, _) {
    if (!mounted) return;
    setState(() {
      image?.dispose();
      image = info.image.clone();
    });
  });

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (stream != null) return;
    stream = const AssetImage('assets/brand/create-account-reference.png')
        .resolve(createLocalImageConfiguration(context));
    stream!.addListener(listener);
  }

  @override
  void dispose() {
    stream?.removeListener(listener);
    image?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: 'FurYou and WHELPS create account page with dog and cat artwork',
    child: CustomPaint(
      painter: image == null ? null : _ReferencePainter(image!),
    ),
  );
}

class _ReferencePainter extends CustomPainter {
  final ui.Image image;
  const _ReferencePainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    const source = Rect.fromLTWH(95, 105, 755, 1520);
    canvas.drawImageRect(
      image,
      source,
      Offset.zero & size,
      Paint()..filterQuality = FilterQuality.high,
    );
  }

  @override
  bool shouldRepaint(_ReferencePainter oldDelegate) =>
      image != oldDelegate.image;
}
