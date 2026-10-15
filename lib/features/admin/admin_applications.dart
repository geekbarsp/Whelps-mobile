part of 'admin_shell.dart';

const _applicationLabels = {
  'all': 'All',
  'submitted': 'Submitted',
  'under_review': 'Under review',
  'approved': 'Approved',
  'rejected': 'Rejected',
  'cancelled': 'Cancelled',
  'completed': 'Completed',
};

Color _applicationColor(String status) => switch (status) {
  'approved' || 'completed' => const Color(0xFF2B9656),
  'rejected' || 'cancelled' => const Color(0xFFD74850),
  'under_review' => const Color(0xFFAD750A),
  'submitted' => const Color(0xFF247DB9),
  _ => const Color(0xFF82756E),
};

DateTime? _applicationDate(Map<String, dynamic> row) =>
    DateTime.tryParse('${row['submitted_at'] ?? row['submittedAt'] ?? ''}');

class _ApplicationsTab extends StatefulWidget {
  const _ApplicationsTab();
  @override
  State<_ApplicationsTab> createState() => _ApplicationsTabState();
}

class _ApplicationsTabState extends State<_ApplicationsTab> {
  String search = '', filter = 'all', sort = 'newest';
  int? days;

  Future<void> _filters() async {
    var selectedSort = sort;
    var selectedDays = days ?? 0;
    final applied = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, update) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Filter applications',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedSort,
                  decoration: const InputDecoration(labelText: 'Sort by'),
                  items: const [
                    DropdownMenuItem(
                      value: 'newest',
                      child: Text('Newest first'),
                    ),
                    DropdownMenuItem(
                      value: 'oldest',
                      child: Text('Oldest first'),
                    ),
                  ],
                  onChanged: (value) => update(() => selectedSort = value!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: selectedDays,
                  decoration: const InputDecoration(labelText: 'Submitted'),
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('Any time')),
                    DropdownMenuItem(value: 7, child: Text('Last 7 days')),
                    DropdownMenuItem(value: 30, child: Text('Last 30 days')),
                  ],
                  onChanged: (value) => update(() => selectedDays = value!),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Apply filters'),
                ),
                TextButton(
                  onPressed: () {
                    selectedSort = 'newest';
                    selectedDays = 0;
                    Navigator.pop(context, true);
                  },
                  child: const Text('Reset filters'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (applied == true && mounted) {
      setState(() {
        sort = selectedSort;
        days = selectedDays == 0 ? null : selectedDays;
      });
    }
  }

  Future<void> _newApplication() => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (context) => SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Start a new application',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            const Text(
              'Share the Whelps website with the adopter. They can sign in, choose an available pet, and complete their application. Their submission will appear here for review.',
            ),
            const SizedBox(height: 12),
            const Text(
              'Applications must be submitted from the adopter’s own account.',
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              icon: const Icon(Icons.copy_rounded),
              label: const Text('Copy Whelps website link'),
              onPressed: () async {
                await Clipboard.setData(
                  const ClipboardData(text: BackendConfig.whelpsApiUrl),
                );
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Website link copied. Share it with the adopter.',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final all = _rows(app, 'applications');
    final now = DateTime.now();
    final rows =
        all.where((row) {
          final status = '${row['status'] ?? 'submitted'}';
          final haystack =
              '${row['id']} ${row['applicant_name']} ${row['applicant_email']} ${row['pet_name']} ${_applicationLabels[status] ?? status}'
                  .toLowerCase();
          final submitted = _applicationDate(row);
          return haystack.contains(search.trim().toLowerCase()) &&
              (filter == 'all' || status == filter) &&
              (days == null ||
                  (submitted != null &&
                      !submitted.isBefore(
                        now.subtract(Duration(days: days!)),
                      ) &&
                      !submitted.isAfter(now)));
        }).toList()..sort((a, b) {
          final first = _applicationDate(a), second = _applicationDate(b);
          if (first == null) return second == null ? 0 : 1;
          if (second == null) return -1;
          return sort == 'oldest'
              ? first.compareTo(second)
              : second.compareTo(first);
        });
    int count(String status) =>
        all.where((row) => row['status'] == status).length;
    int weekly(String status) => all.where((row) {
      if (row['status'] != status) return false;
      final date = status == 'submitted'
          ? _applicationDate(row)
          : DateTime.tryParse(
              '${row['decision_at'] ?? row['decisionAt'] ?? row['reviewDecisionAt'] ?? ''}',
            );
      return date != null &&
          !date.isBefore(now.subtract(const Duration(days: 7))) &&
          !date.isAfter(now);
    }).length;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final foreground = Theme.of(context).colorScheme.onSurface;
    return _RefreshPage(
      child: ListView(
        key: const PageStorageKey('admin-applications'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          const _DashboardHeader(),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final title = Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: dark
                          ? const Color(0xFF684028)
                          : const Color(0xFFFFE4CE),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      Icons.assignment_rounded,
                      color: foreground,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Applications',
                          style: TextStyle(
                            color: foreground,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                            letterSpacing: -.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Review and manage adoption applications.',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                            fontSize: 10.5,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
              final button = FilledButton.icon(
                onPressed: _newApplication,
                style: FilledButton.styleFrom(
                  backgroundColor: dark
                      ? const Color(0xFFE8A66D)
                      : const Color(0xFFA4511B),
                  foregroundColor: dark
                      ? const Color(0xFF301B0E)
                      : Colors.white,
                  minimumSize: const Size(48, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  textStyle: const TextStyle(
                    fontFamily: 'NunitoSans',
                    fontWeight: FontWeight.w800,
                    fontSize: 10.5,
                  ),
                ),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('New Application'),
              );
              return constraints.maxWidth < 350 ||
                      MediaQuery.textScalerOf(context).scale(14) > 18
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        title,
                        const SizedBox(height: 10),
                        Align(alignment: Alignment.centerRight, child: button),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: title),
                        const SizedBox(width: 5),
                        button,
                      ],
                    );
            },
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final large = MediaQuery.textScalerOf(context).scale(14) > 20;
              final metrics = [
                for (final status in ['submitted', 'approved', 'rejected'])
                  _ApplicationMetric(
                    status: status,
                    count: count(status),
                    weekly: weekly(status),
                    onTap: () => setState(() => filter = status),
                  ),
              ];
              return large
                  ? Column(
                      children: [
                        for (final metric in metrics) ...[
                          metric,
                          const SizedBox(height: 8),
                        ],
                      ],
                    )
                  : IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < metrics.length; i++) ...[
                            if (i > 0) const SizedBox(width: 9),
                            Expanded(child: metrics[i]),
                          ],
                        ],
                      ),
                    );
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) => setState(() => search = value),
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search_rounded),
                    hintText: 'Applicant, pet, or application ID...',
                    hintStyle: TextStyle(fontSize: 12),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Badge(
                isLabelVisible: days != null || sort != 'newest',
                child: IconButton.filledTonal(
                  tooltip: 'Filter applications',
                  onPressed: _filters,
                  style: IconButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    backgroundColor: FurUColors.card(context),
                    foregroundColor: foreground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.tune_rounded),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final entry in _applicationLabels.entries)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Semantics(
                      selected: filter == entry.key,
                      button: true,
                      child: Material(
                        color: filter == entry.key
                            ? const Color(0xFFA4511B)
                            : FurUColors.card(context),
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          onTap: () => setState(() => filter = entry.key),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 48),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  filter == entry.key
                                      ? Icons.check_rounded
                                      : Icons.circle,
                                  size: filter == entry.key ? 16 : 9,
                                  color: filter == entry.key
                                      ? Colors.white
                                      : _applicationColor(entry.key),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  entry.value,
                                  style: TextStyle(
                                    color: filter == entry.key
                                        ? Colors.white
                                        : foreground,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 11),
          if (app.adminError != null) ...[
            _AdminSyncNotice(message: app.adminError!),
            const SizedBox(height: 10),
          ],
          if (app.adminLoading && all.isEmpty)
            const _LoadingCards()
          else if (rows.isEmpty)
            EmptyState(
              icon: Icons.assignment_outlined,
              title: app.adminError != null
                  ? 'Applications unavailable'
                  : 'No matching applications',
              message: app.adminError != null
                  ? 'Pull down to try again.'
                  : 'Try another status or search term.',
            )
          else
            for (final row in rows) ...[
              _ApplicationRecordCard(row: row),
              const SizedBox(height: 8),
            ],
        ],
      ),
    );
  }
}

