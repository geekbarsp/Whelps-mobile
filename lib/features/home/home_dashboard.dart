import 'package:flutter/material.dart';

import '../../core/app_controller.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../widgets/components.dart';
import '../applications/activity_screen.dart';
import '../applications/workflow_screen.dart';
import '../pets/pet_detail.dart';
import '../rescue/rescue_screen.dart';

class FurUHomeDashboard extends StatelessWidget {
  final void Function([String species]) onDiscover;

  const FurUHomeDashboard({super.key, required this.onDiscover});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final firstName = app.profile!.name.trim().split(' ').first;
    return PageBody(
      child: ListView(
        key: const PageStorageKey('home-dashboard-scroll'),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          FurUReveal(
            child: Row(
              children: [
                const Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: _PartnershipHeader(),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.outlined(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  ),
                  tooltip: 'Notifications',
                  style: IconButton.styleFrom(
                    backgroundColor: FurUColors.card(context),
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    minimumSize: const Size(48, 48),
                  ),
                  icon: Badge(
                    isLabelVisible:
                        app.notificationsEnabled && app.submissions.isNotEmpty,
                    backgroundColor: const Color(0xFFF16F2A),
                    child: const Icon(Icons.notifications_none_rounded),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          FurUReveal(
            delay: const Duration(milliseconds: 60),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, $firstName  ✦',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Your forever friend\nis waiting.',
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              fontSize: 35,
                              height: 1.04,
                              letterSpacing: -1.4,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Transform.rotate(
                    angle: -.08,
                    child: Text(
                      'Good pets,\nbrighter\ntomorrows  ♡',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.08,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFFFFA552)
                            : const Color(0xFF6D3D27),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          FurUReveal(
            delay: const Duration(milliseconds: 110),
            child: _SearchBar(onTap: onDiscover),
          ),
          const SizedBox(height: 16),
          FurUReveal(
            delay: const Duration(milliseconds: 160),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _DashboardAction(
                    title: 'Adopt',
                    subtitle: 'Find a friend',
                    icon: Icons.pets_rounded,
                    background: const Color(0xFFF3EBDD),
                    onTap: onDiscover,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DashboardAction(
                    title: 'Rehome',
                    subtitle: 'A fresh start',
                    icon: Icons.home_outlined,
                    background: const Color(0xFFFFD7AA),
                    onTap: () => openWorkflow(
                      context,
                      app.newDraft(SubmissionKind.rehome),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DashboardAction(
                    title: 'Rescue',
                    subtitle: 'Find help',
                    icon: Icons.volunteer_activism_outlined,
                    background: const Color(0xFFE8EDF7),
                    onTap: () => openRescue(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          FurUReveal(
            delay: const Duration(milliseconds: 220),
            child: _EditorialHero(onBrowse: onDiscover),
          ),
          const SizedBox(height: 18),
          _CategoryRail(onDiscover: onDiscover),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Ready for a new start',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontSize: 23),
                ),
              ),
              TextButton.icon(
                onPressed: onDiscover,
                label: const Text('See all'),
                icon: const Icon(Icons.arrow_forward_rounded, size: 17),
                iconAlignment: IconAlignment.end,
              ),
            ],
          ),
          const SizedBox(height: 10),
          _FeaturedPets(
            pets: app.pets
                .where((pet) => pet.availability == PetAvailability.available)
                .take(2)
                .toList(),
          ),
          const SizedBox(height: 18),
          _RehomeBanner(
            onTap: () =>
                openWorkflow(context, app.newDraft(SubmissionKind.rehome)),
          ),
          const SizedBox(height: 18),
          const _JourneyCard(),
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: () => _showStory(context),
            icon: const Icon(Icons.favorite_border_rounded, size: 18),
            label: const Text('Our story · FurYou × WHELPS'),
          ),
          const SizedBox(height: 4),
          OutlinedButton.icon(
            onPressed: () => openRescue(context),
            icon: const Icon(Icons.support_agent_rounded, size: 19),
            label: const Text('Contact for Rescue'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              side: BorderSide(color: Theme.of(context).colorScheme.outline),
              backgroundColor: FurUColors.card(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _PartnershipHeader extends StatelessWidget {
  const _PartnershipHeader();

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              style: const TextStyle(
                fontFamily: 'Fraunces',
                fontSize: 27,
                height: .9,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.4,
              ),
              children: [
                TextSpan(
                  text: 'Fur',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const TextSpan(
                  text: 'You',
                  style: TextStyle(color: Color(0xFFFF8A17)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'WE LOVE THEM LIKE YOU DO',
            style: TextStyle(
              fontSize: 6.4,
              letterSpacing: .25,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9),
        child: Text(
          '×',
          style: TextStyle(
            fontSize: 17,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      SizedBox(
        width: 50,
        height: 47,
        child: ClipRect(
          child: Transform.scale(
            scale: 1.65,
            child: Image.asset(
              'assets/brand/whelps-logo.png',
              width: 36,
              height: 36,
              fit: BoxFit.contain,
              semanticLabel: 'WHELPS',
            ),
          ),
        ),
      ),
    ],
  );
}

class _SearchBar extends StatelessWidget {
  final VoidCallback onTap;
  const _SearchBar({required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
    color: FurUColors.card(context),
    elevation: Theme.of(context).brightness == Brightness.dark ? 0 : 2,
    shadowColor: const Color(0x162C1C12),
    borderRadius: BorderRadius.circular(19),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(19),
      child: SizedBox(
        height: 60,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                size: 27,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  'Find a little love…',
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Icon(
                Icons.tune_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _DashboardAction extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color background;
  final VoidCallback onTap;

  const _DashboardAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.background,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    return FurUPress(
      child: Material(
        color: dark ? scheme.surfaceContainerHigh : background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 142,
            child: Padding(
              padding: const EdgeInsets.all(13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: dark
                          ? scheme.primaryContainer
                          : const Color(0xD9FFFFFF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 24, color: scheme.primary),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: 'Fraunces',
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: scheme.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EditorialHero extends StatelessWidget {
  final VoidCallback onBrowse;
  const _EditorialHero({required this.onBrowse});

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(25),
    child: SizedBox(
      height: 245,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/brand/reference-cat.jpg',
            fit: BoxFit.cover,
            alignment: const Alignment(.15, .05),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xE6422617),
                  Color(0x522E1C12),
                  Color(0x001A100A),
                ],
                stops: [0, .5, 1],
              ),
            ),
          ),
          Positioned(
            left: 18,
            top: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF8F1),
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
                      letterSpacing: 1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Small paws.\nBig love.',
                  style: TextStyle(
                    fontFamily: 'Fraunces',
                    fontSize: 31,
                    height: .94,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Real pets. Brighter tomorrows.',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
                const SizedBox(height: 13),
                FilledButton.icon(
                  onPressed: onBrowse,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text('Meet the pets'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(155, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    backgroundColor: const Color(0xFFFF9628),
                    foregroundColor: const Color(0xFF251B16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _CategoryRail extends StatelessWidget {
  final void Function([String species]) onDiscover;
  const _CategoryRail({required this.onDiscover});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        _CategoryPill(
          label: 'All pets',
          icon: Icons.pets_rounded,
          selected: true,
          onTap: () => onDiscover('All'),
        ),
        const SizedBox(width: 8),
        _CategoryPill(
          label: 'Dogs',
          icon: Icons.pets_outlined,
          onTap: () => onDiscover('Dog'),
        ),
        const SizedBox(width: 8),
        _CategoryPill(
          label: 'Cats',
          icon: Icons.cruelty_free_outlined,
          onTap: () => onDiscover('Cat'),
        ),
      ],
    ),
  );
}

class _CategoryPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryPill({
    required this.label,
    required this.icon,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) => ActionChip(
    onPressed: onTap,
    backgroundColor: selected
        ? Theme.of(context).colorScheme.primaryContainer
        : FurUColors.card(context),
    side: BorderSide.none,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
    avatar: Icon(icon, size: 19, color: Theme.of(context).colorScheme.primary),
    label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
  );
}

class _FeaturedPets extends StatelessWidget {
  final List<Pet> pets;
  const _FeaturedPets({required this.pets});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final stack =
          constraints.maxWidth < 330 ||
          MediaQuery.textScalerOf(context).scale(14) > 19;
      if (stack) {
        return Column(
          children: [
            for (var i = 0; i < pets.length; i++) ...[
              _HomePetCard(pet: pets[i]),
              if (i != pets.length - 1) const SizedBox(height: 14),
            ],
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < pets.length; i++) ...[
            Expanded(child: _HomePetCard(pet: pets[i])),
            if (i != pets.length - 1) const SizedBox(width: 12),
          ],
        ],
      );
    },
  );
}

class _HomePetCard extends StatelessWidget {
  final Pet pet;
  const _HomePetCard({required this.pet});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final saved = app.favorites.contains(pet.id);
    return Material(
      color: FurUColors.card(context),
      borderRadius: BorderRadius.circular(21),
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      shadowColor: const Color(0x152C1C12),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => PetDetail(pet: pet)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 132,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PetImage(pet),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: IconButton.filled(
                      onPressed: () async {
                        try {
                          await app.toggleFavorite(pet.id);
                        } catch (error) {
                          if (context.mounted) showError(context, error);
                        }
                      },
                      tooltip: saved
                          ? 'Unsave ${pet.name}'
                          : 'Save ${pet.name}',
                      style: IconButton.styleFrom(
                        backgroundColor: FurUColors.card(context),
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        minimumSize: const Size(40, 40),
                      ),
                      icon: Icon(
                        saved
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(13, 11, 13, 13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: TextStyle(
                      fontFamily: 'Fraunces',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${pet.age} · ${pet.sex}',
                    style: const TextStyle(fontSize: 11.5),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          pet.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11),
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
    );
  }
}

class _RehomeBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _RehomeBanner({required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.primaryContainer
        : const Color(0xFFFFDAB4),
    borderRadius: BorderRadius.circular(22),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(
              Icons.home_outlined,
              size: 39,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'A fresh start for every pet.',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontFamily: 'Fraunces',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'We’ll guide you, one caring step at a time.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 22,
              backgroundColor: Theme.of(context).colorScheme.surface
                  .withValues(alpha: .72),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _JourneyCard extends StatelessWidget {
  const _JourneyCard();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: FurUColors.card(context),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'A LITTLE CARE. A LIFETIME OF LOVE.',
          style: TextStyle(
            fontSize: 9,
            letterSpacing: 1.2,
            color: Color(0xFFB65318),
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your journey home',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 5),
        const Text('A thoughtful match, one caring step at a time.'),
        const SizedBox(height: 18),
        const _JourneyStep(
          number: '01',
          title: 'Find your companion',
          body: 'Explore profiles, personalities, and care needs.',
        ),
        const _JourneyStep(
          number: '02',
          title: 'Tell us about your home',
          body: 'Create your profile and complete the adoption assessment.',
        ),
        const _JourneyStep(
          number: '03',
          title: 'Review, meet, and welcome',
          body: 'Arrange a meeting and plan a supported transition home.',
          last: true,
        ),
      ],
    ),
  );
}

class _JourneyStep extends StatelessWidget {
  final String number;
  final String title;
  final String body;
  final bool last;

  const _JourneyStep({
    required this.number,
    required this.title,
    required this.body,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: last ? 0 : 15),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFFFD8B0),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: FurUColors.forest,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(body, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ],
    ),
  );
}

void _showStory(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  backgroundColor: Theme.of(context).colorScheme.surface,
  builder: (context) => SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const _PartnershipHeader(),
          const SizedBox(height: 24),
          Text(
            'Every pet deserves\na new beginning.',
            style: TextStyle(
              fontFamily: 'Fraunces',
              fontSize: 29,
              height: 1.08,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'FurYou brings caring families closer to rescued pets. Together with WHELPS, we combine rehabilitation with thoughtful adoption screening.',
          ),
          const SizedBox(height: 20),
          const _JourneyCard(),
        ],
      ),
    ),
  ),
);
