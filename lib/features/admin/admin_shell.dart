import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/app_controller.dart';
import '../../core/theme.dart';
import '../../widgets/components.dart';
import '../../core/backend_config.dart';

part 'admin_dashboard.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});
  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int tab = 0;
  static const titles = [
    'Dashboard',
    'Pets & health',
    'Applications',
    'Monitoring',
    'More',
  ];

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return Scaffold(
      appBar: tab == 0
          ? null
          : AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titles[tab]),
                  Text(
                    'FurU × Whelps administration',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              actions: [
                IconButton(
                  tooltip: 'Refresh',
                  onPressed: app.adminLoading ? null : app.refreshAdminData,
                  icon: app.adminLoading
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Center(child: FurUStatusBadge('Admin')),
                ),
              ],
            ),
      body: SafeArea(
        top: tab == 0,
        child: IndexedStack(
          index: tab,
          children: [
            _AdminHome(onOpenTab: (value) => setState(() => tab = value)),
            const _PetHealthTab(),
            const _ApplicationsTab(),
            const _MonitoringTab(),
            const _MoreTab(),
          ],
        ),
      ),
      bottomNavigationBar: _AdminBottomNavigation(
        selectedIndex: tab,
        onSelected: (value) => setState(() => tab = value),
      ),
    );
  }
}

class _LoadingCards extends StatelessWidget {
  const _LoadingCards();
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 10,
    runSpacing: 10,
    children: List.generate(
      6,
      (_) => Container(
        width: (MediaQuery.sizeOf(context).width - 46) / 2,
        height: 128,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    ),
  );
}

class _PetHealthTab extends StatefulWidget {
  const _PetHealthTab();
  @override
  State<_PetHealthTab> createState() => _PetHealthTabState();
}

class _PetHealthTabState extends State<_PetHealthTab> {
  String search = '';
  String filter = 'all';

  @override
  Widget build(BuildContext context) {
    final rows = _rows(AppScope.of(context), 'pets').where((row) {
      final status = '${row['listing_status'] ?? 'pending'}';
      final haystack = '${row['name']} ${row['breed']} $status'.toLowerCase();
      return haystack.contains(search.toLowerCase()) &&
          (filter == 'all' || status == filter);
    }).toList();
    return _RefreshPage(
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 32),
        children: [
          TextField(
            onChanged: (value) => setState(() => search = value),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              hintText: 'Pet name, breed, or status',
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final value in [
                  'all',
                  'pending',
                  'active',
                  'corrections_requested',
                  'adopted',
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 7),
                    child: ChoiceChip(
                      label: Text(_pretty(value)),
                      selected: filter == value,
                      onSelected: (_) => setState(() => filter = value),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (rows.isEmpty)
            const EmptyState(
              icon: Icons.pets_outlined,
              title: 'No pet records in this view',
              message: 'New submissions and published pets will appear here.',
            )
          else
            for (final row in rows) ...[
              _PetHealthCard(row: row),
              const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}

class _PetHealthCard extends StatelessWidget {
  final Map<String, dynamic> row;
  const _PetHealthCard({required this.row});

  @override
  Widget build(BuildContext context) {
    final health = row['health'];
    final healthText = health is List && health.isNotEmpty
        ? health.join(' • ')
        : 'Health information awaiting verification';
    return Material(
      color: FurUColors.card(context),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _open(context, _ApprovalDetail(kind: 0, row: row)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(Icons.pets_rounded, size: 29),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${row['name'] ?? 'Pet'}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        FurUStatusBadge(
                          _pretty('${row['listing_status'] ?? 'pending'}'),
                        ),
                      ],
                    ),
                    Text('${row['breed'] ?? row['species'] ?? 'Animal'}'),
                    const SizedBox(height: 4),
                    Text(
                      healthText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApplicationsTab extends StatefulWidget {
  const _ApplicationsTab();
  @override
  State<_ApplicationsTab> createState() => _ApplicationsTabState();
}

class _ApplicationsTabState extends State<_ApplicationsTab> {
  String search = '';
  String filter = 'all';

  @override
  Widget build(BuildContext context) {
    final all = _rows(AppScope.of(context), 'applications');
    final rows = all.where((row) {
      final status = '${row['status'] ?? 'submitted'}';
      final haystack =
          '${row['id']} ${row['applicant_name']} '
                  '${row['applicant_email']} ${row['pet_name']} $status'
              .toLowerCase();
      return haystack.contains(search.toLowerCase()) &&
          (filter == 'all' || status == filter);
    }).toList();
    int count(Iterable<String> statuses) =>
        all.where((row) => statuses.contains('${row['status']}')).length;
    return _RefreshPage(
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 32),
        children: [
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'Submitted',
                  value: count(['submitted', 'under_review']),
                  color: FurUColors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniStat(
                  label: 'Approved',
                  value: count(['approved', 'handover', 'completed']),
                  color: const Color(0xFF2D9855),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniStat(
                  label: 'Rejected',
                  value: count(['rejected']),
                  color: const Color(0xFFD64C46),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            onChanged: (value) => setState(() => search = value),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              hintText: 'Applicant, pet, or application ID',
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final value in [
                  'all',
                  'submitted',
                  'under_review',
                  'approved',
                  'rejected',
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 7),
                    child: ChoiceChip(
                      label: Text(_pretty(value)),
                      selected: filter == value,
                      onSelected: (_) => setState(() => filter = value),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (rows.isEmpty)
            const EmptyState(
              icon: Icons.assignment_outlined,
              title: 'No matching applications',
              message: 'Try another status or search term.',
            )
          else
            for (final row in rows) ...[
              _ApprovalCard(kind: 1, row: row),
              const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
    decoration: BoxDecoration(
      color: FurUColors.card(context),
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: color.withValues(alpha: .22)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.circle, color: color, size: 10),
        const SizedBox(height: 7),
        Text('$value', style: Theme.of(context).textTheme.titleLarge),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
  );
}

class _MonitoringTab extends StatefulWidget {
  const _MonitoringTab();
  @override
  State<_MonitoringTab> createState() => _MonitoringTabState();
}

class _MonitoringTabState extends State<_MonitoringTab> {
  String search = '';

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    bool matches(Map<String, dynamic> row) =>
        _value(row).toLowerCase().contains(search.toLowerCase());
    final records = _rows(app, 'adoption_records').where(matches).toList();
    final active = records
        .where((row) => '${row['status']}' != 'completed')
        .toList();
    final completed = records
        .where((row) => '${row['status']}' == 'completed')
        .toList();
    final updates = _rows(app, 'monitoring_updates').where(matches).toList();
    return _RefreshPage(
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 32),
        children: [
          TextField(
            onChanged: (value) => setState(() => search = value),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              hintText: 'Pet, adopter, or status',
            ),
          ),
          const SizedBox(height: 20),
          _SectionTitle('Active monitoring', '${active.length} active'),
          const SizedBox(height: 10),
          if (active.isEmpty)
            const EmptyState(
              icon: Icons.monitor_heart_outlined,
              title: 'No active monitoring',
              message: 'Approved placements will appear here.',
            )
          else
            for (final row in active)
              _DataCard(
                title: '${row['pet_name'] ?? 'Pet ${_shortId(row['pet_id'])}'}',
                status: _pretty('${row['status']}'),
                lines: [
                  'Adopter ${row['adopter_name'] ?? _shortId(row['adopter_id'])}',
                  'Approved ${_date(row['approved_at'])}',
                ],
              ),
          const SizedBox(height: 20),
          _SectionTitle('Monitoring updates', '${updates.length} received'),
          const SizedBox(height: 10),
          if (updates.isEmpty)
            const EmptyState(
              icon: Icons.update_rounded,
              title: 'No monitoring updates',
              message: 'Adopter check-ins will appear here for review.',
            )
          else
            for (final row in updates) _MonitoringUpdateCard(row: row),
          if (completed.isNotEmpty) ...[
            const SizedBox(height: 20),
            _SectionTitle('Completed adoptions', '${completed.length} total'),
            const SizedBox(height: 10),
            for (final row in completed)
              _DataCard(
                title: '${row['pet_name'] ?? 'Pet ${_shortId(row['pet_id'])}'}',
                status: 'Completed',
                lines: ['Completed ${_date(row['completed_at'])}'],
              ),
          ],
        ],
      ),
    );
  }
}

class _MonitoringUpdateCard extends StatelessWidget {
  final Map<String, dynamic> row;
  const _MonitoringUpdateCard({required this.row});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: FurUSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${row['pet_name'] ?? 'Pet'} · ${row['adopter_name'] ?? 'Adopter'}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              FurUStatusBadge(_pretty('${row['status'] ?? 'pending_review'}')),
            ],
          ),
          Text(
            'Submitted ${_date(row['created_at'])}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          for (final entry in const {
            'pet_condition': 'Pet condition',
            'feeding': 'Feeding',
            'health': 'Health',
            'behavior': 'Behavior',
          }.entries)
            if ('${row[entry.key] ?? ''}'.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Text('${entry.value}: ${row[entry.key]}'),
              ),
          if ('${row['status'] ?? ''}' == 'pending_review') ...[
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () => _reviewMonitoring(context, row, false),
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Mark reviewed'),
                ),
                OutlinedButton(
                  onPressed: () => _reviewMonitoring(context, row, true),
                  child: const Text('Needs clarification'),
                ),
              ],
            ),
          ],
        ],
      ),
    ),
  );
}

