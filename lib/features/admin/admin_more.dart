part of 'admin_shell.dart';

class _MoreTab extends StatelessWidget {
  const _MoreTab();
  @override
  Widget build(BuildContext context) {
    final unread = _map(
      AppScope.of(context).adminWorkspace['stats'],
    )['unread_messages'];
    final tools = [
      (
        Icons.forum_outlined,
        'Messages',
        'Approved adopters and monitoring conversations',
        const Color(0xFFC96F50),
        const _MessagesScreen(),
      ),
      (
        Icons.trending_up_rounded,
        'System evaluation',
        'Feedback, outcomes, and activity trends',
        const Color(0xFF368CDE),
        const _AnalyticsScreen(),
      ),
      (
        Icons.people_rounded,
        'User management',
        'Search, suspend, or restore accounts',
        const Color(0xFF1EAD80),
        const _ModulePage(title: 'User management', child: _UsersTab()),
      ),
      (
        Icons.shield_outlined,
        'Reports & moderation',
        'Investigate safety and welfare reports',
        const Color(0xFFD65362),
        const _ModulePage(title: 'Reports & moderation', child: _ReportsTab()),
      ),
      (
        Icons.verified_outlined,
        'Organization verification',
        'Review rescue and shelter credentials',
        const Color(0xFFCA9444),
        const _OrganizationScreen(),
      ),
      (
        Icons.favorite_border_rounded,
        'Adoption records',
        'Track completed and historical adoptions',
        const Color(0xFF9856D0),
        const _RecordsScreen(),
      ),
      (
        Icons.settings_rounded,
        'System settings',
        'Manage platform settings and preferences',
        const Color(0xFF219B92),
        const _AdminSettingsScreen(),
      ),
    ];
    return _RefreshPage(
      child: ListView(
        key: const PageStorageKey('admin-more'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          const _DashboardHeader(),
          const SizedBox(height: 16),
          const _AdminToolsBanner(),
          const SizedBox(height: 10),
          for (var i = 0; i < tools.length; i++) ...[
            _AdminToolCard(
              icon: tools[i].$1,
              title: tools[i].$2,
              subtitle: tools[i].$3,
              color: tools[i].$4,
              artwork: i,
              unread: i == 0 ? unread?.toString() ?? '—' : null,
              onTap: () => _open(context, tools[i].$5),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 3, bottom: 9),
            child: Text(
              'Account & activity',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          for (final item in [
            (
              Icons.notifications_none_rounded,
              'Notifications',
              'Announcements and delivery history',
              const Color(0xFFDA9650),
              7,
              const _NotificationsScreen(),
            ),
            (
              Icons.history_rounded,
              'Audit logs',
              'Administrator action history',
              const Color(0xFF568BC4),
              8,
              const _AuditScreen(),
            ),
            (
              Icons.admin_panel_settings_outlined,
              'Administrator profile',
              'Your account and sign-out options',
              const Color(0xFF9270C6),
              9,
              const _AdminProfileScreen(),
            ),
          ]) ...[
            _AdminToolCard(
              icon: item.$1,
              title: item.$2,
              subtitle: item.$3,
              color: item.$4,
              artwork: item.$5,
              onTap: () => _open(context, item.$6),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _AdminToolsBanner extends StatelessWidget {
  const _AdminToolsBanner();
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: dark
                ? const [Color(0xFF473125), Color(0xFF64442A)]
                : const [Color(0xFFFFEFDE), Color(0xFFFCEBD4)],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final stacked = MediaQuery.textScalerOf(context).scale(14) > 18;
            final copy = Padding(
              padding: const EdgeInsets.fromLTRB(13, 15, 4, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ADMINISTRATION',
                    style: TextStyle(
                      color: dark
                          ? const Color(0xFFFFC18A)
                          : const Color(0xFFA45128),
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Tools & Settings',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 22,
                      height: 1.12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -.7,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Manage messages, accounts, reports, and system configurations for FurU × Whelps.',
                    style: TextStyle(
                      color: dark ? const Color(0xFFEBD5C4) : FurUColors.cocoa,
                      fontSize: 10.5,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            );
            final pets = Image.asset(
              'assets/brand/admin-welcome-pets.png',
              fit: BoxFit.cover,
              excludeFromSemantics: true,
            );
            if (stacked) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  copy,
                  SizedBox(height: 140, child: pets),
                ],
              );
            }
            return Stack(
              children: [
                Positioned(
                  right: -20,
                  top: 0,
                  bottom: -8,
                  width: constraints.maxWidth * .46,
                  child: pets,
                ),
                SizedBox(width: constraints.maxWidth * .63, child: copy),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AdminToolCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  final int? artwork;
  final String? unread;
  final VoidCallback onTap;
  const _AdminToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.artwork,
    this.unread,
  });
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final foreground = Theme.of(context).colorScheme.onSurface;
    final accent = dark ? Color.lerp(color, Colors.white, .3)! : color;
    return Material(
      color: Color.alphaBlend(
        color.withValues(alpha: dark ? .09 : .025),
        FurUColors.card(context),
      ),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final showArt =
                  artwork != null &&
                  constraints.maxWidth >= 325 &&
                  MediaQuery.textScalerOf(context).scale(14) < 18;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 41,
                    height: 43,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: accent, size: 27),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: foreground,
                            fontSize: 13.5,
                            height: 1.2,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                            fontSize: 10.5,
                            height: 1.35,
                            letterSpacing: 0,
                          ),
                        ),
                        if (unread != null) ...[
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: .08),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Icon(
                                      Icons.circle,
                                      size: 6,
                                      color: (int.tryParse(unread!) ?? 0) > 0
                                          ? const Color(0xFFE84C46)
                                          : accent,
                                    ),
                                  ),
                                  TextSpan(text: '  $unread unread'),
                                ],
                              ),
                              style: TextStyle(
                                color: foreground,
                                fontWeight: FontWeight.w700,
                                fontSize: 9,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (showArt) ...[
                    const SizedBox(width: 5),
                    ExcludeSemantics(
                      child: _AdminToolArt(kind: artwork!, color: accent),
                    ),
                  ],
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: foreground,
                    size: 21,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// Decorative miniatures echo the reference; operational metrics stay in text.
class _AdminToolArt extends StatelessWidget {
  final int kind;
  final Color color;
  const _AdminToolArt({required this.kind, required this.color});

  Widget _paper(double width, double height, {IconData? icon}) => Container(
    width: width,
    height: height,
    padding: const EdgeInsets.all(7),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(9),
    ),
    child: icon != null
        ? Icon(icon, size: height * .6, color: color.withValues(alpha: .5))
        : Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final fraction in [0.7, 1.0, .8])
                FractionallySizedBox(
                  widthFactor: fraction,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: .35),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
            ],
          ),
  );
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 70,
    height: 54,
    child: Stack(
      clipBehavior: Clip.hardEdge,
      children: switch (kind) {
        0 => [
          Positioned(left: 12, top: 0, child: _paper(48, 48)),
          Positioned(
            left: 0,
            bottom: 0,
            child: Icon(
              Icons.chat_bubble_rounded,
              size: 41,
              color: color.withValues(alpha: .24),
            ),
          ),
          Positioned(
            left: 17,
            top: -4,
            child: Icon(
              Icons.sms_rounded,
              size: 35,
              color: color.withValues(alpha: .6),
            ),
          ),
          Positioned(
            right: -1,
            bottom: 1,
            child: Icon(
              Icons.sms_rounded,
              size: 28,
              color: color.withValues(alpha: .8),
            ),
          ),
        ],
        1 => [
          Positioned(right: 1, bottom: 0, child: _paper(62, 48)),
          Positioned(
            left: 5,
            right: 6,
            bottom: 7,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < 6; i++)
                  Expanded(
                    child: Container(
                      height: 8 + i * 6,
                      margin: const EdgeInsets.only(left: 3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: .22 + i * .1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
        2 => [
          Positioned(right: 0, top: 1, child: _paper(61, 30)),
          Positioned(left: 0, bottom: 0, child: _paper(65, 27)),
          Positioned(
            left: 3,
            top: 4,
            child: Icon(
              Icons.account_circle_rounded,
              size: 22,
              color: color.withValues(alpha: .5),
            ),
          ),
          Positioned(
            left: 3,
            bottom: 3,
            child: Icon(
              Icons.account_circle_rounded,
              size: 21,
              color: color.withValues(alpha: .8),
            ),
          ),
        ],
        3 => [
          Positioned(left: 10, top: 0, child: _paper(47, 53)),
          Positioned(
            right: 0,
            bottom: 0,
            child: Icon(
              Icons.error_rounded,
              size: 26,
              color: color.withValues(alpha: .8),
            ),
          ),
        ],
        4 => [
          Positioned(left: 0, top: 1, child: _paper(44, 51)),
          Positioned(
            right: 0,
            top: 2,
            child: Icon(
              Icons.home_rounded,
              size: 33,
              color: color.withValues(alpha: .35),
            ),
          ),
          const Positioned(
            right: 16,
            bottom: 0,
            child: Icon(
              Icons.check_circle_rounded,
              size: 25,
              color: Color(0xFF55AF8D),
            ),
          ),
        ],
        5 => [
          Positioned(
            left: 0,
            top: 0,
            child: Icon(
              Icons.folder_rounded,
              size: 64,
              color: color.withValues(alpha: .24),
            ),
          ),
          Positioned(
            left: 9,
            bottom: 0,
            child: _paper(54, 36, icon: Icons.pets_rounded),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Icon(
              Icons.check_circle_rounded,
              size: 24,
              color: color.withValues(alpha: .8),
            ),
          ),
        ],
        7 => [
          Positioned(right: 1, top: 4, child: _paper(48, 43)),
          Positioned(
            left: 1,
            bottom: 0,
            child: Icon(
              Icons.notifications_active_rounded,
              size: 43,
              color: color.withValues(alpha: .65),
            ),
          ),
          Positioned(
            right: 3,
            top: 1,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .8),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
        8 => [
          Positioned(left: 7, top: 1, child: _paper(45, 51)),
          Positioned(
            right: 0,
            bottom: 0,
            child: Icon(
              Icons.history_rounded,
              size: 33,
              color: color.withValues(alpha: .8),
            ),
          ),
          Positioned(
            left: 1,
            top: 4,
            child: Icon(
              Icons.fact_check_rounded,
              size: 22,
              color: color.withValues(alpha: .55),
            ),
          ),
        ],
        9 => [
          Positioned(right: 0, top: 5, child: _paper(65, 44)),
          Positioned(
            left: 4,
            top: 7,
            child: Icon(
              Icons.account_circle_rounded,
              size: 37,
              color: color.withValues(alpha: .6),
            ),
          ),
          Positioned(
            right: 1,
            bottom: 0,
            child: Icon(
              Icons.verified_user_rounded,
              size: 25,
              color: color.withValues(alpha: .8),
            ),
          ),
        ],
        _ => [
          Positioned(
            right: 0,
            top: 0,
            child: Icon(
              Icons.settings_rounded,
              size: 46,
              color: color.withValues(alpha: .4),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            child: Icon(
              Icons.settings_rounded,
              size: 29,
              color: color.withValues(alpha: .45),
            ),
          ),
        ],
      },
    ),
  );
}
