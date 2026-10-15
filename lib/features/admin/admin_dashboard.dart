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
            const SizedBox(height: 12),
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
                  final metrics = <Widget>[
                    _DashboardMetric(
                      width: width,
                      label: 'Adopter Accounts',
                      value: count('adopters'),
                      detail: 'Registered adopters',
                      icon: Icons.people_rounded,
                      color: const Color(0xFF288DDD),
                    ),
                    _DashboardMetric(
                      width: width,
                      label: 'Available Pets',
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
                      detail: '$recentCount this week',
                      icon: Icons.assignment_rounded,
                      color: const Color(0xFFF58A16),
                      onTap: () => onOpenTab(2),
                    ),
                    _DashboardMetric(
                      width: width,
                      label: 'Completed Adoptions',
                      value: count('completed_adoptions'),
                      detail: stats['completed_adoptions'] == 0
                          ? 'No adoptions yet'
                          : 'Happy new homes',
                      icon: Icons.volunteer_activism_rounded,
                      color: const Color(0xFFD95B72),
                      onTap: () => onOpenTab(3),
                    ),
                  ];
                  return Column(
                    children: [
                      if (largeText)
                        for (final metric in metrics) ...[
                          metric,
                          const SizedBox(height: 10),
                        ]
                      else
                        for (var i = 0; i < metrics.length; i += 2) ...[
                          if (i > 0) const SizedBox(height: 10),
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                metrics[i],
                                const SizedBox(width: 10),
                                metrics[i + 1],
                              ],
                            ),
                          ),
                        ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 10),
              _DashboardMetric(
                width: double.infinity,
                label: 'Unread Messages',
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
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.fromLTRB(6, 2, 6, 6),
              decoration: BoxDecoration(
                color: FurUColors.card(context),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.assignment_rounded, size: 23),
                      const SizedBox(width: 7),
                      const Expanded(
                        child: Text(
                          'Recent applications',
                          style: TextStyle(
                            fontSize: 18,
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
                      const SizedBox(height: 6),
                    ],
                ],
              ),
            ),
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
                  style: const TextStyle(fontSize: 27, height: 1.15),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Administration Panel',
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(fontSize: 11),
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
            PopupMenuItem(value: 'refresh', child: Text('Refresh workspace')),
          ],
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 9),
            decoration: BoxDecoration(
              color: dark ? const Color(0xFF684028) : const Color(0xFFFFE4CE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/brand/admin-avatar.png',
                  width: 25,
                  height: 32,
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                ),
                const SizedBox(width: 4),
                const Text(
                  'Admin',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                ),
                const Icon(Icons.expand_more_rounded, size: 15),
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
                : const [Color(0xFFFFF0DE), Color(0xFFFCEBD4)],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final stacked = MediaQuery.textScalerOf(context).scale(14) > 20;
            final copy = Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
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
                          fontSize: 26,
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
                  const SizedBox(height: 6),
                  Text(
                    'Here’s the latest overview of your FurU × Whelps platform.',
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.35,
                      color: dark ? Colors.white70 : FurUColors.cocoa,
                    ),
                  ),
                ],
              ),
            );
            final portrait = Image.asset(
              'assets/brand/admin-welcome-pets.png',
              fit: BoxFit.cover,
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
                  right: -14,
                  bottom: -9,
                  top: -7,
                  width: constraints.maxWidth * .55,
                  child: portrait,
                ),
                SizedBox(width: constraints.maxWidth * .57, child: copy),
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
    final foreground = Theme.of(context).colorScheme.onSurface;
    return SizedBox(
      width: width,
      child: Material(
        color: Color.alphaBlend(
          color.withValues(alpha: dark ? .17 : .07),
          FurUColors.card(context),
        ),
        borderRadius: BorderRadius.circular(19),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              Positioned(
                right: wide ? 65 : 10,
                bottom: 10,
                child: ExcludeSemantics(
                  child: _DashboardBars(
                    color: accent.withValues(alpha: .20),
                    wide: wide,
                  ),
                ),
              ),
              if (wide)
                Positioned(
                  right: 13,
                  bottom: 13,
                  child: ExcludeSemantics(
                    child: Icon(
                      Icons.pets_rounded,
                      size: 37,
                      color: accent.withValues(alpha: .17),
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.all(wide ? 12 : 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: wide ? 46 : 44,
                      height: wide ? 46 : 44,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: .16),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(icon, color: accent, size: 29),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              color: foreground,
                              fontSize: wide ? 13 : 10.5,
                              letterSpacing: 0,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            value,
                            style: TextStyle(
                              color: foreground,
                              fontSize: 27,
                              fontWeight: FontWeight.w900,
                              height: 1.05,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            detail,
                            style: TextStyle(
                              color: dark
                                  ? Colors.white70
                                  : const Color(0xFF827B75),
                              fontSize: 10,
                              letterSpacing: 0,
                              height: 1.3,
                            ),
                          ),
                        ],
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
}

// Decorative bars echo the reference artwork; they do not represent a data series.
class _DashboardBars extends StatelessWidget {
  final Color color;
  final bool wide;
  const _DashboardBars({required this.color, this.wide = false});
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: List.generate(
      wide ? 4 : 3,
      (i) => Container(
        width: 6,
        height: 10 + i * 8,
        margin: const EdgeInsets.only(left: 3),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    ),
  );
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
    final dark = Theme.of(context).brightness == Brightness.dark;
    final largeText = MediaQuery.textScalerOf(context).scale(14) > 20;
    final status = '${row['status'] ?? 'submitted'}';
    final badge = _DashboardStatus(status: status);
    final foreground = Theme.of(context).colorScheme.onSurface;
    final small = TextStyle(
      fontSize: 10,
      height: 1.4,
      color: dark ? Colors.white60 : const Color(0xFF89837E),
    );
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        boxShadow: dark
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF7E5D41).withValues(alpha: .07),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Material(
        color: FurUColors.card(context),
        borderRadius: BorderRadius.circular(19),
        child: InkWell(
          borderRadius: BorderRadius.circular(19),
          onTap: () => _open(context, _ApprovalDetail(kind: 1, row: row)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                ClipOval(
                  child: SizedBox.square(
                    dimension: 43,
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
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${row['applicant_name'] ?? 'Adopter'}',
                        style: TextStyle(
                          color: foreground,
                          fontWeight: FontWeight.w900,
                          fontSize: 12.5,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${row['pet_name'] ?? 'Pet'} \u00b7 Adopter',
                        style: small,
                      ),
                      Text(when, style: small),
                      if (largeText) ...[const SizedBox(height: 6), badge],
                    ],
                  ),
                ),
                if (!largeText) ...[
                  const SizedBox(width: 5),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 85),
                    child: badge,
                  ),
                ],
                const SizedBox(width: 5),
                Icon(Icons.chevron_right_rounded, size: 18, color: foreground),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardStatus extends StatelessWidget {
  final String status;
  const _DashboardStatus({required this.status});
  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase().replaceAll(' ', '_');
    final color = switch (normalized) {
      'cancelled' || 'rejected' => const Color(0xFFCB3945),
      'approved' || 'under_review' || 'completed' => const Color(0xFF16824D),
      _ => const Color(0xFFAA6509),
    };
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          color.withValues(alpha: dark ? .22 : .12),
          FurUColors.card(context),
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        _pretty(status),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: dark ? Color.lerp(color, Colors.white, .5) : color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          height: 1.2,
        ),
      ),
    );
  }
}