Future<void> _reviewMonitoring(
  BuildContext context,
  Map<String, dynamic> row,
  bool clarification,
) async {
  try {
    await AppScope.of(context).runAdminAction('review_monitoring', {
      'monitoring_update_id': row['id'],
      'status': clarification ? 'needs_clarification' : 'reviewed',
      'reason': clarification
          ? 'The administrator requested clarification.'
          : 'Monitoring update reviewed.',
    });
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            clarification ? 'Clarification requested.' : 'Update reviewed.',
          ),
        ),
      );
    }
  } catch (error) {
    if (context.mounted) showError(context, error);
  }
}

class _ApprovalsTab extends StatefulWidget {
  const _ApprovalsTab();
  @override
  State<_ApprovalsTab> createState() => _ApprovalsTabState();
}

class _ApprovalsTabState extends State<_ApprovalsTab> {
  int segment = 0;
  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final keys = ['pets', 'applications', 'verifications'];
    final rows = _rows(app, keys[segment]);
    return _RefreshPage(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 32),
        children: [
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(
                value: 0,
                icon: Icon(Icons.pets_rounded),
                label: Text('Pets'),
              ),
              ButtonSegment(
                value: 1,
                icon: Icon(Icons.favorite_rounded),
                label: Text('Adoption'),
              ),
              ButtonSegment(
                value: 2,
                icon: Icon(Icons.apartment_rounded),
                label: Text('Orgs'),
              ),
            ],
            selected: {segment},
            showSelectedIcon: false,
            onSelectionChanged: (value) =>
                setState(() => segment = value.first),
          ),
          const SizedBox(height: 16),
          if (rows.isEmpty)
            EmptyState(
              icon: [
                Icons.pets_outlined,
                Icons.favorite_outline_rounded,
                Icons.apartment_outlined,
              ][segment],
              title: 'Queue is clear',
              message: 'New items needing review will appear here.',
            )
          else
            for (final row in rows) ...[
              _ApprovalCard(kind: segment, row: row),
              const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}

