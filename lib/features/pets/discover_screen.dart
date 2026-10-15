import 'package:flutter/material.dart';

import '../../core/app_controller.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../widgets/components.dart';
import 'pet_detail.dart';

class DiscoverScreen extends StatefulWidget {
  final String initialSpecies;
  final bool favoritesOnly;
  const DiscoverScreen({
    super.key,
    this.initialSpecies = 'All',
    this.favoritesOnly = false,
  });
  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final search = TextEditingController();
  late String species = widget.initialSpecies;
  Map<String, String> filters = {};
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  Future<void> openFilters() async {
    final draft = {...filters};
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, update) => SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              0,
              24,
              24 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Find your kind of friend',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  for (final entry in <String, List<String>>{
                    'Sex': ['Any', 'Male', 'Female'],
                    'Size': ['Any', 'Small', 'Medium', 'Large'],
                    'Age': ['Any', 'Under 1 year', '1–3 years', 'Over 3 years'],
                    'Location': ['Any', 'Quezon City', 'Makati', 'Pasig'],
                    'Breed': [
                      'Any',
                      'Golden Retriever',
                      'Mixed breed',
                      'Domestic Shorthair',
                    ],
                    'Status': ['Any', 'Available'],
                  }.entries)
                    FurUDropdown(
                      label: entry.key,
                      options: entry.value,
                      value: draft[entry.key] ?? 'Any',
                      onChanged: (v) => update(() {
                        if (v == 'Any') {
                          draft.remove(entry.key);
                        } else {
                          draft[entry.key] = v!;
                        }
                      }),
                    ),
                  FurUPrimaryButton(
                    label: 'Show matching pets',
                    onPressed: () => Navigator.pop(context, draft),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: () =>
                          Navigator.pop(context, <String, String>{}),
                      child: const Text('Reset filters'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (result != null && mounted) setState(() => filters = result);
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final query = search.text.toLowerCase().trim();
    final pets = app.pets
        .where(
          (p) =>
              p.availability != PetAvailability.unavailable &&
              (!widget.favoritesOnly || app.favorites.contains(p.id)) &&
              (species == 'All' || p.species == species) &&
              '${p.name} ${p.breed} ${p.location}'.toLowerCase().contains(
                query,
              ) &&
              (filters['Sex'] == null || filters['Sex'] == p.sex) &&
              (filters['Size'] == null || filters['Size'] == p.size) &&
              (filters['Location'] == null ||
                  filters['Location'] == p.location) &&
              (filters['Breed'] == null || filters['Breed'] == p.breed) &&
              (filters['Age'] == null ||
                  (filters['Age'] == 'Under 1 year'
                      ? p.ageMonths < 12
                      : filters['Age'] == '1–3 years'
                      ? p.ageMonths >= 12 && p.ageMonths <= 36
                      : p.ageMonths > 36)),
        )
        .toList();
    return PageBody(
      child: ListView(
        key: const PageStorageKey('discover-scroll'),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
        children: [
          if (!widget.favoritesOnly) ...[
            _DiscoverHeader(onNearMe: openFilters),
            const SizedBox(height: 14),
          ] else ...[
            Text(
              'Your little favorites',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 6),
            const Text('The friends you want to keep close.'),
            const SizedBox(height: 22),
          ],
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: search,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Name, breed, or city',
                    prefixIcon: const Icon(Icons.search_rounded, size: 27),
                    suffixIcon: search.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => setState(search.clear),
                          ),
                    filled: true,
                    fillColor: FurUColors.card(context),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                onPressed: openFilters,
                tooltip: 'Filter pets',
                style: IconButton.styleFrom(
                  minimumSize: const Size(60, 60),
                  backgroundColor: const Color(0xFFA65A2A),
                  foregroundColor: Colors.white,
                ),
                icon: Badge(
                  isLabelVisible: filters.isNotEmpty,
                  label: Text('${filters.length}'),
                  child: const Icon(Icons.tune_rounded, size: 27),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _SpeciesRail(
            selected: species,
            onSelected: (value) => setState(() => species = value),
          ),
          if (filters.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: filters.entries
                  .map(
                    (entry) => InputChip(
                      label: Text(entry.value),
                      onDeleted: () =>
                          setState(() => filters.remove(entry.key)),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(
                Icons.pets_rounded,
                size: 19,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.favoritesOnly
                      ? 'Your saved friends'
                      : 'A new best friend is waiting for you',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Text(
                '${pets.length} ${pets.length == 1 ? 'pet' : 'pets'} found',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (pets.isEmpty)
            EmptyState(
              title: widget.favoritesOnly
                  ? 'A little love, saved here'
                  : 'No paws found just yet',
              message: widget.favoritesOnly
                  ? 'Tap the heart on a pet to keep them close.'
                  : 'Try a different search or clear your filters.',
              action: TextButton(
                onPressed: () => setState(() {
                  search.clear();
                  filters.clear();
                  species = 'All';
                }),
                child: const Text('Clear search and filters'),
              ),
            )
          else
            _DiscoverPetGrid(pets: pets),
        ],
      ),
    );
  }
}

class _DiscoverHeader extends StatelessWidget {
  final VoidCallback onNearMe;
  const _DiscoverHeader({required this.onNearMe});

  @override
  Widget build(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? _DarkDiscoverHeader(onNearMe: onNearMe)
      : SizedBox(
          height: 153,
          child: Stack(
            children: [
              Positioned.fill(
                child: Semantics(
                  image: true,
                  label:
                      'FurYou and Whelps. Discover — find your forever friend.',
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final scale = constraints.maxWidth / 780;
                      return ClipRect(
                        child: Stack(
                          clipBehavior: Clip.hardEdge,
                          children: [
                            Positioned(
                              left: -50 * scale,
                              top: -96 * scale,
                              width: 879 * scale,
                              height: 1792 * scale,
                              child: Image.asset(
                                'assets/brand/discover-reference.png',
                                fit: BoxFit.fill,
                                filterQuality: FilterQuality.high,
                                excludeFromSemantics: true,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 8,
                width: 100,
                height: 45,
                child: TextButton(
                  onPressed: onNearMe,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.transparent,
                    overlayColor: Colors.transparent,
                    splashFactory: NoSplash.splashFactory,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text('Near me'),
                ),
              ),
            ],
          ),
        );
}

class _DarkDiscoverHeader extends StatelessWidget {
  final VoidCallback onNearMe;
  const _DarkDiscoverHeader({required this.onNearMe});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 153,
    child: Stack(
      children: [
        Positioned(
          right: -14,
          bottom: -12,
          child: Icon(
            Icons.pets_rounded,
            size: 125,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: .08),
          ),
        ),
        const Positioned(left: 0, top: 0, child: Brand(small: true)),
        Positioned(
          right: 0,
          top: 3,
          child: TextButton.icon(
            onPressed: onNearMe,
            icon: const Icon(Icons.location_on_outlined, size: 17),
            label: const Text('Near me'),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Discover',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 3),
              Text(
                'Find your forever friend',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// Kept for backwards compatibility with older golden tests.
// ignore: unused_element
class _DiscoverBrand extends StatelessWidget {
  const _DiscoverBrand();

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            const TextSpan(
              style: TextStyle(
                fontFamily: 'Fraunces',
                fontSize: 25,
                height: .9,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.3,
              ),
              children: [
                TextSpan(
                  text: 'Fur',
                  style: TextStyle(color: Color(0xFF3B261A)),
                ),
                TextSpan(
                  text: 'You',
                  style: TextStyle(color: Color(0xFFFF8A17)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'WE LOVE THEM LIKE YOU DO',
            style: TextStyle(fontSize: 6, fontWeight: FontWeight.w900),
          ),
        ],
      ),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Text('×', style: TextStyle(fontSize: 16)),
      ),
      SizedBox(
        width: 47,
        height: 44,
        child: ClipRect(
          child: Transform.scale(
            scale: 1.65,
            child: Image.asset('assets/brand/whelps-logo.png'),
          ),
        ),
      ),
    ],
  );
}

class _SpeciesRail extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;
  const _SpeciesRail({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final item in const [
            ('All', 'All pets', Icons.pets_rounded),
            ('Dog', 'Dogs', Icons.pets_outlined),
            ('Cat', 'Cats', Icons.cruelty_free_outlined),
            ('Other', 'Others', Icons.radar_rounded),
          ]) ...[
            ChoiceChip(
              selected: selected == item.$1,
              onSelected: (_) => onSelected(item.$1),
              showCheckmark: false,
              avatar: Icon(
                item.$3,
                size: 20,
                color: selected == item.$1 ? scheme.onPrimary : scheme.primary,
              ),
              label: Text(item.$2),
              labelStyle: TextStyle(
                color: selected == item.$1
                    ? scheme.onPrimary
                    : scheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
              selectedColor: scheme.primary,
              backgroundColor: FurUColors.card(context),
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            ),
            const SizedBox(width: 9),
          ],
        ],
      ),
    );
  }
}

class _DiscoverPetGrid extends StatelessWidget {
  final List<Pet> pets;
  const _DiscoverPetGrid({required this.pets});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final singleColumn =
          constraints.maxWidth < 330 ||
          MediaQuery.textScalerOf(context).scale(14) > 19;
      final width = singleColumn
          ? constraints.maxWidth
          : (constraints.maxWidth - 12) / 2;
      return Wrap(
        spacing: 12,
        runSpacing: 14,
        children: [
          for (final pet in pets)
            SizedBox(
              width: width,
              child: _DiscoverPetCard(pet: pet),
            ),
        ],
      );
    },
  );
}

class _DiscoverPetCard extends StatelessWidget {
  final Pet pet;
  const _DiscoverPetCard({required this.pet});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final saved = app.favorites.contains(pet.id);
    return Material(
      color: FurUColors.card(context),
      elevation: Theme.of(context).brightness == Brightness.dark ? 0 : 1,
      shadowColor: const Color(0x172F1D13),
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
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
                    right: 9,
                    top: 9,
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
                        minimumSize: const Size(42, 42),
                      ),
                      icon: Icon(
                        saved
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    bottom: 9,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: switch (pet.availability) {
                          PetAvailability.available => const Color(0xFF55BD72),
                          PetAvailability.pending => const Color(0xFFFFA039),
                          PetAvailability.adopted => const Color(0xFF6C8FB8),
                          PetAvailability.unavailable => const Color(
                            0xFF77706B,
                          ),
                        },
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.home_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            pet.status,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 11, 14, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: TextStyle(
                      fontFamily: 'Fraunces',
                      fontSize: 22,
                      height: 1,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      Expanded(
                        child: _PetFact(
                          icon: pet.species == 'Cat'
                              ? Icons.cruelty_free_outlined
                              : Icons.pets_outlined,
                          text: pet.breed,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: _PetFact(
                          icon: pet.sex == 'Female' ? Icons.female : Icons.male,
                          text: pet.sex,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Expanded(
                        child: _PetFact(
                          icon: Icons.location_on_outlined,
                          text: pet.location,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: _PetFact(
                          icon: Icons.calendar_month_outlined,
                          text: pet.age,
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

class _PetFact extends StatelessWidget {
  final IconData icon;
  final String text;
  const _PetFact({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        icon,
        size: 16,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      const SizedBox(width: 5),
      Flexible(
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11.5,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    ],
  );
}
