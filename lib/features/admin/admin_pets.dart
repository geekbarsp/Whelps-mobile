part of 'admin_shell.dart';

String _petStatus(Map<String, dynamic> row) {
  final health =
      '${row['healthVerification'] ?? row['health_verification'] ?? ''}';
  if (row['availability'] == 'Adopted') return 'adopted';
  if (health == 'Requires Update') return 'corrections_requested';
  if (health == 'On Treatment' || row['availability'] == 'On Treatment') {
    return 'on_treatment';
  }
  if (health == 'Verified') {
    return row['published'] == true || row['published'] == 1
        ? 'active'
        : 'unpublished';
  }
  return '${row['listing_status'] ?? 'pending'}';
}

const _petStatusLabels = {
  'all': 'All',
  'pending': 'Pending',
  'active': 'Active',
  'on_treatment': 'On Treatment',
  'corrections_requested': 'Corrections',
  'unpublished': 'Unpublished',
  'adopted': 'Adopted',
};

Color _petStatusColor(String status) => switch (status) {
  'active' || 'adopted' => const Color(0xFF249C49),
  'on_treatment' || 'rejected' => const Color(0xFFD94B52),
  'corrections_requested' => const Color(0xFF9571D4),
  'pending' => const Color(0xFFD17B00),
  _ => const Color(0xFF82756E),
};

class _PetHealthTab extends StatefulWidget {
  const _PetHealthTab();
  @override
  State<_PetHealthTab> createState() => _PetHealthTabState();
}

class _PetHealthTabState extends State<_PetHealthTab> {
  String search = '', filter = 'all', species = 'All', sex = 'All';