class _ApprovalCard extends StatelessWidget {
  final int kind;
  final Map<String, dynamic> row;
  const _ApprovalCard({required this.kind, required this.row});
  @override
  Widget build(BuildContext context) {
    final title = kind == 0
        ? '${row['name'] ?? 'Pet listing'}'
        : kind == 1
        ? '${row['applicant_name'] ?? 'Application ${_shortId(row['id'])}'}'
        : 'Organization ${_shortId(row['organization_id'])}';
    final detail = kind == 0
        ? '${row['breed'] ?? row['species'] ?? 'Pet record'}'
        : kind == 1
        ? '${row['pet_name'] ?? 'Pet ${_shortId(row['pet_id'])}'}'
        : '${row['registration_number'] ?? 'Verification request'}';
    final status = '${row['listing_status'] ?? row['status'] ?? 'pending'}';
    return Material(
      color: FurUColors.card(context),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => _ApprovalDetail(kind: kind, row: row),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  [
                    Icons.pets_rounded,
                    Icons.favorite_rounded,
                    Icons.apartment_rounded,
                  ][kind],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 5),
                    FurUStatusBadge(_pretty(status)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApprovalDetail extends StatelessWidget {
  final int kind;
  final Map<String, dynamic> row;
  const _ApprovalDetail({required this.kind, required this.row});

  @override
  Widget build(BuildContext context) {
    final hidden = {
      'id',
      'owner_id',
      'applicant_id',
      'organization_id',
      'reviewed_by',
    };
    return Scaffold(
      appBar: AppBar(
        title: Text(
          [
            'Pet review',
            'Adoption screening',
            'Organization verification',
          ][kind],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 130),
        children: [
          FurUSectionCard(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Row(
              children: [
                Icon(
                  [
                    Icons.pets_rounded,
                    Icons.favorite_rounded,
                    Icons.apartment_rounded,
                  ][kind],
                  size: 38,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        kind == 0
                            ? '${row['name'] ?? 'Pet'}'
                            : _shortId(row['id']),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text('Submitted ${_date(row['created_at'])}'),
                    ],
                  ),
                ),
                FurUStatusBadge(
                  _pretty(
                    '${row['listing_status'] ?? row['status'] ?? 'pending'}',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          for (final entry in row.entries.where(
            (e) => !hidden.contains(e.key) && e.value != null,
          ))
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: FurUSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _pretty(entry.key),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _value(entry.value),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: FilledButton.icon(
            onPressed: () => _showDecision(context, kind, row),
            icon: const Icon(Icons.fact_check_rounded),
            label: const Text('Record review decision'),
          ),
        ),
      ),
    );
  }
}

Future<void> _showDecision(
  BuildContext context,
  int kind,
  Map<String, dynamic> row,
) async {
  final options = kind == 0
      ? const {
          'Approve & publish': 'active',
          'Request corrections': 'corrections_requested',
          'Reject': 'rejected',
          'Remove listing': 'removed',
        }
      : kind == 1
      ? const {
          'Start screening': 'under_review',
          'Request information': 'more_information',
          'Approve — awaiting placement': 'approved',
          'Reject application': 'rejected',
        }
      : const {
          'Verify organization': 'verified',
          'Request information': 'more_information',
          'Reject verification': 'rejected',
          'Revoke verification': 'revoked',
        };
  var selected = options.values.first;
  final reason = TextEditingController();
  final assessments = <String, String>{
    'housing_evaluation': 'Suitable',
    'financial_evaluation': 'Suitable',
    'experience_evaluation': 'Suitable',
    'readiness_evaluation': 'Suitable',
  };
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) => StatefulBuilder(
      builder: (context, setState) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          18,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Review decision',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: selected,
              decoration: const InputDecoration(labelText: 'Decision'),
              items: [
                for (final entry in options.entries)
                  DropdownMenuItem(value: entry.value, child: Text(entry.key)),
              ],
              onChanged: (value) => setState(() => selected = value!),
            ),
            if (kind == 1) ...[
              const SizedBox(height: 12),
              for (final criterion in const {
                'housing_evaluation': 'Housing',
                'financial_evaluation': 'Financial capability',
                'experience_evaluation': 'Pet experience',
                'readiness_evaluation': 'Readiness',
              }.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: DropdownButtonFormField<String>(
                    initialValue: assessments[criterion.key],
                    decoration: InputDecoration(labelText: criterion.value),
                    items:
                        const [
                              'Suitable',
                              'Needs Clarification',
                              'Concern Identified',
                            ]
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              ),
                            )
                            .toList(),
                    onChanged: (value) => assessments[criterion.key] = value!,
                  ),
                ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: reason,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Reason or reviewer note',
                hintText: 'Required for the audit trail',
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                if (reason.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Add a reason before continuing.'),
                    ),
                  );
                  return;
                }
                Navigator.pop(context, true);
              },
              child: const Text('Confirm decision'),
            ),
          ],
        ),
      ),
    ),
  );
  if (confirmed != true || !context.mounted) {
    reason.dispose();
    return;
  }
  final app = AppScope.of(context);
  try {
    await app.runAdminAction(
      kind == 0
          ? 'review_pet'
          : kind == 1
          ? 'review_application'
          : 'verify_organization',
      {
        if (kind == 0) 'pet_id': row['id'],
        if (kind == 1) 'application_id': row['id'],
        if (kind == 2) 'user_id': row['organization_id'],
        'status': selected,
        'reason': reason.text.trim(),
        if (kind == 1) ...assessments,
      },
    );
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Decision saved and audited.')),
      );
    }
  } catch (error) {
    if (context.mounted) showError(context, error);
  }
  reason.dispose();
}

