part of 'admin_shell.dart';

class _AdminHome extends StatelessWidget {
  final ValueChanged<int> onOpenTab;
  const _AdminHome({required this.onOpenTab});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final stats = _map(app.adminWorkspace['stats']);
    final applications = [..._rows(app, 'applications')]
      ..sort(
        (a, b) => '${b['submitted_at'] ?? ''}'.compareTo(
          '${a['submitted_at'] ?? ''}',
        ),
      );
    final pets = _rows(app, 'pets').where(
      (pet) =>
          pet['availability'] == 'Available' &&
          (pet['published'] == 1 || pet['published'] == true) &&
          (pet['healthVerification'] ?? pet['health_verification']) ==
              'Verified',
    );
    final dogs = pets
        .where(
          (pet) => '${pet['species'] ?? pet['type']}'.toLowerCase() == 'dog',
        )
        .length;
    final cats = pets
        .where(
          (pet) => '${pet['species'] ?? pet['type']}'.toLowerCase() == 'cat',
        )
        .length;
    final unread = stats['unread_messages'];
    final week = DateTime.now().subtract(const Duration(days: 7));
    final recentCount = applications
        .where(
          (row) =>
              DateTime.tryParse('${row['submitted_at']}')?.isAfter(week) ??
              false,
        )
        .length;
    String count(String key) => stats[key]?.toString() ?? '—';
    return _RefreshPage(
      child: DefaultTextStyle.merge(
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        child: ListView(
          key: const PageStorageKey('admin-dashboard'),
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            const _DashboardHeader(),
            const SizedBox(height: 18),
            const _DashboardWelcome(),
            const SizedBox(height: 12),
            if (app.adminError != null) ...[
              _AdminSyncNotice(message: app.adminError!),
              const SizedBox(height: 12),
            ],
            if (app.adminLoading && stats.isEmpty)
              const _LoadingCards()
            else ...[
              LayoutBuilder(
                builder: (context, constraints) {
                  final largeText =
                      MediaQuery.textScalerOf(context).scale(14) > 20;
                  final width = largeText
                      ? constraints.maxWidth
                      : (constraints.maxWidth - 10) / 2;
                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _DashboardMetric(
                        width: width,
                        label: 'Adopter accounts',
                        value: count('adopters'),
                        detail: 'Registered adopters',
                        icon: Icons.people_rounded,
                        color: const Color(0xFF288DDD),
                      ),
                      _DashboardMetric(
                        width: width,
                        label: 'Available pets',
                        value: count('available_pets'),
                        detail:
                            '$dogs ${dogs == 1 ? 'dog' : 'dogs'} · $cats ${cats == 1 ? 'cat' : 'cats'}',
                        icon: Icons.pets_rounded,
                        color: const Color(0xFF269951),
                        onTap: () => onOpenTab(1),
                      ),
                      _DashboardMetric(
                        width: width,
                        label: 'Applications',
                        value: count('applications'),
                        detail: '$recentCount in the last 7 days',
                        icon: Icons.assignment_rounded,
                        color: const Color(0xFFF58A16),
                        onTap: () => onOpenTab(2),
                      ),
                      _DashboardMetric(
                        width: width,
                        label: 'Completed adoptions',
                        value: count('completed_adoptions'),
                        detail: stats['completed_adoptions'] == 0
                            ? 'No adoptions yet'
                            : 'Happy new beginnings',
                        icon: Icons.volunteer_activism_rounded,
                        color: const Color(0xFFD95B72),
                        onTap: () => onOpenTab(3),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 10),
              _DashboardMetric(
                width: double.infinity,
                label: 'Unread messages',
                value: count('unread_messages'),
                detail: unread == 0
                    ? 'All caught up!'
                    : 'Open your conversations',
                icon: Icons.chat_rounded,
                color: const Color(0xFF8A59D0),
                wide: true,
                onTap: () => _open(context, const _MessagesScreen()),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.assignment_rounded, size: 23),
                const SizedBox(width: 7),
                const Expanded(
                  child: Text(
                    'Recent applications',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => onOpenTab(2),
                  child: const Text('View all ›'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (applications.isEmpty)
              EmptyState(
                icon: Icons.assignment_outlined,
                title: app.adminLoading
                    ? 'Loading applications'
                    : app.adminError != null
                    ? 'Applications unavailable'
                    : 'No applications yet',
                message: app.adminError != null
                    ? 'Pull down to try again.'
                    : 'Your latest adoption requests will appear here.',
              )
            else
              for (final row in applications.take(3)) ...[
                _DashboardApplication(row: row),
                const SizedBox(height: 10),
              ],
          ],
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Fur',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      TextSpan(
                        text: 'U',
                        style: TextStyle(
                          color: FurUColors.orange,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const TextSpan(
                        text: ' × Whelps',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  style: const TextStyle(fontSize: 26, height: 1.15),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Administration Panel',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        IconButton.filledTonal(
          tooltip: 'Notifications',
          style: IconButton.styleFrom(
            backgroundColor: FurUColors.card(context),
          ),
          onPressed: () => _open(context, const _NotificationsScreen()),
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        const SizedBox(width: 4),
        PopupMenuButton<String>(
          tooltip: 'Administrator menu',
          onSelected: (value) {
            if (value == 'profile') _open(context, const _AdminProfileScreen());
            if (value == 'settings') {
              _open(context, const _AdminSettingsScreen());
            }
            if (value == 'refresh') AppScope.of(context).refreshAdminData();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'profile',
              child: Text('Administrator profile'),
            ),
            PopupMenuItem(value: 'settings', child: Text('Settings')),
            PopupMenuItem(value: 'refresh', child: Text('Refresh dashboard')),
          ],
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 9),
            decoration: BoxDecoration(
              color: dark ? const Color(0xFF684028) : const Color(0xFFFFE4CE),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.account_circle_rounded, size: 22),
                SizedBox(width: 5),
                Text(
                  'Admin',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                ),
                Icon(Icons.expand_more_rounded, size: 17),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DashboardWelcome extends StatelessWidget {
  const _DashboardWelcome();
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: dark
                ? const [Color(0xFF473125), Color(0xFF64442A)]
                : const [Color(0xFFFFEFDC), Color(0xFFFFE3BC)],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final stacked = MediaQuery.textScalerOf(context).scale(14) > 20;
            final copy = Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Welcome back,',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  const Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    children: [
                      Text(
                        'Admin!',
                        style: TextStyle(
                          fontSize: 29,
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                        ),
                      ),
                      Icon(
                        Icons.pets_rounded,
                        color: FurUColors.orange,
                        size: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Text(
                    'Here’s the latest overview of your FurU × Whelps platform.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: dark ? Colors.white70 : FurUColors.cocoa,
                    ),
                  ),
                ],
              ),
            );
            final portrait = Image.asset(
              'assets/brand/landing-pets.png',
              fit: BoxFit.contain,
              excludeFromSemantics: true,
            );
            if (stacked) {
              return Column(
                children: [
                  copy,
                  SizedBox(height: 150, child: portrait),
                ],
              );
            }
            return Stack(
              children: [
                Positioned(
                  right: -12,
                  bottom: -20,
                  top: 0,
                  width: constraints.maxWidth * .53,
                  child: portrait,
                ),
                SizedBox(width: constraints.maxWidth * .59, child: copy),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DashboardMetric extends StatelessWidget {
  final double width;
  final String label, value, detail;
  final IconData icon;
  final Color color;
  final bool wide;
  final VoidCallback? onTap;
  const _DashboardMetric({
    required this.width,
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
    required this.color,
    this.wide = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = dark ? Color.lerp(color, Colors.white, .4)! : color;
    final emblem = Container(
      width: wide ? 52 : 38,
      height: wide ? 52 : 38,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(icon, color: accent, size: wide ? 30 : 23),
    );
    final number = Text(
      value,
      style: TextStyle(
        fontSize: wide ? 32 : 30,
        fontWeight: FontWeight.w900,
        height: 1.15,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
    return SizedBox(
      width: width,
      child: Material(
        color: Color.alphaBlend(
          color.withValues(alpha: dark ? .17 : .085),
          FurUColors.card(context),
        ),
        borderRadius: BorderRadius.circular(23),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: wide
                ? Row(
                    children: [
                      emblem,
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            number,
                            Text(
                              detail,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      ExcludeSemantics(
                        child: Icon(
                          Icons.pets_rounded,
                          color: accent.withValues(alpha: .18),
                          size: 40,
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          emblem,
                          const SizedBox(width: 9),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    minHeight: 34,
                                  ),
                                  child: Text(
                                    label,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                      height: 1.3,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                ),
                                number,
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 9),
                      Text(
                        detail,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(fontSize: 11, height: 1.35),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _DashboardApplication extends StatelessWidget {
  final Map<String, dynamic> row;
  const _DashboardApplication({required this.row});
  @override
  Widget build(BuildContext context) {
    final rawImage = '${row['petImage'] ?? row['pet_image'] ?? ''}';
    final image = rawImage.startsWith('/')
        ? '${BackendConfig.whelpsApiUrl}$rawImage'
        : rawImage;
    final submitted = DateTime.tryParse('${row['submitted_at']}');
    final elapsed = submitted == null
        ? null
        : DateTime.now().difference(submitted);
    final when = elapsed == null
        ? 'Submission date unavailable'
        : elapsed.inDays > 0
        ? 'Submitted ${elapsed.inDays} ${elapsed.inDays == 1 ? 'day' : 'days'} ago'
        : elapsed.inHours > 0
        ? 'Submitted ${elapsed.inHours} ${elapsed.inHours == 1 ? 'hour' : 'hours'} ago'
        : 'Submitted recently';
    return Material(
      color: FurUColors.card(context),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => _open(context, _ApprovalDetail(kind: 1, row: row)),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipOval(
                child: SizedBox.square(
                  dimension: 46,
                  child: image.isEmpty
                      ? const ColoredBox(
                          color: FurUColors.sage,
                          child: Icon(
                            Icons.pets_rounded,
                            color: FurUColors.forest,
                          ),
                        )
                      : Image.network(
                          image,
                          fit: BoxFit.cover,
                          excludeFromSemantics: true,
                          errorBuilder: (_, _, _) => const ColoredBox(
                            color: FurUColors.sage,
                            child: Icon(
                              Icons.pets_rounded,
                              color: FurUColors.forest,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${row['applicant_name'] ?? 'Adopter'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${row['pet_name'] ?? 'Pet'} · Adoption request',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 2),
                    Text(when, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 7),
                    FurUStatusBadge(_pretty('${row['status'] ?? 'submitted'}')),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
