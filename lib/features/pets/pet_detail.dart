import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_controller.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../widgets/components.dart';
import '../applications/workflow_screen.dart';

class PetDetail extends StatelessWidget {
  final Pet pet;
  const PetDetail({super.key, required this.pet});
  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Meet ${pet.name}'),
        actions: [
          IconButton(
            tooltip: 'Share pet details',
            onPressed: () async {
              await Clipboard.setData(
                ClipboardData(
                  text:
                      'Meet ${pet.name} — ${pet.breed}, ${pet.age}, ${pet.sex}. Located in ${pet.location}. ${pet.description}',
                ),
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${pet.name}’s details copied.')),
                );
              }
            },
            icon: const Icon(Icons.ios_share_rounded),
          ),
          IconButton(
            tooltip: app.favorites.contains(pet.id) ? 'Unsave pet' : 'Save pet',
            onPressed: () async {
              try {
                await app.toggleFavorite(pet.id);
              } catch (e) {
                if (context.mounted) showError(context, e);
              }
            },
            icon: AnimatedSwitcher(
              duration: motionDuration(
                context,
                const Duration(milliseconds: 220),
              ),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Icon(
                app.favorites.contains(pet.id)
                    ? Icons.favorite
                    : Icons.favorite_border,
                key: ValueKey(app.favorites.contains(pet.id)),
              ),
            ),
          ),
        ],
      ),
      body: PageBody(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 28),
          children: [
            FurUReveal(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: AspectRatio(aspectRatio: 1.05, child: PetImage(pet)),
              ),
            ),
            const SizedBox(height: 24),
            FurUReveal(
              delay: const Duration(milliseconds: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          pet.name,
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                      ),
                      FurUStatusBadge(pet.status),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('${pet.breed} · ${pet.location}'),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final item in [
                  ('Age', pet.age),
                  ('Sex', pet.sex),
                  ('Size', pet.size),
                ])
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).colorScheme.surfaceContainerHigh
                          : FurUColors.sage,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        Text(item.$1, style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 3),
                        Text(
                          item.$2,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 26),
            Text(
              'A little about ${pet.name}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Text(pet.description, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: pet.traits.map((t) => Chip(label: Text(t))).toList(),
            ),
            const SizedBox(height: 24),
            FurUSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Health & care',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  for (final item in pet.health)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(item)),
                        ],
                      ),
                    ),
                  const Text(
                    'Reported by the rehomer. Discuss care needs during review.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FurUSectionCard(
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .primaryContainer,
                    child: Icon(
                      Icons.home_outlined,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pet.rehomer,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Text('Community pet profile'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Adoption is a thoughtful process. Your application will be reviewed before next steps are arranged.',
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FurUPrimaryButton(
            label: pet.availability == PetAvailability.available
                ? 'Apply for adoption'
                : pet.status,
            icon: Icons.favorite_border,
            onPressed: pet.availability == PetAvailability.available
                ? () => openWorkflow(
                    context,
                    app.newDraft(SubmissionKind.adoption, pet: pet),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
