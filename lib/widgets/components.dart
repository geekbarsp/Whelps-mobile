import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/models.dart';

Duration motionDuration(BuildContext context, Duration duration) =>
    MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;

class FurUReveal extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Offset beginOffset;

  const FurUReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.beginOffset = const Offset(0, .06),
  });

  @override
  State<FurUReveal> createState() => _FurURevealState();
}

class _FurURevealState extends State<FurUReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  late final Animation<double> opacity = CurvedAnimation(
    parent: controller,
    curve: Curves.easeOutCubic,
  );
  late final Animation<Offset> position = Tween<Offset>(
    begin: widget.beginOffset,
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic));
  Timer? timer;
  bool started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (started) return;
    started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      controller.value = 1;
    } else {
      timer = Timer(widget.delay, () {
        if (mounted) controller.forward();
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: opacity,
    child: SlideTransition(position: position, child: widget.child),
  );
}

void showError(BuildContext context, Object error) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(error.toString().replaceFirst('Bad state: ', '')),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

class Brand extends StatelessWidget {
  final bool small;
  const Brand({super.key, this.small = false});
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'FurYou and WHELPS. We love them like you do.',
    image: true,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: FurUColors.cocoa,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/brand/furyou-logo.png',
            width: small ? 100 : 126,
            excludeFromSemantics: true,
            filterQuality: FilterQuality.high,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 7),
            child: Text(
              '×',
              style: TextStyle(color: FurUColors.orange, fontSize: 14),
            ),
          ),
          ClipRect(
            child: Transform.scale(
              scale: 1.65,
              child: Image.asset(
                'assets/brand/whelps-logo.png',
                width: small ? 36 : 42,
                height: small ? 36 : 42,
                excludeFromSemantics: true,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// A short tactile response, without delaying or intercepting the action.
class FurUPress extends StatefulWidget {
  final Widget child;
  const FurUPress({super.key, required this.child});
  @override
  State<FurUPress> createState() => _FurUPressState();
}

class _FurUPressState extends State<FurUPress> {
  bool down = false;
  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: (_) => setState(() => down = true),
    onPointerUp: (_) => setState(() => down = false),
    onPointerCancel: (_) => setState(() => down = false),
    child: AnimatedScale(
      scale: down ? .97 : 1,
      duration: motionDuration(context, const Duration(milliseconds: 160)),
      curve: Curves.easeOutCubic,
      child: widget.child,
    ),
  );
}

class FurUPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final IconData? icon;
  const FurUPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
    this.icon,
  });
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: FurUPress(
      child: FilledButton(
        onPressed: busy ? null : onPressed,
        child: busy
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                children: [
                  Text(label, textAlign: TextAlign.center),
                  if (icon != null) Icon(icon, size: 20),
                ],
              ),
      ),
    ),
  );
}

class FurUTextField extends StatelessWidget {
  final String label;
  final String? initialValue, hint;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final bool required, obscure;
  final int lines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  const FurUTextField({
    super.key,
    required this.label,
    this.initialValue,
    this.hint,
    this.onChanged,
    this.controller,
    this.required = true,
    this.obscure = false,
    this.lines = 1,
    this.keyboardType,
    this.validator,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      onChanged: onChanged,
      obscureText: obscure,
      maxLines: lines,
      keyboardType: keyboardType,
      textInputAction: lines > 1
          ? TextInputAction.newline
          : TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: lines > 1,
      ),
      validator:
          validator ??
          (value) {
            if (required && (value == null || value.trim().isEmpty)) {
              return 'Please enter ${label.toLowerCase()}.';
            }
            if (value == null || value.isEmpty) return null;
            if (keyboardType == TextInputType.emailAddress &&
                !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim())) {
              return 'Enter a valid email address.';
            }
            if (keyboardType == TextInputType.phone &&
                value.replaceAll(RegExp(r'\D'), '').length < 7) {
              return 'Enter a valid phone number.';
            }
            return null;
          },
    ),
  );
}

class FurUDropdown extends StatelessWidget {
  final String label;
  final List<String> options;
  final String? value;
  final ValueChanged<String?> onChanged;
  const FurUDropdown({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: DropdownButtonFormField<String>(
      initialValue: options.contains(value) ? value : null,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: options
          .map(
            (o) => DropdownMenuItem(
              value: o,
              child: Text(o, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? 'Choose ${label.toLowerCase()}.' : null,
    ),
  );
}

class FurUSectionCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  const FurUSectionCard({super.key, required this.child, this.color});
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: dark && color != null
          ? Color.alphaBlend(color!.withValues(alpha: .12), scheme.surface)
          : color ?? scheme.surface,
      elevation: dark ? 0 : 1,
      shadowColor: const Color(0x14203B32),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: dark ? const Color(0xFF49372E) : const Color(0xFFE7E9E1),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: const EdgeInsets.all(20), child: child),
    );
  }
}

