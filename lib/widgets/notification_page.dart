import 'package:flutter/material.dart';

import 'components.dart';

/// Shared notification presentation for adopter and administrator bell routes.
class FurUNotificationPage extends StatelessWidget {
  final Widget? child;
  final String emptyMessage;
  const FurUNotificationPage({
    super.key,
    this.child,
    this.emptyMessage =
        'Draft reminders and application updates will appear here.',
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 76,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 6, 12),
          child: IconButton.filledTonal(
            tooltip: 'Back',
            onPressed: () => Navigator.maybePop(context),
            style: IconButton.styleFrom(
              backgroundColor: dark
                  ? const Color(0xFF473125)
                  : const Color(0xFFF6E8D6),
              foregroundColor: Theme.of(context).colorScheme.onSurface,
            ),
            icon: const Icon(Icons.arrow_back_rounded, size: 25),
          ),
        ),
        title: Text(
          'Notifications',
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(fontSize: 26),
        ),
      ),
      body: SafeArea(
        top: false,
        child: PageBody(
          child:
              child ??
              Stack(
                children: [
                  const Positioned.fill(
                    child: IgnorePointer(
                      child: ExcludeSemantics(child: _NotificationPaws()),
                    ),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 470,
                                  ),
                                  child: AspectRatio(
                                    aspectRatio: 1.45,
                                    child: Image.asset(
                                      'assets/brand/notification-sleeping-pets.png',
                                      fit: BoxFit.contain,
                                      excludeFromSemantics: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 22,
                                  ),
                                  child: Text(
                                    'All quiet for now',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          fontSize: 27,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 30,
                                  ),
                                  child: Text(
                                    emptyMessage,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      fontSize: 15,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 55),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
        ),
      ),
    );
  }
}

class _NotificationPaws extends StatelessWidget {
  const _NotificationPaws();
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF6A452C).withValues(alpha: .3)
        : const Color(0xFFF1D5B5).withValues(alpha: .4);
    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        children: [
          for (final paw in [
            (0.77, .12, -.35, 39.0),
            (.07, .32, -.3, 34.0),
            (.12, .81, -.2, 40.0),
            (.83, .92, -.15, 42.0),
          ])
            Positioned(
              left: constraints.maxWidth * paw.$1,
              top: constraints.maxHeight * paw.$2,
              child: Transform.rotate(
                angle: paw.$3,
                child: Icon(Icons.pets_rounded, size: paw.$4, color: color),
              ),
            ),
        ],
      ),
    );
  }
}
