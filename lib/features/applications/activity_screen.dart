import 'package:flutter/material.dart';

import '../../core/app_controller.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../widgets/components.dart';
import '../../widgets/notification_page.dart';
import 'workflow_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final items = app.submissions;
    return FurUNotificationPage(
      child: items.isEmpty
          ? null
          : ListView(
              padding: const EdgeInsets.all(22),
              children: [
                if (!app.notificationsEnabled)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: FurUSectionCard(
                      color: FurUColors.peach,
                      child: Text(
                        'Notifications are paused. You can turn them back on in Settings.',
                      ),
                    ),
                  ),
                Text(
                  'Your latest updates',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                const Text('Everything important, in one gentle place.'),
                const SizedBox(height: 22),
                for (final item in items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: FurUColors.card(context),
                      borderRadius: BorderRadius.circular(20),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor:
                              item.status == ApplicationStatus.draft
                              ? FurUColors.peach
                              : FurUColors.sage,
                          child: Icon(
                            item.status == ApplicationStatus.draft
                                ? Icons.edit_note_rounded
                                : Icons.notifications_active_outlined,
                            color: FurUColors.forest,
                          ),
                        ),
                        title: Text(
                          item.status == ApplicationStatus.draft
                              ? 'Your draft is waiting'
                              : '${item.status.label}: ${item.title}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          item.status == ApplicationStatus.draft
                              ? 'Continue when you’re ready.'
                              : 'Open this update to review the details.',
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => openWorkflow(context, item),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class ActivityScreen extends StatefulWidget {
  final VoidCallback? onDiscover;
  const ActivityScreen({super.key, this.onDiscover});

  @override
  State<ActivityScreen> createState() => _ReferenceActivityScreenState();
}

class _ReferenceActivityScreenState extends State<ActivityScreen> {
  String filter = 'All';

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const NotificationsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) => PageBody(
    child: ListView(
      key: const PageStorageKey('activity-scroll'),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Every step, together.',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 31,
                      height: 1.05,
                      letterSpacing: -1.1,
                    ),
                  ),
                  const SizedBox(height: 9),
                  const Text(
                    'Your applications, adoptions, and activity in one place.',
                    style: TextStyle(fontSize: 14, color: Color(0xFF8C8580)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: _openNotifications,
              tooltip: 'Notifications',
              style: IconButton.styleFrom(
                minimumSize: const Size(46, 46),
                backgroundColor: const Color(0xFFF6E8D7),
                foregroundColor: const Color(0xFF5E351F),
              ),
              icon: const Badge(
                smallSize: 8,
                backgroundColor: Color(0xFFF25C22),
                child: Icon(Icons.notifications_none_rounded, size: 25),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _ActivityFilters(
          selected: filter,
          onSelected: (value) => setState(() => filter = value),
        ),
        const SizedBox(height: 19),
        if (filter == 'All' || filter == 'Adoption') ...[
          const _ActivitySectionHeader(
            color: Color(0xFFFF962B),
            title: 'Ongoing',
          ),
          const SizedBox(height: 10),
          const _ActivityPetCard(
            crop: Rect.fromLTWH(108, 455, 144, 145),
            badgeIcon: Icons.favorite_border_rounded,
            badge: 'Adoption Application',
            name: 'Milo',
            status: 'Application under review',
            date: 'Submitted on Sep 27, 2026',
            statusIcon: Icons.schedule_rounded,
            showMenu: true,
          ),
          const SizedBox(height: 9),
        ],
        if (filter == 'All' || filter == 'Rehome') ...[
          if (filter == 'Rehome') ...[
            const _ActivitySectionHeader(
              color: Color(0xFFFF962B),
              title: 'Ongoing',
            ),
            const SizedBox(height: 10),
          ],
          const _ActivityPetCard(
            crop: Rect.fromLTWH(108, 655, 144, 145),
            badgeIcon: Icons.home_outlined,
            badge: 'Rehoming Request',
            name: 'Luna',
            status: 'Waiting for shelter response',
            date: 'Submitted on Sep 25, 2026',
            statusIcon: Icons.schedule_rounded,
            showMenu: true,
          ),
          const SizedBox(height: 19),
        ],
        if (filter == 'All' || filter == 'Adoption') ...[
          const _ActivitySectionHeader(
            color: Color(0xFF2196F3),
            title: 'Upcoming',
          ),
          const SizedBox(height: 10),
          const _UpcomingActivityCard(),
          const SizedBox(height: 19),
        ],
        if (filter == 'All' || filter == 'Rescue') ...[
          const _ActivitySectionHeader(
            color: Color(0xFF77C765),
            title: 'Completed',
          ),
          const SizedBox(height: 10),
          const _ActivityPetCard(
            crop: Rect.fromLTWH(108, 1205, 144, 145),
            badgeIcon: Icons.pets_outlined,
            badge: 'Rescue Support',
            name: 'Buddy',
            status: 'Donation received',
            date: 'Completed on Sep 20, 2026',
            statusIcon: Icons.check_circle_rounded,
            statusColor: Color(0xFF55BDC1),
          ),
          const SizedBox(height: 9),
        ],
        if (filter == 'All' || filter == 'Adoption')
          const _ActivityPetCard(
            crop: Rect.fromLTWH(108, 1405, 144, 145),
            badgeIcon: Icons.favorite_border_rounded,
            badge: 'Adoption',
            name: 'Choco',
            status: 'Application approved',
            date: 'Completed on Sep 15, 2026',
            statusIcon: Icons.check_circle_rounded,
            statusColor: Color(0xFF77C765),
          ),
      ],
    ),
  );
}

class _ActivityFilters extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;
  const _ActivityFilters({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final item in const [
            ('All', Icons.format_list_bulleted_rounded),
            ('Adoption', Icons.favorite_border_rounded),
            ('Rehome', Icons.home_outlined),
            ('Rescue', Icons.pets_outlined),
          ]) ...[
            Material(
              color: selected == item.$1
                  ? scheme.primaryContainer
                  : FurUColors.card(context),
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                onTap: () => onSelected(item.$1),
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 11,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.$2,
                        size: 18,
                        color: selected == item.$1
                            ? scheme.onPrimaryContainer
                            : scheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item.$1,
                        style: TextStyle(
                          color: selected == item.$1
                              ? scheme.onPrimaryContainer
                              : scheme.onSurface,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _ActivitySectionHeader extends StatelessWidget {
  final Color color;
  final String title;
  const _ActivitySectionHeader({required this.color, required this.title});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      TextButton.icon(
        onPressed: () {},
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFFA45C2D),
          padding: EdgeInsets.zero,
          minimumSize: const Size(64, 30),
        ),
        iconAlignment: IconAlignment.end,
        icon: const Icon(Icons.chevron_right_rounded, size: 20),
        label: const Text('See all'),
      ),
    ],
  );
}

class _ActivityPetCard extends StatelessWidget {
  final Rect crop;
  final IconData badgeIcon;
  final String badge;
  final String name;
  final String status;
  final String date;
  final IconData statusIcon;
  final Color statusColor;
  final bool showMenu;
  const _ActivityPetCard({
    required this.crop,
    required this.badgeIcon,
    required this.badge,
    required this.name,
    required this.status,
    required this.date,
    required this.statusIcon,
    this.statusColor = const Color(0xFF5B4436),
    this.showMenu = false,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: FurUColors.card(context),
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(11),
        child: Row(
          children: [
            _ActivityReferenceCrop(crop: crop),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF4A2D1E)
                                : const Color(0xFFFFF0DF),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                badgeIcon,
                                size: 15,
                                color: const Color(0xFFF06A22),
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  badge,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? const Color(0xFFFFC58E)
                                        : const Color(0xFF6B4935),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (showMenu) ...[
                        const Spacer(),
                        const Icon(Icons.more_vert_rounded, size: 18),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    name,
                    style: TextStyle(
                      fontFamily: 'Fraunces',
                      fontSize: 18,
                      height: 1,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(statusIcon, size: 15, color: statusColor),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          status,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, size: 21),
                    ],
                  ),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
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

class _ActivityReferenceCrop extends StatelessWidget {
  final Rect crop;
  const _ActivityReferenceCrop({required this.crop});

  @override
  Widget build(BuildContext context) {
    const size = 72.0;
    final scale = size / crop.width;
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              left: -crop.left * scale,
              top: -crop.top * scale,
              width: 879 * scale,
              height: 1792 * scale,
              child: Image.asset(
                'assets/brand/activity-reference.png',
                fit: BoxFit.fill,
                filterQuality: FilterQuality.high,
                excludeFromSemantics: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpcomingActivityCard extends StatelessWidget {
  const _UpcomingActivityCard();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: FurUColors.card(context),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: const Color(0xFFFFE7D9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.calendar_month_outlined,
            color: Color(0xFFF26722),
            size: 30,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Meet & Greet',
                style: TextStyle(
                  fontFamily: 'Fraunces',
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'You have an upcoming meeting\nwith the shelter team.',
                style: TextStyle(
                  fontSize: 11.5,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 15,
                    color: Color(0xFF8F552D),
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Sep 30, 2026  ·  10:00 AM',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFFFFB775)
                            : const Color(0xFF71482D),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right_rounded),
      ],
    ),
  );
}

class LegacyActivityScreen extends StatefulWidget {
  final VoidCallback? onDiscover;
  const LegacyActivityScreen({super.key, this.onDiscover});
  @override
  State<LegacyActivityScreen> createState() => _LegacyActivityScreenState();
}

class _LegacyActivityScreenState extends State<LegacyActivityScreen> {
  String filter = 'All';
  Future<void> deleteDraft(AppController app, Submission item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this draft?'),
        content: const Text('The saved answers in this draft will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep draft'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await app.deleteDraft(item.id);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Draft deleted.')));
      }
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final items = app.submissions
        .where(
          (s) =>
              filter == 'All' ||
              (filter == 'Drafts'
                  ? s.status == ApplicationStatus.draft
                  : filter == 'Adoptions'
                  ? s.kind == SubmissionKind.adoption
                  : s.kind == SubmissionKind.rehome),
        )
        .toList();
    return PageBody(
      child: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          Text(
            'Every step, together.',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          const Text('Your applications, drafts, and fresh starts.'),
          const SizedBox(height: 22),
          Wrap(
            spacing: 8,
            children: [
              for (final value in ['All', 'Adoptions', 'Rehoming', 'Drafts'])
                ChoiceChip(
                  label: Text(value),
                  selected: filter == value,
                  onSelected: (_) => setState(() => filter = value),
                ),
            ],
          ),
          const SizedBox(height: 18),
          if (items.isEmpty)
            EmptyState(
              icon: Icons.favorite_border,
              title: 'Your story starts here',
              message: 'Applications and saved drafts will appear here. Take your time finding the right connection.',
              action: widget.onDiscover == null
                  ? null
                  : FurUPrimaryButton(
                      label: 'Meet the pets',
                      onPressed: widget.onDiscover,
                    ),
            ),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () => openWorkflow(context, item),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              item.kind == SubmissionKind.adoption
                                  ? Icons.favorite_outline
                                  : Icons.home_outlined,
                              color: FurUColors.forest,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                item.kind == SubmissionKind.adoption
                                    ? 'Adopting ${app.petById(item.petId)?.name ?? 'a pet'}'
                                    : 'Rehoming ${item.answers['Pet name'] ?? 'a pet'}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            if (item.status == ApplicationStatus.draft)
                              IconButton(
                                tooltip: 'Delete draft',
                                onPressed: () => deleteDraft(app, item),
                                icon: const Icon(Icons.delete_outline_rounded),
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 12,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            FurUStatusBadge(item.status.label),
                            Text(
                              '${item.updatedAt.day}/${item.updatedAt.month}/${item.updatedAt.year}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item.status == ApplicationStatus.draft
                              ? 'Continue where you left off  →'
                              : 'View details and next steps  →',
                          style: const TextStyle(
                            fontSize: 13,
                            color: FurUColors.forest,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SubmissionDetail extends StatelessWidget {
  final String id;
  final bool justSubmitted;
  const SubmissionDetail({
    super.key,
    required this.id,
    this.justSubmitted = false,
  });
  Future<void> cancel(
    BuildContext context,
    AppController app,
    Submission item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel this submission?'),
        content: const Text(
          'Your details will stay in your activity history. You can start a new application later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep submission'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel submission'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await app.saveSubmission(
        item.copyWith(status: ApplicationStatus.cancelled),
      );
    } catch (e) {
      if (context.mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final item = app.submissions.firstWhere((s) => s.id == id);
    final cancelled = item.status == ApplicationStatus.cancelled;
    return Scaffold(
      appBar: AppBar(title: const Text('Submission details')),
      body: PageBody(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            if (justSubmitted && !cancelled) ...[
              const CircleAvatar(
                radius: 34,
                backgroundColor: FurUColors.sage,
                child: Icon(
                  Icons.check_rounded,
                  color: FurUColors.forest,
                  size: 34,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'A hopeful new beginning.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              const Text(
                'Your submission has entered the FurU administrator review queue.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
            ],
            FurUSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.kind == SubmissionKind.adoption
                        ? 'Adoption · ${app.petById(item.petId)?.name}'
                        : 'Rehoming · ${item.answers['Pet name']}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  FurUStatusBadge(item.status.label),
                  const SizedBox(height: 16),
                  Text(
                    'Reference FU-${item.id.substring(item.id.length - 6)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'What happens next',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            for (final row in [
              (
                Icons.check_circle_outline,
                'Submission received',
                'Your details are available to the FurU administrator review queue.',
              ),
              (
                cancelled
                    ? Icons.cancel_outlined
                    : Icons.person_search_outlined,
                cancelled ? 'Cancelled by you' : 'Human review',
                cancelled ? 'This submission is no longer active.' : 'A reviewer checks the details and any supporting documents.',
              ),
              (
                Icons.volunteer_activism_outlined,
                'A thoughtful next step',
                'If approved, the reviewer guides the next steps. No automatic approval.',
              ),
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(row.$1, color: FurUColors.forest),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            row.$2,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(row.$3),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const Divider(),
            if (item.reviewNote.isNotEmpty) ...[
              const SizedBox(height: 16),
              FurUSectionCard(
                color: FurUColors.peach,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reviewer note',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(item.reviewNote),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'Your submitted details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            for (final entry in item.answers.entries.where(
              (e) =>
                  e.value.isNotEmpty &&
                  e.key != 'Account type' &&
                  e.key != 'Organization name',
            ))
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.key, style: const TextStyle(fontSize: 12)),
                    Text(
                      entry.value,
                      style: const TextStyle(color: FurUColors.ink),
                    ),
                  ],
                ),
              ),
            if (item.attachments.isNotEmpty) ...[
              Text(
                'Attachments',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              for (final a in item.attachments)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    a.isImage
                        ? Icons.image_outlined
                        : Icons.description_outlined,
                  ),
                  title: Text(a.name),
                  subtitle: Text(
                    a.bytes == null
                        ? 'Metadata only · file unavailable after restart'
                        : 'Available in this session',
                  ),
                ),
            ],
            if ([
              ApplicationStatus.submitted,
              ApplicationStatus.underReview,
            ].contains(item.status))
              OutlinedButton(
                onPressed: () => cancel(context, app, item),
                child: const Text('Cancel submission'),
              ),
          ],
        ),
      ),
    );
  }
}