  Future<void> _filters() async {
    var selectedSpecies = species;
    var selectedSex = sex;
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Filter pets',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedSpecies,
                  decoration: const InputDecoration(labelText: 'Species'),
                  items: ['All', 'Dog', 'Cat', 'Other']
                      .map(
                        (value) =>
                            DropdownMenuItem(value: value, child: Text(value)),
                      )
                      .toList(),
                  onChanged: (value) => update(() => selectedSpecies = value!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedSex,
                  decoration: const InputDecoration(labelText: 'Sex'),
                  items: ['All', 'Male', 'Female']
                      .map(
                        (value) =>
                            DropdownMenuItem(value: value, child: Text(value)),
                      )
                      .toList(),
                  onChanged: (value) => update(() => selectedSex = value!),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Apply filters'),
                ),
                TextButton(
                  onPressed: () {
                    selectedSpecies = 'All';
                    selectedSex = 'All';
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
        species = selectedSpecies;
        sex = selectedSex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final all = _rows(app, 'pets');
    final rows = all.where((row) {
      final status = _petStatus(row);
      final kind = '${row['species'] ?? row['type'] ?? ''}'.toLowerCase();
      final gender = '${row['gender'] ?? row['sex'] ?? ''}'.toLowerCase();
      final haystack =
          '${row['name']} ${row['breed']} ${_petStatusLabels[status] ?? status}'
              .toLowerCase();
      return haystack.contains(search.trim().toLowerCase()) &&
          (filter == 'all' || status == filter) &&
          (species == 'All' ||
              (species == 'Other'
                  ? kind != 'dog' && kind != 'cat'
                  : kind == species.toLowerCase())) &&
          (sex == 'All' || gender == sex.toLowerCase());
    }).toList();
    final dark = Theme.of(context).brightness == Brightness.dark;
    final foreground = Theme.of(context).colorScheme.onSurface;
    return _RefreshPage(
      child: ListView(
        key: const PageStorageKey('admin-pets'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          const _DashboardHeader(),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked =
                  constraints.maxWidth < 340 ||
                  MediaQuery.textScalerOf(context).scale(14) > 18;
              final title = Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: dark
                          ? const Color(0xFF684028)
                          : const Color(0xFFFFE4CE),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      Icons.pets_rounded,
                      color: foreground,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pets & Health',
                          style: TextStyle(
                            color: foreground,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                            letterSpacing: -.4,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Manage pets, health records, and status.',
                          style: TextStyle(
                            fontSize: 10.5,
                            height: 1.3,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
              final add = FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: dark
                      ? const Color(0xFFE8A66D)
                      : const Color(0xFFA4511B),
                  foregroundColor: dark
                      ? const Color(0xFF301B0E)
                      : Colors.white,
                  minimumSize: const Size(48, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  textStyle: const TextStyle(
                    fontFamily: 'NunitoSans',
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                onPressed: () => _open(context, const _AddPetScreen()),
                icon: const Icon(Icons.add_rounded, size: 19),
                label: const Text('Add Pet'),
              );
              return stacked
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        title,
                        const SizedBox(height: 12),
                        Align(alignment: Alignment.centerRight, child: add),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: title),
                        const SizedBox(width: 8),
                        add,
                      ],
                    );
            },
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
                    hintText: 'Search pet name, breed, or status...',
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
                isLabelVisible: species != 'All' || sex != 'All',
                child: IconButton.filledTonal(
                  tooltip: 'Filter pets',
                  onPressed: _filters,
                  style: IconButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    backgroundColor: FurUColors.card(context),
                    foregroundColor: foreground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
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
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final entry in _petStatusLabels.entries)
                  Padding(
                    padding: const EdgeInsets.only(right: 7),
                    child: _PetFilterChip(
                      label: entry.value,
                      status: entry.key,
                      selected: filter == entry.key,
                      count: entry.key == 'all'
                          ? all.length
                          : all
                                .where((row) => _petStatus(row) == entry.key)
                                .length,
                      onTap: () => setState(() => filter = entry.key),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (app.adminError != null) ...[
            _AdminSyncNotice(message: app.adminError!),
            const SizedBox(height: 12),
          ],
          if (app.adminLoading && all.isEmpty)
            const _LoadingCards()
          else if (rows.isEmpty)
            EmptyState(
              icon: Icons.pets_outlined,
              title: app.adminError != null
                  ? 'Pet records unavailable'
                  : 'No pet records in this view',
              message: app.adminError != null
                  ? 'Pull down to try again.'
                  : 'Try another search or filter, or add a pet.',
            )
          else
            for (final row in rows) ...[
              _PetHealthCard(row: row),
              const SizedBox(height: 9),
            ],
        ],
      ),
    );
  }
}

class _PetFilterChip extends StatelessWidget {
  final String label, status;
  final int count;
  final bool selected;
  final VoidCallback onTap;
  const _PetFilterChip({
    required this.label,
    required this.status,
    required this.count,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final foreground = selected
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? const Color(0xFFA4511B) : FurUColors.card(context),
        borderRadius: BorderRadius.circular(17),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(17),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  selected ? Icons.check_rounded : Icons.circle,
                  size: selected ? 17 : 9,
                  color: selected ? Colors.white : _petStatusColor(status),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 7),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.white.withValues(alpha: .17)
                        : (dark ? Colors.white10 : const Color(0xFFF5F2EE)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(color: foreground, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PetHealthCard extends StatelessWidget {
  final Map<String, dynamic> row;
  const _PetHealthCard({required this.row});
  @override
  Widget build(BuildContext context) {
    final status = _petStatus(row);
    final gender = '${row['gender'] ?? row['sex'] ?? ''}'.toLowerCase();
    final female = gender == 'female';
    final fixed = '${row['fixedStatus'] ?? row['fixed_status'] ?? ''}';
    final vaccination =
        '${row['vaccinationStatus'] ?? row['vaccination_status'] ?? ''}';
    final updated = DateTime.tryParse(
      '${row['updatedAt'] ?? row['updated_at'] ?? ''}',
    );
    final days = updated == null
        ? null
        : DateTime.now().difference(updated).inDays;
    final when = days == null
        ? 'Update date unavailable'
        : days <= 0
        ? 'Updated today'
        : 'Updated $days ${days == 1 ? 'day' : 'days'} ago';
    final raw = '${row['image'] ?? row['image_url'] ?? ''}';
    final image = raw.startsWith('/')
        ? '${BackendConfig.whelpsApiUrl}$raw'
        : raw;
    final foreground = Theme.of(context).colorScheme.onSurface;
    final tags = Wrap(
      spacing: 5,
      runSpacing: 5,
      children: [
        if (fixed.isNotEmpty)
          _PetPill(
            label: fixed,
            color: female ? const Color(0xFFCB435C) : const Color(0xFF3674B3),
            icon: Icons.verified_user_outlined,
          ),
        if (vaccination.isNotEmpty)
          _PetPill(
            label: vaccination,
            color: const Color(0xFF23854B),
            icon: Icons.vaccines_outlined,
          ),
        if (fixed.isEmpty && vaccination.isEmpty)
          const Text('Health details pending', style: TextStyle(fontSize: 10)),
      ],
    );
    final badge = _PetPill(
      label: _petStatusLabels[status] ?? _pretty(status),
      color: _petStatusColor(status),
      icon: Icons.circle,
      bold: true,
    );
    return Material(
      color: FurUColors.card(context),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _open(context, _ApprovalDetail(kind: 0, row: row)),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stacked =
                  constraints.maxWidth < 315 ||
                  MediaQuery.textScalerOf(context).scale(14) > 18;
              final identity = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          '${row['name'] ?? 'Pet'}',
                          style: TextStyle(
                            color: foreground,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                          ),
                        ),
                      ),
                      if (gender == 'male' || female) ...[
                        const SizedBox(width: 7),
                        _PetPill(
                          label: '',
                          color: female
                              ? const Color(0xFFD54F83)
                              : const Color(0xFF3383C6),
                          icon: female
                              ? Icons.female_rounded
                              : Icons.male_rounded,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${row['breed'] ?? row['species'] ?? 'Animal'}',
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.3,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              );
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: SizedBox(
                      width: stacked ? 65 : 67,
                      height: stacked ? 82 : 72,
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
                        if (stacked) ...[
                          identity,
                          const SizedBox(height: 6),
                          badge,
                          const SizedBox(height: 4),
                          Text(when, style: const TextStyle(fontSize: 9)),
                        ] else
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: identity),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    badge,
                                    const SizedBox(height: 4),
                                    Text(
                                      when,
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        fontSize: 9,
                                        height: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 7),
                        tags,
                      ],
                    ),
                  ),
                  const SizedBox(width: 3),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: foreground,
                    size: 19,
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

class _PetPill extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final bool bold;
  const _PetPill({
    required this.label,
    required this.color,
    required this.icon,
    this.bold = false,
  });
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? Color.lerp(color, Colors.white, .45)! : color;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: label.isEmpty ? 5 : 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: dark ? .23 : .10),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Icon(
                icon,
                size: icon == Icons.circle ? 8 : 13,
                color: ink,
              ),
            ),
            if (label.isNotEmpty) TextSpan(text: '  $label'),
          ],
        ),
        style: TextStyle(
          color: ink,
          fontSize: bold ? 10.5 : 9,
          height: 1.25,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
        ),
      ),
    );
  }
}

