import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'components.dart';

/// A single, quiet camera move that settles; no perpetual background ticker.
class CompanionPortrait extends StatelessWidget {
  final double height;
  final bool compact;
  final VoidCallback? onBrowse;
  const CompanionPortrait({
    super.key,
    this.height = 300,
    this.compact = false,
    this.onBrowse,
  });

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(30),
    child: SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 1.07, end: 1),
            duration: motionDuration(
              context,
              const Duration(milliseconds: 1400),
            ),
            curve: Curves.easeOutCubic,
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: Image.asset(
              'assets/brand/reference-cat.jpg',
              fit: BoxFit.cover,
              alignment: const Alignment(0, .05),
              semanticLabel: 'A rescued tabby, from the FurYou desktop design',
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x10000000),
                  Color(0x00000000),
                  Color(0xD930251E),
                ],
                stops: [0, .42, 1],
              ),
            ),
          ),
          Positioned(
            left: 18,
            top: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: FurUColors.cream,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.pets_rounded, size: 14, color: FurUColors.forest),
                  SizedBox(width: 7),
                  Text(
                    'A SECOND CHANCE',
                    style: TextStyle(
                      fontSize: 9,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w800,
                      color: FurUColors.ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: FurUReveal(
              delay: const Duration(milliseconds: 200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    compact
                        ? 'Small paws. Big love.'
                        : 'Some love is meant to find you.',
                    style: const TextStyle(
                      fontFamily: 'Fraunces',
                      fontSize: 23,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.12,
                    ),
                  ),
                  if (onBrowse != null) ...[
                    const SizedBox(height: 12),
                    FurUPress(
                      child: FilledButton.icon(
                        onPressed: onBrowse,
                        icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                        label: const Text('Meet the pets'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(48, 48),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class AdoptionJourney extends StatelessWidget {
  const AdoptionJourney({super.key});

  @override
  Widget build(BuildContext context) => FurUSectionCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'A LITTLE CARE. A LIFETIME OF LOVE.',
          style: TextStyle(
            fontSize: 9,
            letterSpacing: 1.3,
            color: FurUColors.forest,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Your journey home',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        const Text('A thoughtful match, one caring step at a time.'),
        const SizedBox(height: 16),
        for (final step in [
          (
            '01',
            'Find your companion',
            'Explore pet profiles, personalities, and care needs.',
          ),
          (
            '02',
            'Tell us about your home',
            'Create your profile and complete the adoption assessment.',
          ),
          (
            '03',
            'Review, meet, and welcome',
            'After approval, arrange a meeting and plan a supported transition home.',
          ),
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: FurUColors.peach,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    step.$1,
                    style: const TextStyle(
                      color: FurUColors.forest,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.$2,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: FurUColors.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(step.$3, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

void showOurStory(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  backgroundColor: FurUColors.cream,
  builder: (context) => SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Brand(),
          const SizedBox(height: 24),
          Text(
            'Every pet deserves\na new beginning.',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          const Text(
            'FurYou brings caring families closer to rescued pets. The FurYou × WHELPS vision combines animal rescue and rehabilitation with thoughtful adoption screening.',
          ),
          const SizedBox(height: 18),
          const AdoptionJourney(),
          const SizedBox(height: 20),
          FurUPrimaryButton(
            label: 'Back to the pets',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    ),
  ),
);
