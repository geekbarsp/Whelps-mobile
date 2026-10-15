part of 'admin_shell.dart';

const _monitoringLabels = {
  'monitoring': 'Monitoring',
  'pending_review': 'Pending review',
  'reviewed': 'Reviewed',
  'needs_clarification': 'Needs clarification',
  'completed': 'Completed',
};

String _monitoringStatus(Map<String, dynamic> row) =>
    '${row['status'] ?? row['reviewStatus'] ?? 'pending_review'}'
        .toLowerCase()
        .replaceAll(' ', '_');

Color _monitoringColor(String status) => switch (status) {
  'reviewed' || 'completed' => const Color(0xFF218947),
  'needs_clarification' => const Color(0xFFB24C29),
  _ => const Color(0xFFC67A08),
};

// Match stable identifiers or an unambiguous photo, never just a pet name.
Map<String, dynamic> _monitoringPet(
  AppController app,
  Map<String, dynamic> row,
) {
  final id = row['pet_id'] ?? row['petId'];
  final photo = row['petImage'] ?? row['pet_image'];
  final matches = _rows(app, 'pets')
      .where(
        (pet) => id != null
            ? '${pet['id']}' == '$id'
            : photo != null && '$photo'.isNotEmpty && pet['image'] == photo,
      )
      .toList();
  return matches.length == 1 ? matches.single : const {};
}

class _MonitoringTab extends StatefulWidget {
  const _MonitoringTab();
  @override
  State<_MonitoringTab> createState() => _MonitoringTabState();
}

class _MonitoringTabState extends State<_MonitoringTab> {
  String search = '', filter = 'all';
  bool activeOpen = true, updatesOpen = true, completedOpen = true;

