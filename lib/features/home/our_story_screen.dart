import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../widgets/components.dart';
import '../rescue/rescue_screen.dart';

class OurStoryScreen extends StatelessWidget {
  const OurStoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 315 + ((textScale - 1).clamp(0, 1) * 125),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            foregroundColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: IconButton.filled(
                tooltip: 'Back',
                onPressed: () => Navigator.pop(context),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0x99302119),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/brand/our-story-dogs.webp',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    semanticLabel: 'Three rescued dogs cared for by WHELPS',
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x30190D07), Color(0xD9341B0F)],
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 76, 22, 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _Eyebrow('FURYOU × WHELPS', light: true),
                          const SizedBox(height: 10),
                          Text(
                            'Where happy\nbeginnings start.',
                            textScaler: TextScaler.linear(
                              textScale.clamp(1, 1.2),
                            ),
                            style: const TextStyle(
                              fontFamily: 'Fraunces',
                              fontSize: 37,
                              height: 1.03,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: PageBody(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 30, 18, 38),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _StoryIntroduction(),
                    const SizedBox(height: 34),
                    const _Commitments(),
                    const SizedBox(height: 34),
                    const _ShelterMoment(),
                    const SizedBox(height: 38),
                    const _MissionAndVision(),
                    const SizedBox(height: 40),
                    const _TeamSection(),
                    const SizedBox(height: 40),
                    const _FrequentlyAskedQuestions(),
                    const SizedBox(height: 30),
                    FilledButton.icon(
                      onPressed: () => openRescue(context),
                      icon: const Icon(Icons.support_agent_rounded),
                      label: const Text('Contact WHELPS'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(54),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryIntroduction extends StatelessWidget {
  const _StoryIntroduction();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _Eyebrow('OUR STORY'),
      const SizedBox(height: 9),
      Text(
        'Compassion became a commitment.',
        style: Theme.of(context).textTheme.headlineMedium
            ?.copyWith(fontSize: 29, height: 1.12),
      ),
      const SizedBox(height: 15),
      Text(
        'FurYou was created with WHELPS to protect vulnerable animals and help abused, abandoned, and neglected dogs and cats receive the care they deserve.',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      const SizedBox(height: 12),
      Text(
        'Together, we connect rescue and rehabilitation with responsible families, making adoption more accessible while keeping animal welfare at the center of every decision.',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      const SizedBox(height: 22),
      ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: Image.asset(
            'assets/brand/whelps-team.jpg',
            fit: BoxFit.cover,
            semanticLabel: 'WHELPS team with rescued dogs',
          ),
        ),
      ),
      const SizedBox(height: 10),
      Text(
        'The people behind WHELPS, together with animals in their care.',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ],
  );
}

class _Commitments extends StatelessWidget {
  const _Commitments();

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.health_and_safety_outlined, 'Promote spaying\nand neutering'),
      (
        Icons.volunteer_activism_outlined,
        'Practice responsible\npet ownership',
      ),
      (Icons.campaign_outlined, 'Speak up against\ncruelty'),
      (Icons.home_outlined, 'Support local\nshelters'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How we show up',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 350;
            final itemWidth = wide
                ? (constraints.maxWidth - 12) / 2
                : constraints.maxWidth;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final item in items)
                  SizedBox(
                    width: itemWidth,
                    child: _CommitmentCard(icon: item.$1, title: item.$2),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _CommitmentCard extends StatelessWidget {
  final IconData icon;
  final String title;
  const _CommitmentCard({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minHeight: 132),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: FurUColors.card(context),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: scheme.primary.withValues(alpha: .25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: scheme.primary, size: 26),
          const SizedBox(height: 15),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Fraunces',
              fontWeight: FontWeight.w700,
              height: 1.25,
              fontSize: 16,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShelterMoment extends StatelessWidget {
  const _ShelterMoment();

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(25),
    child: SizedBox(
      height: 260,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/brand/whelps-cats-feeding.jpg',
            fit: BoxFit.cover,
            alignment: const Alignment(0, -.25),
            semanticLabel: 'Cats receiving food at the WHELPS shelter',
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xC92B180F)],
              ),
            ),
          ),
          const Positioned(
            left: 20,
            right: 20,
            bottom: 18,
            child: Text(
              'Care happens in the\nquiet, everyday moments.',
              style: TextStyle(
                fontFamily: 'Fraunces',
                fontSize: 24,
                height: 1.12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _MissionAndVision extends StatelessWidget {
  const _MissionAndVision();

  @override
  Widget build(BuildContext context) => Column(
    children: const [
      _PurposeCard(
        icon: Icons.favorite_rounded,
        label: 'OUR MISSION',
        title: 'Every animal deserves a second chance and a loving home.',
        body: 'We rescue, rehabilitate, and rehome abused, abandoned, and neglected animals while keeping reporting and adoption accessible.',
      ),
      SizedBox(height: 14),
      _PurposeCard(
        icon: Icons.auto_awesome_rounded,
        label: 'OUR VISION',
        title: 'Technology and compassion can create a world without animal suffering.',
      ),
    ],
  );
}

class _PurposeCard extends StatelessWidget {
  final IconData icon;
  final String label, title;
  final String? body;
  const _PurposeCard({
    required this.icon,
    required this.label,
    required this.title,
    this.body,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: dark
            ? Theme.of(context).colorScheme.surfaceContainerHigh
            : const Color(0xFFFFE7CF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 19,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              _Eyebrow(label),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontSize: 22, height: 1.24),
          ),
          if (body != null) ...[
            const SizedBox(height: 12),
            Text(body!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

class _TeamSection extends StatelessWidget {
  const _TeamSection();

  @override
  Widget build(BuildContext context) {
    const roles = [
      (Icons.pets_outlined, 'Rescue Lead'),
      (Icons.medical_services_outlined, 'Veterinary Liaison'),
      (Icons.handshake_outlined, 'Adoption Coordinator'),
      (Icons.groups_outlined, 'Community Manager'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Eyebrow('OUR TEAM'),
        const SizedBox(height: 9),
        Text(
          'People who choose to care.',
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(fontSize: 27),
        ),
        const SizedBox(height: 10),
        Text(
          'The WHELPS team works across rescue, health support, adoption, and community care.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 18),
        for (final role in roles) ...[
          _RoleRow(icon: role.$1, title: role.$2),
          if (role != roles.last) const SizedBox(height: 9),
        ],
      ],
    );
  }
}

class _RoleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  const _RoleRow({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      color: FurUColors.card(context),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Text(
            'WHELPS Volunteer · $title',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

class _FrequentlyAskedQuestions extends StatelessWidget {
  const _FrequentlyAskedQuestions();

  static const items = [
    (
      'What does the name “Whelps” signify?',
      'Whelps reflects our focus on young and vulnerable companion animals while honoring every rescue at every age.',
    ),
    (
      'What animal care standards does WHELPS follow?',
      'Each animal receives appropriate shelter care, health checks, vaccinations, and rehabilitation support before adoption.',
    ),
    (
      'How does rehabilitation work?',
      'Care plans are tailored to each rescue and can include medical treatment, nutrition, socialization, and behavior support.',
    ),
    (
      'How is WHELPS sustained?',
      'Community donations, in-kind supplies, volunteers, and adoption support keep the shelter operating.',
    ),
  ];

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _Eyebrow('QUESTIONS'),
      const SizedBox(height: 9),
      Text(
        'Things people often ask.',
        style: Theme.of(context).textTheme.headlineMedium
            ?.copyWith(fontSize: 27),
      ),
      const SizedBox(height: 16),
      Material(
        color: FurUColors.card(context),
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (var index = 0; index < items.length; index++) ...[
              Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  initiallyExpanded: index == 0,
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 4,
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(18, 0, 48, 18),
                  title: Text(
                    items[index].$1,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        items[index].$2,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
              if (index != items.length - 1)
                Divider(
                  height: 1,
                  indent: 18,
                  endIndent: 18,
                  color: Theme.of(context).colorScheme.outlineVariant
                      .withValues(alpha: .55),
                ),
            ],
          ],
        ),
      ),
    ],
  );
}

class _Eyebrow extends StatelessWidget {
  final String text;
  final bool light;
  const _Eyebrow(this.text, {this.light = false});

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontSize: 10,
      letterSpacing: 1.5,
      fontWeight: FontWeight.w900,
      color: light
          ? const Color(0xFFFFD2A2)
          : Theme.of(context).colorScheme.primary,
    ),
  );
}

void openOurStory(BuildContext context) => Navigator.push(
  context,
  MaterialPageRoute<void>(builder: (_) => const OurStoryScreen()),
);