class _UsersTab extends StatefulWidget {
  const _UsersTab();
  @override
  State<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<_UsersTab> {
  String search = '';
  String filter = 'all';
  @override
  Widget build(BuildContext context) {
    final users = _rows(AppScope.of(context), 'users').where((row) {
      final text = '${row['full_name']} ${row['email']} ${row['id']}'
          .toLowerCase();
      return text.contains(search.toLowerCase()) &&
          (filter == 'all' ||
              row['account_status'] == filter ||
              row['account_type'] == filter);
    }).toList();
    return _RefreshPage(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 32),
        children: [
          TextField(
            onChanged: (value) => setState(() => search = value),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              hintText: 'Name, email, or account ID',
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final value in [
                  'all',
                  'active',
                  'suspended',
                  'banned',
                  'organization',
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 7),
                    child: ChoiceChip(
                      label: Text(_pretty(value)),
                      selected: filter == value,
                      onSelected: (_) => setState(() => filter = value),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          if (users.isEmpty)
            const EmptyState(
              icon: Icons.person_search_rounded,
              title: 'No matching users',
              message: 'Try another search or filter.',
            ),
          for (final user in users) ...[
            _UserCard(user: user),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  const _UserCard({required this.user});
  @override
  Widget build(BuildContext context) {
    final name = '${user['full_name'] ?? 'FurU member'}';
    return FurUSectionCard(
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                child: Text(name.isEmpty ? 'F' : name[0].toUpperCase()),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      '${user['email'] ?? ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              FurUStatusBadge(_pretty('${user['account_status'] ?? 'active'}')),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_pretty('${user['account_type'] ?? 'individual'}')} • Joined ${_date(user['created_at'])}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              TextButton(
                onPressed: () => _showUserActions(context, user),
                child: const Text('Manage'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> _showUserActions(
  BuildContext context,
  Map<String, dynamic> user,
) async {
  final current = '${user['account_status'] ?? 'active'}';
  final status = await showModalBottomSheet<String>(
    context: context,
    useSafeArea: true,
    builder: (context) => Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${user['full_name'] ?? 'Member'}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text('${user['email'] ?? ''}'),
          const SizedBox(height: 16),
          if (current != 'active')
            ListTile(
              leading: const Icon(Icons.replay_rounded),
              title: const Text('Reactivate account'),
              onTap: () => Navigator.pop(context, 'active'),
            ),
          if (current != 'suspended')
            ListTile(
              leading: const Icon(Icons.pause_circle_outline_rounded),
              title: const Text('Suspend account'),
              onTap: () => Navigator.pop(context, 'suspended'),
            ),
          if (current != 'banned')
            ListTile(
              leading: const Icon(Icons.block_rounded),
              title: const Text('Ban account'),
              textColor: Theme.of(context).colorScheme.error,
              iconColor: Theme.of(context).colorScheme.error,
              onTap: () => Navigator.pop(context, 'banned'),
            ),
        ],
      ),
    ),
  );
  if (status == null || !context.mounted) return;
  final reason = TextEditingController();
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('${_pretty(status)} account?'),
      content: TextField(
        controller: reason,
        maxLines: 3,
        decoration: const InputDecoration(labelText: 'Required reason'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (reason.text.trim().isNotEmpty) Navigator.pop(context, true);
          },
          child: const Text('Confirm'),
        ),
      ],
    ),
  );
  if (confirmed == true && context.mounted) {
    try {
      await AppScope.of(context).runAdminAction('set_user_status', {
        'user_id': user['id'],
        'status': status,
        'reason': reason.text.trim(),
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account ${_pretty(status).toLowerCase()}.')),
        );
      }
    } catch (error) {
      if (context.mounted) showError(context, error);
    }
  }
  reason.dispose();
}

class _ReportsTab extends StatefulWidget {
  const _ReportsTab();
  @override
  State<_ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends State<_ReportsTab> {
  String filter = 'open';
  @override
  Widget build(BuildContext context) {
    final reports = _rows(AppScope.of(context), 'reports')
        .where(
          (row) =>
              filter == 'all' ||
              (filter == 'open'
                  ? ['new', 'under_review'].contains(row['status'])
                  : row['status'] == filter),
        )
        .toList();
    return _RefreshPage(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 32),
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final value in ['open', 'all', 'resolved', 'dismissed'])
                  Padding(
                    padding: const EdgeInsets.only(right: 7),
                    child: ChoiceChip(
                      label: Text(_pretty(value)),
                      selected: filter == value,
                      onSelected: (_) => setState(() => filter = value),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          if (reports.isEmpty)
            const EmptyState(
              icon: Icons.health_and_safety_outlined,
              title: 'No reports here',
              message: 'Reports matching this filter will appear here.',
            ),
          for (final report in reports) ...[
            _ReportCard(report: report),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final Map<String, dynamic> report;
  const _ReportCard({required this.report});
  @override
  Widget build(BuildContext context) => FurUSectionCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _pretty('${report['category'] ?? 'other'}'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            FurUStatusBadge(_pretty('${report['status'] ?? 'new'}')),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '${report['details'] ?? ''}',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Text(
                _date(report['created_at']),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            TextButton(
              onPressed: () => _resolveReport(context, report),
              child: const Text('Investigate'),
            ),
          ],
        ),
      ],
    ),
  );
}

Future<void> _resolveReport(
  BuildContext context,
  Map<String, dynamic> report,
) async {
  var status = 'under_review';
  final note = TextEditingController();
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Report investigation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: status,
              items: const [
                DropdownMenuItem(
                  value: 'under_review',
                  child: Text('Under review'),
                ),
                DropdownMenuItem(value: 'resolved', child: Text('Resolved')),
                DropdownMenuItem(value: 'dismissed', child: Text('Dismissed')),
              ],
              onChanged: (value) => setState(() => status = value!),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: note,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Investigation notes',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (note.text.trim().isNotEmpty) Navigator.pop(context, true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
  if (result == true && context.mounted) {
    try {
      await AppScope.of(context).runAdminAction('resolve_report', {
        'report_id': report['id'],
        'status': status,
        'reason': note.text.trim(),
      });
    } catch (error) {
      if (context.mounted) showError(context, error);
    }
  }
  note.dispose();
}

class _MoreTab extends StatelessWidget {
  const _MoreTab();
  @override
  Widget build(BuildContext context) => _RefreshPage(
    child: ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
      children: [
        Text(
          'Administration tools',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 5),
        Text(
          'Messages, evaluation, account management, and system controls.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 14),
        _MoreTile(
          Icons.forum_outlined,
          'Messages',
          'Approved adopters and monitoring conversations',
          () => _open(context, const _MessagesScreen()),
        ),
        _MoreTile(
          Icons.insights_rounded,
          'System evaluation',
          'Feedback, outcomes, and activity trends',
          () => _open(context, const _AnalyticsScreen()),
        ),
        _MoreTile(
          Icons.people_outline_rounded,
          'User management',
          'Search, suspend, or restore accounts',
          () => _open(
            context,
            const _ModulePage(title: 'User management', child: _UsersTab()),
          ),
        ),
        _MoreTile(
          Icons.shield_outlined,
          'Reports & moderation',
          'Investigate safety and welfare reports',
          () => _open(
            context,
            const _ModulePage(
              title: 'Reports & moderation',
              child: _ReportsTab(),
            ),
          ),
        ),
        _MoreTile(
          Icons.verified_user_outlined,
          'Organization verification',
          'Review rescue and shelter credentials',
          () => _open(context, const _OrganizationScreen()),
        ),
        _MoreTile(
          Icons.handshake_outlined,
          'Adoption records',
          'Handover and completion history',
          () => _open(context, const _RecordsScreen()),
        ),
        _MoreTile(
          Icons.campaign_outlined,
          'Notifications',
          'Announcements and delivery history',
          () => _open(context, const _NotificationsScreen()),
        ),
        _MoreTile(
          Icons.history_rounded,
          'Audit logs',
          'Append-only administrator actions',
          () => _open(context, const _AuditScreen()),
        ),
        _MoreTile(
          Icons.settings_outlined,
          'Settings',
          'Theme, notifications, access, and storage',
          () => _open(context, const _AdminSettingsScreen()),
        ),
        _MoreTile(
          Icons.admin_panel_settings_outlined,
          'Administrator profile',
          'Authorized Whelps administrator account',
          () => _open(context, const _AdminProfileScreen()),
        ),
      ],
    ),
  );
}

class _MoreTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  const _MoreTile(this.icon, this.title, this.subtitle, this.onTap);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Material(
      color: FurUColors.card(context),
      borderRadius: BorderRadius.circular(19),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(icon),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    ),
  );
}

class _RecordsScreen extends StatelessWidget {
  const _RecordsScreen();
  @override
  Widget build(BuildContext context) {
    final rows = _rows(AppScope.of(context), 'adoption_records');
    return _SimplePage(
      title: 'Adoption records',
      child: rows.isEmpty
          ? const EmptyState(
              icon: Icons.handshake_outlined,
              title: 'No completed records',
              message:
                  'Confirmed handovers will create permanent adoption records.',
            )
          : ListView(
              children: [
                for (final row in rows)
                  _DataCard(
                    title: 'Adoption ${_shortId(row['id'])}',
                    status: _pretty('${row['status']}'),
                    lines: [
                      'Pet ${_shortId(row['pet_id'])}',
                      'Approved ${_date(row['approved_at'])}',
                      'Completed ${_date(row['completed_at'])}',
                    ],
                  ),
              ],
            ),
    );
  }
}

class _ModulePage extends StatelessWidget {
  final String title;
  final Widget child;
  const _ModulePage({required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: child,
  );
}

class _OrganizationScreen extends StatelessWidget {
  const _OrganizationScreen();

  @override
  Widget build(BuildContext context) {
    final rows = _rows(AppScope.of(context), 'verifications');
    return _SimplePage(
      title: 'Organization verification',
      child: rows.isEmpty
          ? const EmptyState(
              icon: Icons.verified_user_outlined,
              title: 'No organizations awaiting review',
              message: 'Submitted rescue and shelter credentials appear here.',
            )
          : ListView(
              children: [
                for (final row in rows) ...[
                  _ApprovalCard(kind: 2, row: row),
                  const SizedBox(height: 10),
                ],
              ],
            ),
    );
  }
}

class _MessagesScreen extends StatefulWidget {
  const _MessagesScreen();
  @override
  State<_MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<_MessagesScreen> {
  String search = '';
  String filter = 'all';

  @override
  Widget build(BuildContext context) {
    final rows = _rows(AppScope.of(context), 'conversations').where((row) {
      final text = '${row['participant_name']} ${row['pet_name']}'
          .toLowerCase();
      final type = '${row['category'] ?? 'approved'}';
      return text.contains(search.toLowerCase()) &&
          (filter == 'all' || type == filter);
    }).toList();
    return _SimplePage(
      title: 'Messages',
      child: Column(
        children: [
          TextField(
            onChanged: (value) => setState(() => search = value),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              hintText: 'Search name or pet',
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final value in ['all', 'approved', 'adopted'])
                  Padding(
                    padding: const EdgeInsets.only(right: 7),
                    child: ChoiceChip(
                      label: Text(
                        value == 'adopted' ? 'Adopted pets' : _pretty(value),
                      ),
                      selected: filter == value,
                      onSelected: (_) => setState(() => filter = value),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: rows.isEmpty
                ? const EmptyState(
                    icon: Icons.forum_outlined,
                    title: 'No conversations yet',
                    message: 'Approved adopter conversations will appear here.',
                  )
                : ListView(
                    children: [
                      for (final row in rows)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 9),
                          child: Material(
                            color: FurUColors.card(context),
                            borderRadius: BorderRadius.circular(19),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              leading: CircleAvatar(
                                child: Text(
                                  '${row['participant_name'] ?? 'A'}'[0]
                                      .toUpperCase(),
                                ),
                              ),
                              title: Text(
                                '${row['participant_name'] ?? 'Adopter'}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              subtitle: Text(
                                '${row['pet_name'] ?? 'Pet'} · ${row['last_message'] ?? 'Open conversation'}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: const Icon(Icons.chevron_right_rounded),
                              onTap: () => _open(
                                context,
                                _ConversationScreen(conversation: row),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _ConversationScreen extends StatefulWidget {
  final Map<String, dynamic> conversation;
  const _ConversationScreen({required this.conversation});
  @override
  State<_ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<_ConversationScreen> {
  final message = TextEditingController();
  bool sending = false;

  @override
  void dispose() {
    message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = (widget.conversation['messages'] as List? ?? const [])
        .map((value) => _map(value))
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${widget.conversation['participant_name'] ?? 'Adopter'}'),
            Text(
              '${widget.conversation['pet_name'] ?? 'Adoption conversation'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const EmptyState(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'Start the conversation',
                    message: 'Send a clear update or monitoring reminder.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(18),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final item = messages[index];
                      final admin = item['sender_role'] == 'admin';
                      return Align(
                        alignment: admin
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 290),
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: admin
                                ? Theme.of(context).colorScheme.primaryContainer
                                : FurUColors.card(context),
                            borderRadius: BorderRadius.circular(17),
                          ),
                          child: Text('${item['body'] ?? ''}'),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                12,
                8,
                12,
                10 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: message,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Write a message',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'Send message',
                    onPressed: sending ? null : _send,
                    icon: sending
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _send() async {
    final body = message.text.trim();
    if (body.isEmpty) return;
    setState(() => sending = true);
    try {
      await AppScope.of(context).runAdminAction('send_message', {
        'conversation_id': widget.conversation['id'],
        'body': body,
      });
      message.clear();
    } catch (error) {
      if (mounted) showError(context, error);
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }
}

class _AnalyticsScreen extends StatelessWidget {
  const _AnalyticsScreen();
  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final stats = _map(app.adminWorkspace['stats']);
    final analytics = _map(app.adminWorkspace['analytics']);
    final applicationRows = _rows(app, 'applications');
    int outcomeCount(Iterable<String> statuses) => applicationRows
        .where((row) => statuses.contains('${row['status']}'))
        .length;
    final applications = _trendValues(analytics['monthly_applications']);
    final adoptions = _trendValues(analytics['monthly_adoptions']);
    final points = _monthlyPoints(applications, adoptions);
    final hasTrendData = applications.isNotEmpty || adoptions.isNotEmpty;
    return _SimplePage(
      title: 'System evaluation',
      child: ListView(
        children: [
          Text(
            'Platform outcomes',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Feedback and operational results from the live workflow.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _AnalyticsTotal(
                  label: 'Average rating',
                  value: '${stats['average_rating'] ?? 0}',
                  color: FurUColors.orange,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AnalyticsTotal(
                  label: 'Feedback submissions',
                  value: '${stats['feedback_submissions'] ?? 0}',
                  color: const Color(0xFF5C8CC7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _AnalyticsTotal(
                  label: 'Completed adoptions',
                  value: '${stats['completed_adoptions'] ?? 0}',
                  color: const Color(0xFF42A66A),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AnalyticsTotal(
                  label: 'Monitoring updates',
                  value: '${stats['monitoring_updates'] ?? 0}',
                  color: const Color(0xFF9B70C4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Adoption activity',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Applications and completed adoptions over the last 12 months',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          if (app.adminLoading && !hasTrendData)
            Container(
              height: 280,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Center(child: CircularProgressIndicator()),
            )
          else if (!hasTrendData)
            const EmptyState(
              icon: Icons.show_chart_rounded,
              title: 'No monthly activity yet',
              message: 'The line graph will fill automatically after applications and completed adoptions are recorded.',
            )
          else
            _MonthlyLineChart(points: points),
          const SizedBox(height: 20),
          Text('Current totals', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _AnalyticsTotal(
                  label: 'Applications pending',
                  value: '${stats['pending_applications'] ?? 0}',
                  color: FurUColors.orange,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AnalyticsTotal(
                  label: 'Adoptions completed',
                  value: '${stats['completed_adoptions'] ?? 0}',
                  color: const Color(0xFF42A66A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _AnalyticsTotal(
                  label: 'Completion rate',
                  value: '${analytics['completion_rate'] ?? 0}%',
                  color: const Color(0xFF5C8CC7),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AnalyticsTotal(
                  label: 'Reports resolved',
                  value: '${analytics['report_resolution_rate'] ?? 0}%',
                  color: const Color(0xFF9B70C4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            'Application outcomes',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'Submitted',
                  value: outcomeCount(['submitted', 'under_review']),
                  color: FurUColors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniStat(
                  label: 'Approved',
                  value: outcomeCount(['approved', 'handover', 'completed']),
                  color: const Color(0xFF42A66A),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniStat(
                  label: 'Rejected',
                  value: outcomeCount(['rejected']),
                  color: const Color(0xFFD64C46),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnalyticsTotal extends StatelessWidget {
  final String label, value;
  final Color color;
  const _AnalyticsTotal({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => FurUSectionCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 5,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 10),
        Text(value, style: Theme.of(context).textTheme.headlineSmall),
        Text(label, maxLines: 2, style: Theme.of(context).textTheme.bodySmall),
      ],
    ),
  );
}

class _TrendPoint {
  final DateTime month;
  final int applications, adoptions;
  const _TrendPoint(this.month, this.applications, this.adoptions);
}

Map<DateTime, int> _trendValues(dynamic raw) {
  final result = <DateTime, int>{};
  for (final value in raw as List? ?? const []) {
    final row = _map(value);
    final parsed = DateTime.tryParse('${row['month'] ?? ''}');
    if (parsed == null) continue;
    result[DateTime(parsed.year, parsed.month)] =
        (row['total'] as num?)?.toInt() ?? 0;
  }
  return result;
}

List<_TrendPoint> _monthlyPoints(
  Map<DateTime, int> applications,
  Map<DateTime, int> adoptions,
) {
  final now = DateTime.now();
  return List.generate(12, (index) {
    final offset = 11 - index;
    final month = DateTime(now.year, now.month - offset);
    return _TrendPoint(month, applications[month] ?? 0, adoptions[month] ?? 0);
  });
}

class _MonthlyLineChart extends StatefulWidget {
  final List<_TrendPoint> points;
  const _MonthlyLineChart({required this.points});
  @override
  State<_MonthlyLineChart> createState() => _MonthlyLineChartState();
}

class _MonthlyLineChartState extends State<_MonthlyLineChart> {
  int? selected;

  void inspect(TapDownDetails details, double width) {
    const left = 40.0;
    const right = 12.0;
    final usable = math.max(1.0, width - left - right);
    final fraction = ((details.localPosition.dx - left) / usable).clamp(0, 1);
    setState(() {
      selected = (fraction * (widget.points.length - 1)).round();
    });
  }

  @override
  Widget build(BuildContext context) {
    final chosen = selected == null ? null : widget.points[selected!];
    const applicationColor = Color(0xFFFF8B2B);
    const adoptionColor = Color(0xFF42A66A);
    final semanticSummary = widget.points
        .map(
          (point) =>
              '${_monthName(point.month.month)} ${point.month.year}: '
              '${point.applications} applications and ${point.adoptions} completed adoptions',
        )
        .join('. ');
    return FurUSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: const [
              _Legend(color: applicationColor, label: 'Applications'),
              _Legend(color: adoptionColor, label: 'Completed adoptions'),
            ],
          ),
          const SizedBox(height: 14),
          if (chosen != null)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Container(
                key: ValueKey(chosen.month),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text(
                  '${_monthName(chosen.month.month)} ${chosen.month.year}  •  '
                  '${chosen.applications} applications  •  '
                  '${chosen.adoptions} completed',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            )
          else
            Text(
              'Tap the graph to inspect a month',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) => Semantics(
              label: 'Monthly adoption activity line graph. $semanticSummary',
              image: true,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) => inspect(details, constraints.maxWidth),
                onHorizontalDragUpdate: (details) => inspect(
                  TapDownDetails(localPosition: details.localPosition),
                  constraints.maxWidth,
                ),
                child: SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _TrendChartPainter(
                      points: widget.points,
                      selected: selected,
                      gridColor: Theme.of(context).dividerColor,
                      labelColor: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant,
                      applicationColor: applicationColor,
                      adoptionColor: adoptionColor,
                    ),
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

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 18,
        height: 4,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      const SizedBox(width: 6),
      Flexible(
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
    ],
  );
}

class _TrendChartPainter extends CustomPainter {
  final List<_TrendPoint> points;
  final int? selected;
  final Color gridColor, labelColor, applicationColor, adoptionColor;
  const _TrendChartPainter({
    required this.points,
    required this.selected,
    required this.gridColor,
    required this.labelColor,
    required this.applicationColor,
    required this.adoptionColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const left = 40.0;
    const right = 12.0;
    const top = 10.0;
    const bottom = 30.0;
    final chart = Rect.fromLTRB(
      left,
      top,
      size.width - right,
      size.height - bottom,
    );
    final highest = points.fold<int>(1, (current, point) {
      return math.max(current, math.max(point.applications, point.adoptions));
    });
    final ceiling = _niceCeiling(highest);
    final gridPaint = Paint()
      ..color = gridColor.withValues(alpha: .55)
      ..strokeWidth = 1;

    for (var row = 0; row <= 4; row++) {
      final y = chart.top + chart.height * row / 4;
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), gridPaint);
      _paintText(
        canvas,
        '${(ceiling * (4 - row) / 4).round()}',
        Offset(0, y - 7),
        labelColor,
        width: left - 6,
        align: TextAlign.right,
      );
    }

    double xAt(int index) =>
        chart.left + chart.width * index / (points.length - 1);
    double yAt(int value) => chart.bottom - chart.height * value / ceiling;

    Path lineFor(int Function(_TrendPoint) valueOf) {
      final path = Path();
      for (var index = 0; index < points.length; index++) {
        final position = Offset(xAt(index), yAt(valueOf(points[index])));
        if (index == 0) {
          path.moveTo(position.dx, position.dy);
        } else {
          path.lineTo(position.dx, position.dy);
        }
      }
      return path;
    }

    final applicationPath = lineFor((point) => point.applications);
    final adoptionPath = lineFor((point) => point.adoptions);
    final area = Path.from(applicationPath)
      ..lineTo(chart.right, chart.bottom)
      ..lineTo(chart.left, chart.bottom)
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            applicationColor.withValues(alpha: .18),
            applicationColor.withValues(alpha: .01),
          ],
        ).createShader(chart),
    );
    canvas.drawPath(
      applicationPath,
      Paint()
        ..color = applicationColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawPath(
      adoptionPath,
      Paint()
        ..color = adoptionColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    for (var index = 0; index < points.length; index++) {
      if (index % 3 == 0 || index == points.length - 1) {
        _paintText(
          canvas,
          _monthName(points[index].month.month),
          Offset(xAt(index) - 18, chart.bottom + 8),
          labelColor,
          width: 36,
          align: TextAlign.center,
        );
      }
      for (final series in [
        (points[index].applications, applicationColor),
        (points[index].adoptions, adoptionColor),
      ]) {
        canvas.drawCircle(
          Offset(xAt(index), yAt(series.$1)),
          selected == index ? 5 : 3,
          Paint()..color = series.$2,
        );
      }
    }

    if (selected != null) {
      final x = xAt(selected!);
      canvas.drawLine(
        Offset(x, chart.top),
        Offset(x, chart.bottom),
        Paint()
          ..color = labelColor.withValues(alpha: .45)
          ..strokeWidth = 1,
      );
    }
  }

  int _niceCeiling(int value) {
    if (value <= 4) return 4;
    final magnitude = math.pow(10, value.toString().length - 1).toInt();
    return ((value / magnitude).ceil() * magnitude).toInt();
  }

  void _paintText(
    Canvas canvas,
    String text,
    Offset offset,
    Color color, {
    required double width,
    required TextAlign align,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
      textAlign: align,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: width);
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_TrendChartPainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.selected != selected ||
      oldDelegate.gridColor != gridColor ||
      oldDelegate.labelColor != labelColor;
}

String _monthName(int month) => const [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
][month - 1];

class _NotificationsScreen extends StatelessWidget {
  const _NotificationsScreen();
  @override
  Widget build(BuildContext context) {
    final rows = _rows(AppScope.of(context), 'notifications');
    return _SimplePage(
      title: 'Notifications',
      action: IconButton(
        onPressed: () => _announcement(context),
        tooltip: 'New announcement',
        icon: const Icon(Icons.add_rounded),
      ),
      child: ListView(
        children: [
          FilledButton.icon(
            onPressed: () => _announcement(context),
            icon: const Icon(Icons.campaign_rounded),
            label: const Text('Send announcement'),
          ),
          const SizedBox(height: 16),
          if (rows.isEmpty)
            const EmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'No notification history',
              message: 'Announcements and decision notices will appear here.',
            )
          else
            for (final row in rows.take(100))
              _DataCard(
                title: '${row['title']}',
                status: _date(row['created_at']),
                lines: ['${row['body']}'],
              ),
        ],
      ),
    );
  }
}

Future<void> _announcement(BuildContext context) async {
  final title = TextEditingController();
  final body = TextEditingController();
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('New announcement'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: title,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: body,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Message'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (title.text.trim().isNotEmpty && body.text.trim().isNotEmpty) {
              Navigator.pop(context, true);
            }
          },
          child: const Text('Send'),
        ),
      ],
    ),
  );
  if (ok == true && context.mounted) {
    try {
      await AppScope.of(context).runAdminAction('send_announcement', {
        'title': title.text.trim(),
        'body': body.text.trim(),
      });
    } catch (error) {
      if (context.mounted) showError(context, error);
    }
  }
  title.dispose();
  body.dispose();
}

class _AuditScreen extends StatelessWidget {
  const _AuditScreen();
  @override
  Widget build(BuildContext context) {
    final rows = _rows(AppScope.of(context), 'audit_logs');
    return _SimplePage(
      title: 'Audit logs',
      child: rows.isEmpty
          ? const EmptyState(
              icon: Icons.history_rounded,
              title: 'No audit entries',
              message: 'Sensitive admin actions are recorded by the database.',
            )
          : ListView(
              children: [for (final row in rows) _ActivityTile(row: row)],
            ),
    );
  }
}

class _AdminSettingsScreen extends StatelessWidget {
  const _AdminSettingsScreen();
  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return _SimplePage(
      title: 'Admin settings',
      child: ListView(
        children: [
          FurUSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.notifications_active_outlined),
                const SizedBox(height: 10),
                Text(
                  'Notifications',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Application, message, and monitoring alerts appear in the administrator workspace.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FurUSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.security_rounded),
                const SizedBox(height: 10),
                Text(
                  'Secure administrator access',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  app.usesSecureBackend
                      ? 'Administrator access is controlled by authenticated roles and database policies.'
                      : 'Connect the configured backend to enforce administrator roles and security policies.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FurUSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.storage_rounded),
                const SizedBox(height: 10),
                Text(
                  'Database & storage',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  app.usesSecureBackend
                      ? 'Application data, pet images, and private documents use the connected backend.'
                      : 'Backend configuration is required before cloud sync and private uploads are enabled.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FurUSectionCard(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Dark theme'),
                  secondary: const Icon(Icons.dark_mode_outlined),
                  value: app.themePreference == AppThemePreference.dark,
                  onChanged: (value) => app.setThemePreference(
                    value
                        ? AppThemePreference.dark
                        : AppThemePreference.defaultTheme,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminProfileScreen extends StatelessWidget {
  const _AdminProfileScreen();

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final name = app.profile?.name ?? 'Whelps Administrator';
    return _SimplePage(
      title: 'Administrator profile',
      child: ListView(
        children: [
          FurUSectionCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: FurUColors.orange,
                  foregroundColor: Colors.white,
                  child: Text(
                    name.isEmpty ? 'W' : name[0].toUpperCase(),
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: Theme.of(context).textTheme.titleLarge),
                      Text(app.profile?.email ?? ''),
                      const SizedBox(height: 6),
                      const FurUStatusBadge('Administrator'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FurUSectionCard(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.lock_person_outlined),
              title: Text('Account security'),
              subtitle: Text(
                'This account is protected by authentication and administrator role policies.',
              ),
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await app.signOut();
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}

class _SimplePage extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? action;
  const _SimplePage({required this.title, required this.child, this.action});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(title),
      actions: action == null ? null : [action!],
    ),
    body: PageBody(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
        child: child,
      ),
    ),
  );
}

class _DataCard extends StatelessWidget {
  final String title, status;
  final List<String> lines;
  const _DataCard({
    required this.title,
    required this.status,
    required this.lines,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: FurUSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              FurUStatusBadge(status),
            ],
          ),
          const SizedBox(height: 7),
          for (final line in lines) Text(line),
        ],
      ),
    ),
  );
}

class _ActivityTile extends StatelessWidget {
  final Map<String, dynamic> row;
  const _ActivityTile({required this.row});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: FurUSectionCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: const Icon(Icons.history_rounded),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _pretty('${row['action_type'] ?? 'Admin action'}'),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  '${row['reason'] ?? 'Recorded securely'}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _date(row['created_at']),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  final String title, trailing;
  const _SectionTitle(this.title, this.trailing);
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      ),
      Text(trailing, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}

class _AdminSyncNotice extends StatelessWidget {
  final String message;
  const _AdminSyncNotice({required this.message});

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.cloud_sync_outlined,
            color: Theme.of(context).colorScheme.onTertiaryContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onTertiaryContainer,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _RefreshPage extends StatelessWidget {
  final Widget child;
  const _RefreshPage({required this.child});
  @override
  Widget build(BuildContext context) => PageBody(
    child: RefreshIndicator(
      onRefresh: AppScope.of(context).refreshAdminData,
      child: child,
    ),
  );
}

void _open(BuildContext context, Widget page) =>
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => page));
Map<String, dynamic> _map(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : const {};
List<Map<String, dynamic>> _rows(AppController app, String key) =>
    (app.adminWorkspace[key] as List? ?? const [])
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList();
String _shortId(dynamic value) {
  final text = '$value';
  return text.length > 8
      ? text.substring(0, 8).toUpperCase()
      : text.toUpperCase();
}

String _pretty(String value) {
  final clean = value.replaceAll('_', ' ').trim();
  return clean.isEmpty
      ? 'Unknown'
      : '${clean[0].toUpperCase()}${clean.substring(1)}';
}

String _date(dynamic value) {
  if (value == null) return 'Not yet';
  final date = DateTime.tryParse('$value')?.toLocal();
  if (date == null) return '$value';
  return '${date.day}/${date.month}/${date.year}';
}

String _value(dynamic value) {
  if (value is Map) {
    return value.entries
        .map((e) => '${_pretty('${e.key}')}: ${e.value}')
        .join('\n');
  }
  if (value is List) return value.isEmpty ? 'None' : value.join(', ');
  return '$value';
}
