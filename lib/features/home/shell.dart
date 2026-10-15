import 'package:flutter/material.dart';

import '../../core/app_controller.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../widgets/components.dart';
import '../../widgets/quick_action.dart';
import '../../widgets/brand_experience.dart';
import '../rescue/rescue_screen.dart';
import '../pets/discover_screen.dart';
import '../pets/pet_detail.dart';
import '../applications/activity_screen.dart';
import '../applications/workflow_screen.dart';
import '../profile/profile_screen.dart';
import 'home_dashboard.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int tab = 0;
  String species = 'All';
  late final PageController pageController = PageController();

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void selectTab(int value) {
    setState(() => tab = value);
    if (!pageController.hasClients) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      pageController.jumpToPage(value);
    } else {
      pageController.animateToPage(
        value,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void discover([String value = 'All']) {
    setState(() => species = value);
    selectTab(1);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      bottom: false,
      child: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (value) {
          if (tab != value) setState(() => tab = value);
        },
        children: [
          _KeepAlivePage(child: FurUHomeDashboard(onDiscover: discover)),
          _KeepAlivePage(
            child: DiscoverScreen(
              key: ValueKey(species),
              initialSpecies: species,
            ),
          ),
          _KeepAlivePage(child: ActivityScreen(onDiscover: discover)),
          const _KeepAlivePage(child: ProfileScreen()),
        ],
      ),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: tab,
      onDestinationSelected: selectTab,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.search_rounded),
          label: 'Discover',
        ),
        NavigationDestination(
          icon: Icon(Icons.assignment_outlined),
          selectedIcon: Icon(Icons.assignment_rounded),
          label: 'Activity',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    ),
  );
}

class _KeepAlivePage extends StatefulWidget {
  final Widget child;
  const _KeepAlivePage({required this.child});

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

class HomeScreen extends StatelessWidget {
  final void Function([String species]) onDiscover;
  const HomeScreen({super.key, required this.onDiscover});
  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return PageBody(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
        children: [
          FurUReveal(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Brand(small: true),
                IconButton.outlined(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  ),
                  tooltip: 'Notifications',
                  icon: Badge(
                    isLabelVisible:
                        app.notificationsEnabled && app.submissions.isNotEmpty,
                    child: const Icon(Icons.notifications_none_rounded),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          FurUReveal(
            delay: const Duration(milliseconds: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${app.profile!.name.split(' ').first} ☀',
                  style: const TextStyle(fontSize: 14, color: FurUColors.muted),
                ),
                const SizedBox(height: 7),
                Text(
                  'Your forever friend\nis waiting.',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          FurUReveal(
            delay: const Duration(milliseconds: 120),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onDiscover,
                child: const Padding(
                  padding: EdgeInsets.all(17),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: FurUColors.muted),
                      SizedBox(width: 12),
                      Expanded(child: Text('Find a little love…')),
                      Icon(
                        Icons.tune_rounded,
                        size: 21,
                        color: FurUColors.forest,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          FurUReveal(
            delay: const Duration(milliseconds: 180),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columns = MediaQuery.textScalerOf(context).scale(14) > 20
                    ? 1
                    : 3;
                final width =
                    (constraints.maxWidth - (columns - 1) * 10) / columns;
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    SizedBox(
                      width: width,
                      child: QuickAction(
                        title: 'Adopt',
                        subtitle: 'Find a friend',
                        icon: Icons.favorite_border_rounded,
                        onTap: onDiscover,
                      ),
                    ),
                    SizedBox(
                      width: width,
                      child: QuickAction(
                        title: 'Rehome',
                        subtitle: 'A fresh start',
                        icon: Icons.home_outlined,
                        color: FurUColors.peach,
                        onTap: () => openWorkflow(
                          context,
                          app.newDraft(SubmissionKind.rehome),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: width,
                      child: QuickAction(
                        title: 'Rescue',
                        subtitle: 'Find help',
                        icon: Icons.support_agent_rounded,
                        color: const Color(0xFFE6EAF4),
                        onTap: () => openRescue(context),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 22),
          FurUReveal(
            delay: const Duration(milliseconds: 240),
            child: CompanionPortrait(
              height: MediaQuery.textScalerOf(context).scale(14) > 21
                  ? 350
                  : 270,
              compact: true,
              onBrowse: onDiscover,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in [
                ('All', Icons.pets),
                ('Dog', Icons.pets_outlined),
                ('Cat', Icons.cruelty_free_outlined),
              ])
                ActionChip(
                  avatar: Icon(item.$2, size: 18),
                  label: Text(item.$1 == 'All' ? 'All pets' : '${item.$1}s'),
                  onPressed: () => onDiscover(item.$1),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Ready for a new start',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton(onPressed: onDiscover, child: const Text('See all')),
            ],
          ),
          const SizedBox(height: 8),
          PetCollection(pets: app.pets.take(2).toList()),
          const SizedBox(height: 12),
          const Text(
            'Meet our sample pets. Live shelter listings are coming soon.',
            style: TextStyle(fontSize: 11),
          ),
          const SizedBox(height: 24),
          FurUSectionCard(
            color: FurUColors.peach,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.volunteer_activism_outlined,
                  color: FurUColors.forest,
                ),
                const SizedBox(height: 12),
                Text(
                  'A fresh start for every pet.',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Need to find a new home for a pet? We’ll guide you, one caring step at a time.',
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => openWorkflow(
                    context,
                    app.newDraft(SubmissionKind.rehome),
                  ),
                  child: const Text('Rehome a pet  →'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const AdoptionJourney(),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => showOurStory(context),
            icon: const Icon(Icons.favorite_outline),
            label: const Text('Our story · FurYou × WHELPS'),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => openRescue(context),
            icon: const Icon(Icons.support_agent_rounded),
            label: const Text('Contact for Rescue'),
          ),
        ],
      ),
    );
  }
}

class PetCollection extends StatelessWidget {
  final List<Pet> pets;
  const PetCollection({super.key, required this.pets});
  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 600
            ? 3
            : MediaQuery.textScalerOf(context).scale(14) > 21
            ? 1
            : 2;
        final width = (constraints.maxWidth - (columns - 1) * 14) / columns;
        return Wrap(
          spacing: 14,
          runSpacing: 16,
          children: pets
              .map(
                (pet) => SizedBox(
                  width: width,
                  child: FurUPetCard(
                    pet: pet,
                    saved: app.favorites.contains(pet.id),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => PetDetail(pet: pet),
                      ),
                    ),
                    onFavorite: () async {
                      try {
                        await app.toggleFavorite(pet.id);
                      } catch (e) {
                        if (context.mounted) showError(context, e);
                      }
                    },
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}