class FurUStatusBadge extends StatelessWidget {
  final String label;
  const FurUStatusBadge(this.label, {super.key});
  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (label) {
      'Rejected' => (const Color(0xFFF8E4E1), const Color(0xFF8B3029)),
      'Cancelled' => (const Color(0xFFECEDEA), const Color(0xFF5F665F)),
      'Draft' => (const Color(0xFFECEDEA), const Color(0xFF4D5952)),
      'Submitted' => (const Color(0xFFE5ECF7), const Color(0xFF315986)),
      'Under review' ||
      'Review requested' => (const Color(0xFFFFEBCB), const Color(0xFF7D5518)),
      'Approved' ||
      'Available' ||
      'Verified' => (const Color(0xFFDCECDF), FurUColors.forest),
      'Admin' => (const Color(0xFFFFE0BF), const Color(0xFF8A3D0B)),
      'Pending adoption' => (const Color(0xFFFFEBCB), const Color(0xFF7D5518)),
      'Adopted' => (const Color(0xFFDDE8F5), const Color(0xFF315986)),
      'Unavailable' => (const Color(0xFFE4E0DE), const Color(0xFF5F5652)),
      _ => (FurUColors.sage, FurUColors.forest),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: foreground,
        ),
      ),
    );
  }
}

class PetImage extends StatelessWidget {
  final Pet pet;
  const PetImage(this.pet, {super.key});

  Widget _fallback(BuildContext context) => ColoredBox(
    color: Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.surfaceContainerHigh
        : FurUColors.sage,
    child: const Center(
      child: Icon(Icons.pets, size: 64, color: FurUColors.forest),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final label = '${pet.name}, ${pet.breed}';
    final photo = pet.photo.trim();
    if (photo.startsWith('https://') || photo.startsWith('http://')) {
      return Image.network(
        photo,
        fit: BoxFit.cover,
        semanticLabel: label,
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : Stack(
                fit: StackFit.expand,
                children: [
                  _fallback(context),
                  const Center(
                    child: SizedBox.square(
                      dimension: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ],
              ),
        errorBuilder: (context, _, _) => _fallback(context),
      );
    }
    if (photo.startsWith('data:image/')) {
      try {
        final bytes = Uri.parse(photo).data?.contentAsBytes();
        if (bytes != null) {
          return Image.memory(
            bytes,
            fit: BoxFit.cover,
            semanticLabel: label,
            errorBuilder: (context, _, _) => _fallback(context),
          );
        }
      } on FormatException {
        return _fallback(context);
      }
    }
    return Image.asset(
      photo,
      fit: BoxFit.cover,
      semanticLabel: label,
      errorBuilder: (context, _, _) => _fallback(context),
    );
  }
}

class FurUPetCard extends StatelessWidget {
  final Pet pet;
  final bool saved;
  final VoidCallback onTap, onFavorite;
  const FurUPetCard({
    super.key,
    required this.pet,
    required this.saved,
    required this.onTap,
    required this.onFavorite,
  });
  @override
  Widget build(BuildContext context) => FurUPress(
    child: Material(
      color: FurUColors.card(context),
      elevation: Theme.of(context).brightness == Brightness.dark ? 0 : 1,
      shadowColor: const Color(0x24203B32),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 1.12,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PetImage(pet),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: IconButton.filledTonal(
                      style: IconButton.styleFrom(
                        backgroundColor: FurUColors.card(context)
                            .withValues(alpha: .94),
                      ),
                      tooltip: saved
                          ? 'Unsave ${pet.name}'
                          : 'Save ${pet.name}',
                      onPressed: onFavorite,
                      icon: AnimatedSwitcher(
                        duration: motionDuration(
                          context,
                          const Duration(milliseconds: 220),
                        ),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                        child: Icon(
                          saved
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          key: ValueKey(saved),
                          color: Theme.of(context).colorScheme.primary,
                          size: 21,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pet.name, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 2),
                  Text(
                    '${pet.age} · ${pet.sex}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: FurUColors.muted,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          pet.location,
                          style: const TextStyle(fontSize: 11),
                          overflow: TextOverflow.ellipsis,
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
    ),
  );
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title, message;
  final Widget? action;
  const EmptyState({
    super.key,
    this.icon = Icons.pets_outlined,
    required this.title,
    required this.message,
    this.action,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 38,
          backgroundColor: FurUColors.sage,
          child: Icon(icon, size: 34, color: FurUColors.forest),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(message, textAlign: TextAlign.center),
        if (action != null) ...[const SizedBox(height: 24), action!],
      ],
    ),
  );
}

class PageBody extends StatelessWidget {
  final Widget child;
  const PageBody({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 760),
      child: child,
    ),
  );
}