class _ApplicationMetric extends StatelessWidget {
  final String status;
  final int count, weekly;
  final VoidCallback onTap;
  const _ApplicationMetric({
    required this.status,
    required this.count,
    required this.weekly,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final color = status == 'submitted'
        ? const Color(0xFFF29652)
        : _applicationColor(status);
    final ink = Theme.of(context).colorScheme.onSurface;
    return Material(
      color: Color.alphaBlend(
        color.withValues(alpha: dark ? .15 : .08),
        FurUColors.card(context),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: color.withValues(alpha: .16)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Positioned(
              right: 8,
              bottom: 18,
              child: ExcludeSemantics(
                child: _DashboardBars(color: color.withValues(alpha: .20)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 23,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: .75),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      status == 'approved'
                          ? Icons.check_rounded
                          : status == 'rejected'
                          ? Icons.close_rounded
                          : Icons.description_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$count',
                    style: TextStyle(
                      color: ink,
                      fontSize: 25,
                      height: 1.1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    _applicationLabels[status]!,
                    style: TextStyle(
                      color: ink,
                      fontSize: 11,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Tooltip(
                    message: status == 'submitted'
                        ? 'Currently submitted applications received in the last 7 days'
                        : 'Current ${_applicationLabels[status]!.toLowerCase()} applications with a decision recorded in the last 7 days',
                    child: Text(
                      '+$weekly this week',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 10,
                        height: 1.3,
                      ),
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
}

class _ApplicationRecordCard extends StatelessWidget {
  final Map<String, dynamic> row;
  const _ApplicationRecordCard({required this.row});
  @override
  Widget build(BuildContext context) {
    final status = '${row['status'] ?? 'submitted'}';
    final accent = _applicationColor(status);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tint = [
      'approved',
      'submitted',
      'under_review',
      'completed',
    ].contains(status);
    final foreground = Theme.of(context).colorScheme.onSurface;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final raw = '${row['petImage'] ?? row['pet_image'] ?? ''}';
    final image = raw.startsWith('/')
        ? '${BackendConfig.whelpsApiUrl}$raw'
        : raw;
    final submitted = _applicationDate(row);
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
    final account = row['account_type'] ?? row['applicant_type'];
    final accountLabel = account == null ? 'Adopter' : _pretty('$account');
    void openReview() => _open(context, _ApprovalDetail(kind: 1, row: row));
    return Material(
      color: tint
          ? Color.alphaBlend(
              accent.withValues(alpha: dark ? .10 : .035),
              FurUColors.card(context),
            )
          : FurUColors.card(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(17),
        side: BorderSide(
          color: tint ? accent.withValues(alpha: .14) : Colors.transparent,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: openReview,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(9, 9, 2, 9),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stacked =
                  constraints.maxWidth < 310 ||
                  MediaQuery.textScalerOf(context).scale(14) > 18;
              final badge = Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: dark ? .22 : .1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  _applicationLabels[status] ?? _pretty(status),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: dark
                        ? Color.lerp(accent, Colors.white, .45)
                        : accent,
                    fontSize: 10.5,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              );
              final metadata = Wrap(
                spacing: 5,
                runSpacing: 3,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Tooltip(
                    message: '${row['id'] ?? 'Application ID unavailable'}',
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: foreground.withValues(alpha: .07),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        row['id'] == null ? 'No ID' : '#${_shortId(row['id'])}',
                        style: TextStyle(color: muted, fontSize: 9),
                      ),
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Icon(
                            Icons.schedule_rounded,
                            size: 10,
                            color: muted,
                          ),
                        ),
                        TextSpan(text: '  $when'),
                      ],
                    ),
                    style: TextStyle(color: muted, fontSize: 9, height: 1.3),
                  ),
                ],
              );
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: SizedBox(
                            width: 53,
                            height: 58,
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
                        Positioned(
                          right: -2,
                          bottom: -3,
                          child: ExcludeSemantics(
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: FurUColors.card(context),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFFFDEDA),
                                ),
                              ),
                              child: const Icon(
                                Icons.favorite_rounded,
                                size: 14,
                                color: Color(0xFFEE6A66),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${row['applicant_name'] ?? 'Adopter'}',
                          style: TextStyle(
                            color: foreground,
                            fontSize: 13,
                            height: 1.2,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _ApplicationInfo(
                                    icon: Icons.pets_rounded,
                                    text: '${row['pet_name'] ?? 'Pet'}',
                                  ),
                                  const SizedBox(height: 3),
                                  _ApplicationInfo(
                                    icon: Icons.person_outline_rounded,
                                    text: accountLabel,
                                  ),
                                ],
                              ),
                            ),
                            if (!stacked) ...[
                              const SizedBox(width: 3),
                              Flexible(child: badge),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        metadata,
                        if (stacked) ...[const SizedBox(height: 6), badge],
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: PopupMenuButton<String>(
                          tooltip: 'Application actions',
                          icon: Icon(
                            Icons.more_horiz_rounded,
                            size: 18,
                            color: muted,
                          ),
                          onSelected: (action) async {
                            if (action == 'open') {
                              openReview();
                              return;
                            }
                            await Clipboard.setData(
                              ClipboardData(text: '${row['id']}'),
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Application ID copied.'),
                                ),
                              );
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'open',
                              child: Text('Open screening'),
                            ),
                            if (row['id'] != null)
                              const PopupMenuItem(
                                value: 'copy',
                                child: Text('Copy application ID'),
                              ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: foreground,
                        size: 19,
                      ),
                    ],
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

class _ApplicationInfo extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ApplicationInfo({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      children: [
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Icon(
            icon,
            size: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        TextSpan(text: '  $text'),
      ],
    ),
    style: TextStyle(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontSize: 10,
      height: 1.3,
    ),
  );
}