  Future<void> _filters() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Filter monitoring',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              for (final entry in {
                'all': 'All records',
                ..._monitoringLabels,
              }.entries)
                ListTile(
                  title: Text(entry.value),
                  selected: filter == entry.key,
                  leading: Icon(
                    filter == entry.key
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                  ),
                  onTap: () => Navigator.pop(context, entry.key),
                ),
            ],
          ),
        ),
      ),
    );
    if (selected != null && mounted) {
      setState(() {
        filter = selected;
        activeOpen = updatesOpen = completedOpen = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    bool matches(Map<String, dynamic> row) {
      final status = _monitoringStatus(row);
      return '${row['pet_name']} ${row['adopter_name']} ${_monitoringLabels[status] ?? status}'
              .toLowerCase()
              .contains(search.trim().toLowerCase()) &&
          (filter == 'all' || status == filter);
    }

    final records = _rows(app, 'adoption_records').where(matches).toList();
    final active = records
        .where((row) => _monitoringStatus(row) != 'completed')
        .toList();
    final completed = records
        .where((row) => _monitoringStatus(row) == 'completed')
        .toList();
    final updates = _rows(app, 'monitoring_updates').where(matches).toList()
      ..sort(
        (a, b) =>
            '${b['created_at'] ?? ''}'.compareTo('${a['created_at'] ?? ''}'),
      );
    final foreground = Theme.of(context).colorScheme.onSurface;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return _RefreshPage(
      child: ListView(
        key: const PageStorageKey('admin-monitoring'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          const _DashboardHeader(),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: dark
                      ? const Color(0xFF684028)
                      : const Color(0xFFFFE4CE),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.bar_chart_rounded,
                  color: foreground,
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monitoring',
                      style: TextStyle(
                        color: foreground,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Track pets, adopters, and application status.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) => setState(() => search = value),
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search_rounded),
                    hintText: 'Search pet, adopter, or status...',
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
                isLabelVisible: filter != 'all',
                child: IconButton.filledTonal(
                  tooltip: 'Filter monitoring',
                  onPressed: _filters,
                  style: IconButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    backgroundColor: FurUColors.card(context),
                    foregroundColor: foreground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
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
          if (filter != 'all')
            Align(
              alignment: Alignment.centerLeft,
              child: InputChip(
                label: Text(_monitoringLabels[filter] ?? _pretty(filter)),
                onDeleted: () => setState(() => filter = 'all'),
              ),
            ),
          const SizedBox(height: 12),
          if (app.adminError != null) ...[
            _AdminSyncNotice(message: app.adminError!),
            const SizedBox(height: 12),
          ],
          if (app.adminLoading && records.isEmpty && updates.isEmpty)
            const _LoadingCards()
          else ...[
            if (filter == 'all' || filter == 'monitoring')
              _MonitoringSection(
                title: 'Active monitoring',
                subtitle: 'Currently being monitored by the team.',
                count: '${active.length} active',
                icon: Icons.monitor_heart_outlined,
                expanded: activeOpen,
                onToggle: () => setState(() => activeOpen = !activeOpen),
                child: active.isEmpty
                    ? const _MonitoringEmpty(
                        'No active monitoring',
                        'Approved placements will appear here.',
                      )
                    : Column(
                        children: [
                          for (final row in active) ...[
                            _PlacementCard(row: row),
                            const SizedBox(height: 6),
                          ],
                        ],
                      ),
              ),
            if (filter == 'all' || filter == 'monitoring')
              const SizedBox(height: 12),
            if (filter != 'monitoring' && filter != 'completed')
              _MonitoringSection(
                title: 'Monitoring updates',
                subtitle: 'Recent activities and status changes.',
                count: '${updates.length} updates',
                icon: Icons.description_rounded,
                expanded: updatesOpen,
                onToggle: () => setState(() => updatesOpen = !updatesOpen),
                child: updates.isEmpty
                    ? const _MonitoringEmpty(
                        'No monitoring updates',
                        'Try another search or wait for an adopter check-in.',
                      )
                    : Column(
                        children: [
                          for (var i = 0; i < updates.length; i++) ...[
                            _MonitoringUpdateCard(
                              key: ValueKey(updates[i]['id']),
                              row: updates[i],
                              initiallyExpanded: i == 0,
                            ),
                            if (i < updates.length - 1)
                              const SizedBox(height: 8),
                          ],
                        ],
                      ),
              ),
            if (completed.isNotEmpty || filter == 'completed') ...[
              const SizedBox(height: 12),
              _MonitoringSection(
                title: 'Completed adoptions',
                subtitle: 'Placements finalized after monitoring.',
                count: '${completed.length} completed',
                icon: Icons.task_alt_rounded,
                expanded: completedOpen,
                onToggle: () => setState(() => completedOpen = !completedOpen),
                child: completed.isEmpty
                    ? const _MonitoringEmpty(
                        'No completed records in this view',
                        'Completed placements supplied by the service appear here.',
                      )
                    : Column(
                        children: [
                          for (final row in completed) _PlacementCard(row: row),
                        ],
                      ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _MonitoringEmpty extends StatelessWidget {
  final String title, message;
  const _MonitoringEmpty(this.title, this.message);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
    child: Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    ),
  );
}

class _MonitoringSection extends StatelessWidget {
  final String title, subtitle, count;
  final IconData icon;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;
  const _MonitoringSection({
    required this.title,
    required this.subtitle,
    required this.count,
    required this.icon,
    required this.expanded,
    required this.onToggle,
    required this.child,
  });
  @override
  Widget build(BuildContext context) {
    final foreground = Theme.of(context).colorScheme.onSurface;
    return Material(
      color: FurUColors.card(context),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Semantics(
            expanded: expanded,
            button: true,
            child: InkWell(
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 11,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 29,
                      height: 31,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF684028)
                            : const Color(0xFFFFE9D6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, size: 21, color: foreground),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: foreground,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: const TextStyle(fontSize: 10, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      flex: 0,
                      child: Text(
                        count,
                        style: TextStyle(color: foreground, fontSize: 10),
                      ),
                    ),
                    Icon(
                      expanded
                          ? Icons.expand_more_rounded
                          : Icons.chevron_right_rounded,
                      size: 20,
                      color: foreground,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 0, 6, 7),
              child: child,
            ),
        ],
      ),
    );
  }
}

class _MonitoringIdentity extends StatelessWidget {
  final Map<String, dynamic> row;
  final bool update;
  final bool expanded;
  const _MonitoringIdentity({
    required this.row,
    this.update = false,
    this.expanded = false,
  });
  @override
  Widget build(BuildContext context) {
    final pet = _monitoringPet(AppScope.of(context), row);
    final raw = '${row['petImage'] ?? row['pet_image'] ?? pet['image'] ?? ''}';
    final image = raw.startsWith('/')
        ? '${BackendConfig.whelpsApiUrl}$raw'
        : raw;
    final gender = '${row['gender'] ?? pet['gender'] ?? ''}'.toLowerCase();
    final breed = row['breed'] ?? pet['breed'];
    final age = row['age'] ?? pet['age'];
    final details = [
      if (breed != null && '$breed'.isNotEmpty) '$breed',
      if (age != null && '$age'.isNotEmpty) '$age',
    ].join(' · ');
    final status = _monitoringStatus(row);
    final foreground = Theme.of(context).colorScheme.onSurface;
    final caption = update
        ? 'Submitted: ${_date(row['created_at'])}'
        : '${row['applicationStatus'] ?? (status == 'completed' ? 'Adoption completed' : 'Approved placement · Monitoring')}';
    final badge = _PetPill(
      label: _monitoringLabels[status] ?? _pretty(status),
      color: _monitoringColor(status),
      icon: status == 'reviewed' || status == 'completed'
          ? Icons.check_circle_outline_rounded
          : Icons.schedule_rounded,
      bold: true,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked =
            constraints.maxWidth < 310 ||
            MediaQuery.textScalerOf(context).scale(14) > 18;
        final name = Row(
          children: [
            Flexible(
              child: Text(
                '${row['pet_name'] ?? 'Pet'}',
                style: TextStyle(
                  color: foreground,
                  fontSize: 17,
                  height: 1.2,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (gender == 'male' || gender == 'female') ...[
              const SizedBox(width: 6),
              _PetPill(
                label: '',
                color: gender == 'female'
                    ? const Color(0xFFCD4C7A)
                    : const Color(0xFF3582C2),
                icon: gender == 'female'
                    ? Icons.female_rounded
                    : Icons.male_rounded,
              ),
            ],
          ],
        );
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 63,
                height: 68,
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
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (stacked)
                    name
                  else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: name),
                        const SizedBox(width: 3),
                        Flexible(child: badge),
                      ],
                    ),
                  if (details.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      details,
                      style: const TextStyle(fontSize: 10.5, height: 1.3),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    'Adopter: ${row['adopter_name'] ?? 'Not provided'}',
                    style: const TextStyle(fontSize: 11, height: 1.3),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    caption,
                    style: const TextStyle(fontSize: 10, height: 1.3),
                  ),
                  if (stacked) ...[const SizedBox(height: 6), badge],
                ],
              ),
            ),
            const SizedBox(width: 2),
            Padding(
              padding: const EdgeInsets.only(top: 26),
              child: Icon(
                update && expanded
                    ? Icons.expand_more_rounded
                    : Icons.chevron_right_rounded,
                size: 19,
                color: foreground,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PlacementCard extends StatelessWidget {
  final Map<String, dynamic> row;
  const _PlacementCard({required this.row});
  @override
  Widget build(BuildContext context) => Material(
    color: FurUColors.card(context),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: const Color(0xFFD99A58).withValues(alpha: .18)),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        useSafeArea: true,
        isScrollControlled: true,
        builder: (context) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Placement details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 14),
                _MonitoringIdentity(row: row),
                const SizedBox(height: 18),
                SelectableText('Placement ID: ${row['id'] ?? 'Unavailable'}'),
                if (row['approved_at'] != null)
                  Text('Approved: ${_date(row['approved_at'])}'),
                if (row['completed_at'] != null)
                  Text('Completed: ${_date(row['completed_at'])}'),
              ],
            ),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(9),
        child: _MonitoringIdentity(row: row),
      ),
    ),
  );
}

class _MonitoringUpdateCard extends StatefulWidget {
  final Map<String, dynamic> row;
  final bool initiallyExpanded;
  const _MonitoringUpdateCard({
    super.key,
    required this.row,
    this.initiallyExpanded = false,
  });
  @override
  State<_MonitoringUpdateCard> createState() => _MonitoringUpdateCardState();
}

class _MonitoringUpdateCardState extends State<_MonitoringUpdateCard> {
  late bool expanded = widget.initiallyExpanded;
  bool saving = false;
  String? notesError;
  late final notes = TextEditingController(
    text: '${widget.row['admin_notes'] ?? widget.row['adminNotes'] ?? ''}',
  );
  @override
  void didUpdateWidget(covariant _MonitoringUpdateCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.row['admin_notes'] != widget.row['admin_notes']) {
      notes.text = '${widget.row['admin_notes'] ?? ''}';
    }
  }

  @override
  void dispose() {
    notes.dispose();
    super.dispose();
  }

  Future<void> _review(bool clarification) async {
    if (saving) return;
    if (clarification && notes.text.trim().isEmpty) {
      setState(() => notesError = 'Explain what the adopter needs to clarify.');
      return;
    }
    setState(() {
      saving = true;
      notesError = null;
    });
    try {
      await AppScope.of(context).runAdminAction('review_monitoring', {
        'monitoring_update_id': widget.row['id'],
        'status': clarification ? 'needs_clarification' : 'reviewed',
        'reason': notes.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              clarification ? 'Clarification requested.' : 'Update reviewed.',
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) showError(context, error);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final row = widget.row;
    final canReview = _monitoringStatus(row) == 'pending_review';
    final foreground = Theme.of(context).colorScheme.onSurface;
    return Material(
      color: FurUColors.card(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(17),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant
              .withValues(alpha: .5),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            expanded: expanded,
            button: true,
            child: InkWell(
              onTap: saving ? null : () => setState(() => expanded = !expanded),
              child: Padding(
                padding: const EdgeInsets.all(9),
                child: _MonitoringIdentity(
                  row: row,
                  update: true,
                  expanded: expanded,
                ),
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Column(
                      children: [
                        for (final entry in const [
                          (
                            'pet_condition',
                            'Pet condition',
                            Icons.pets_rounded,
                          ),
                          ('feeding', 'Feeding', Icons.rice_bowl_outlined),
                          ('health', 'Health', Icons.monitor_heart_rounded),
                          (
                            'behavior',
                            'Behavior',
                            Icons.sentiment_satisfied_alt_rounded,
                          ),
                        ])
                          _MonitoringObservation(
                            label: entry.$2,
                            text: '${row[entry.$1] ?? ''}'.trim(),
                            icon: entry.$3,
                          ),
                      ],
                    ),
                  ),
                  if ('${row['notes'] ?? ''}'.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Adopter notes',
                      style: TextStyle(
                        color: foreground,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '${row['notes']}',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 18,
                        color: foreground,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          'Notes from staff',
                          style: TextStyle(
                            color: foreground,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (canReview)
                    TextField(
                      key: ValueKey('monitoring-notes-${row['id']}'),
                      controller: notes,
                      enabled: !saving,
                      style: const TextStyle(fontSize: 11, height: 1.4),
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Add your review notes...',
                        hintStyle: const TextStyle(fontSize: 11),
                        errorText: notesError,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        fillColor: Theme.of(context).scaffoldBackgroundColor,
                      ),
                      onChanged: (_) {
                        if (notesError != null) {
                          setState(() => notesError = null);
                        }
                      },
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        notes.text.isEmpty
                            ? 'No staff notes recorded.'
                            : notes.text,
                        style: const TextStyle(fontSize: 11, height: 1.4),
                      ),
                    ),
                  if (canReview) ...[
                    const SizedBox(height: 9),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final buttons = [
                          FilledButton.icon(
                            onPressed: saving ? null : () => _review(false),
                            icon: saving
                                ? const SizedBox.square(
                                    dimension: 15,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.check_rounded, size: 18),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(48, 48),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontFamily: 'NunitoSans',
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            label: const Text(
                              'Mark as reviewed',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: saving ? null : () => _review(true),
                            icon: const Icon(
                              Icons.description_outlined,
                              size: 17,
                            ),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(48, 48),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontFamily: 'NunitoSans',
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            label: const Text(
                              'Needs clarification',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ];
                        return constraints.maxWidth < 280 ||
                                MediaQuery.textScalerOf(context).scale(14) > 18
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  buttons[0],
                                  const SizedBox(height: 7),
                                  buttons[1],
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(child: buttons[0]),
                                  const SizedBox(width: 7),
                                  Expanded(child: buttons[1]),
                                ],
                              );
                      },
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MonitoringObservation extends StatelessWidget {
  final String label, text;
  final IconData icon;
  const _MonitoringObservation({
    required this.label,
    required this.text,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final title = Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 11,
                  height: 1.3,
                ),
              ),
            ),
          ],
        );
        final value = Text(
          text.isEmpty ? 'Not provided' : text,
          style: const TextStyle(fontSize: 11, height: 1.4),
        );
        return MediaQuery.textScalerOf(context).scale(14) > 18
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [title, const SizedBox(height: 4), value],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 4, child: title),
                  const SizedBox(width: 8),
                  Expanded(flex: 5, child: value),
                ],
              );
      },
    ),
  );
}