class _AdminBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  const _AdminBottomNavigation({
    required this.selectedIndex,
    required this.onSelected,
  });
  static const labels = [
    'Dashboard',
    'Pets',
    'Applications',
    'Monitoring',
    'More',
  ];
  static const icons = [
    Icons.home_rounded,
    Icons.pets_rounded,
    Icons.assignment_outlined,
    Icons.bar_chart_rounded,
    Icons.more_horiz_rounded,
  ];
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: FurUColors.card(context),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(labels.length, (i) {
              final selected = i == selectedIndex;
              final color = dark
                  ? const Color(0xFFF3D8C3)
                  : const Color(0xFF563522);
              return Expanded(
                child: Semantics(
                  selected: selected,
                  button: true,
                  label: labels[i],
                  child: Tooltip(
                    message: labels[i],
                    child: InkWell(
                      borderRadius: BorderRadius.circular(19),
                      onTap: () => onSelected(i),
                      child: AnimatedContainer(
                        duration: MediaQuery.disableAnimationsOf(context)
                            ? Duration.zero
                            : const Duration(milliseconds: 180),
                        constraints: const BoxConstraints(minHeight: 58),
                        padding: const EdgeInsets.symmetric(
                          vertical: 7,
                          horizontal: 2,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? (dark
                                    ? const Color(0xFF684028)
                                    : const Color(0xFFFFE4CE))
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(19),
                        ),
                        child: ExcludeSemantics(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(icons[i], size: 26, color: color),
                              const SizedBox(height: 3),
                              Text(
                                labels[i],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: color,
                                  fontSize: 10,
                                  height: 1.25,
                                  fontWeight: selected
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