class _AddPetScreen extends StatefulWidget {
  const _AddPetScreen();
  @override
  State<_AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<_AddPetScreen> {
  final form = GlobalKey<FormState>();
  final fields = {
    for (final key in ['name', 'breed', 'age', 'description', 'healthNotes'])
      key: TextEditingController(),
  };
  String type = 'Dog',
      gender = 'Male',
      fixed = 'Unknown',
      vaccination = 'Unknown',
      healthVerification = 'Pending Verification',
      existingPhoto = '/images/pets/buddy.webp';
  Uint8List? photoBytes;
  String? photoName;
  int step = 0;
  bool saving = false;
  @override
  void dispose() {
    for (final controller in fields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _continue() async {
    if (!form.currentState!.validate()) return;
    if (step == 0) {
      setState(() => step = 1);
      return;
    }
    setState(() => saving = true);
    try {
      await AppScope.of(context).runAdminAction('create_pet', {
        for (final entry in fields.entries) entry.key: entry.value.text.trim(),
        'type': type,
        'gender': gender,
        'image': photoBytes == null
            ? existingPhoto
            : 'data:image/${_photoExtension(photoName!)};base64,${base64Encode(photoBytes!)}',
        'fixedStatus': fixed,
        'vaccinationStatus': vaccination,
        'healthVerification': healthVerification,
        'published': false,
      });
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pet added. Review health information before publishing.',
          ),
        ),
      );
    } catch (error) {
      if (mounted) showError(context, error);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  String _photoExtension(String name) {
    final extension = name.split('.').last.toLowerCase();
    return extension == 'jpg' ? 'jpeg' : extension;
  }

  Future<void> _pickPhoto() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
      );
      if (file == null || !mounted) return;
      final length = await file.length();
      if (length == null || length == 0 || length > 2 * 1024 * 1024) {
        throw StateError('Choose a JPG, PNG, or WebP image up to 2 MB.');
      }
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        photoBytes = bytes;
        photoName = file.name;
      });
    } catch (error) {
      if (mounted) showError(context, error);
    }
  }

  Widget _photoPicker() {
    final preview = photoBytes != null
        ? Image.memory(photoBytes!, fit: BoxFit.cover)
        : Image.network(
            '${BackendConfig.whelpsApiUrl}$existingPhoto',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const ColoredBox(
              color: FurUColors.sage,
              child: Icon(Icons.pets_rounded, color: FurUColors.forest),
            ),
          );
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: FurUColors.card(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pet photo', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(width: 86, height: 96, child: preview),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OutlinedButton.icon(
                      onPressed: saving ? null : _pickPhoto,
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                      label: Text(photoName ?? 'Upload a photo'),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'JPG, PNG, or WebP · maximum 2 MB',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (photoBytes != null)
                      TextButton(
                        onPressed: saving
                            ? null
                            : () => setState(() {
                                photoBytes = null;
                                photoName = null;
                              }),
                        child: const Text('Use an existing image instead'),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (photoBytes == null) ...[
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: existingPhoto,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Or use an existing image',
              ),
              items: const [
                DropdownMenuItem(
                  value: '/images/pets/buddy.webp',
                  child: Text('Golden dog'),
                ),
                DropdownMenuItem(
                  value: '/images/pets/bella.webp',
                  child: Text('Gray cat'),
                ),
              ],
              onChanged: saving
                  ? null
                  : (value) => setState(() => existingPhoto = value!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _field(
    String key,
    String label, {
    int lines = 1,
    bool required = true,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      key: ValueKey(key),
      controller: fields[key],
      maxLines: lines,
      enabled: !saving,
      keyboardType: lines > 1 ? TextInputType.multiline : TextInputType.text,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if (required && (value == null || value.trim().isEmpty)) {
          return 'Enter $label.';
        }
        return null;
      },
    ),
  );
  Widget _choice(
    String label,
    String value,
    List<String> options,
    ValueChanged<String> change,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: DropdownButtonFormField<String>(
      key: ValueKey(label),
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: options
          .map((option) => DropdownMenuItem(value: option, child: Text(option)))
          .toList(),
      onChanged: saving ? null : (value) => setState(() => change(value!)),
    ),
  );
  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !saving,
    child: Scaffold(
      appBar: AppBar(title: const Text('Add Pet Listing')),
      body: Form(
        key: form,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(value: (step + 1) / 2),
              const SizedBox(height: 16),
              Text(
                step == 0 ? 'Pet information' : 'Health & review',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 5),
              Text(
                step == 0
                    ? 'Create the pet profile and add a clear photo.'
                    : 'Record health details before the listing is published.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              if (step == 0) ...[
                _field('name', 'Pet name'),
                _choice('Animal type', type, [
                  'Dog',
                  'Cat',
                  'Other',
                ], (v) => type = v),
                _field('breed', 'Breed'),
                _field('age', 'Age'),
                _choice('Gender', gender, [
                  'Male',
                  'Female',
                  'Unknown',
                ], (v) => gender = v),
                _photoPicker(),
                _field('description', 'Pet description', lines: 4),
              ] else ...[
                FurUSectionCard(
                  child: Text(
                    '${fields['name']!.text} · $type · ${fields['breed']!.text}\n${fields['age']!.text} · $gender\n${fields['description']!.text}',
                  ),
                ),
                const SizedBox(height: 16),
                _choice('Spay / neuter status', fixed, [
                  'Unknown',
                  'Neutered',
                  'Spayed',
                  'Not neutered',
                  'Not spayed',
                ], (v) => fixed = v),
                _choice('Vaccination status', vaccination, [
                  'Unknown',
                  'Vaccinated',
                  'Partially vaccinated',
                  'Not vaccinated',
                ], (v) => vaccination = v),
                _choice('Health verification', healthVerification, const [
                  'Pending Verification',
                ], (v) => healthVerification = v),
                _field(
                  'healthNotes',
                  'Health notes',
                  lines: 3,
                  required: false,
                ),
                const Text(
                  'The pet will be saved as pending verification. Review its health information before publishing.',
                ),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: saving ? null : _continue,
                child: saving
                    ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(step == 0 ? 'Continue' : 'Save pet for review'),
              ),
              if (step == 1)
                TextButton(
                  onPressed: saving ? null : () => setState(() => step = 0),
                  child: const Text('Back to pet details'),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
