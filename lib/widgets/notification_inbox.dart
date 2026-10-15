import 'package:flutter/material.dart';

import 'notification_page.dart';

/// A selectable inbox; all mutations must succeed at the data boundary first.
class FurUNotificationInbox extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final Future<void> Function() onRefresh;
  final void Function(Map<String, dynamic>) onOpen;
  final Future<void> Function(List<String>, bool) onAction;
  final bool refreshError;
  const FurUNotificationInbox({
    super.key,
    required this.items,
    required this.onRefresh,
    required this.onOpen,
    required this.onAction,
    this.refreshError = false,
  });
  @override
  State<FurUNotificationInbox> createState() => _FurUNotificationInboxState();
}

class _FurUNotificationInboxState extends State<FurUNotificationInbox> {
  bool _selecting = false;
  bool _busy = false;
  String _filter = 'All';
  final Set<String> _selected = {};
  String _id(Map<String, dynamic> item) => '${item['id']}';
  String _category(Map<String, dynamic> item) {
    final type = '${item['type'] ?? ''}'.toUpperCase();
    if (type.contains('MESSAGE')) return 'Messages';
    if (type.contains('APPLICATION') ||
        type.contains('ADOPTION') ||
        type.contains('CLARIFICATION')) {
      return 'Applications';
    }
    return 'System';
  }

  List<Map<String, dynamic>> get _visible => widget.items
      .where((item) => _filter == 'All' || _category(item) == _filter)
      .toList();

  @override
  void didUpdateWidget(covariant FurUNotificationInbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    _selected.retainAll(widget.items.map(_id));
  }

  void _cancel() => setState(() {
    _selecting = false;
    _selected.clear();
  });
  void _toggle(String id) => setState(() {
    if (!_selected.add(id)) _selected.remove(id);
  });

  Future<void> _act(bool delete) async {
    final ids = _selected.toList();
    if (ids.isEmpty || _busy) return;
    if (delete) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Delete ${ids.length} ${ids.length == 1 ? 'notification' : 'notifications'}?',
          ),
          content: const Text(
            'This removes the selected updates from your inbox. Applications and messages are kept.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }
    setState(() => _busy = true);
    try {
      await widget.onAction(ids, delete);
      if (mounted) _cancel();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              delete
                  ? 'Could not delete notifications. Please try again.'
                  : 'Could not mark notifications as read. Please try again.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final visible = _visible;
    return PopScope(
      canPop: !_selecting && !_busy,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !_busy) _cancel();
      },
      child: RefreshIndicator(
        onRefresh: _busy ? () async {} : widget.onRefresh,
        child: FurUNotificationPage(
          onBack: () {
            if (_busy) return;
            if (_selecting) {
              _cancel();
            } else {
              Navigator.maybePop(context);
            }
          },
          headerAction: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              minimumSize: const Size(0, 44),
            ),
            onPressed: _busy || (_selecting && visible.isEmpty)
                ? null
                : () => setState(() {
                    if (!_selecting) {
                      _selecting = true;
                    } else {
                      _selected.addAll(visible.map(_id));
                    }
                  }),
            icon: Icon(
              _selecting ? Icons.done_all_rounded : Icons.check_rounded,
              size: 19,
            ),
            label: Text(_selecting ? 'Select all' : 'Select'),
          ),
          bottomBar: _selecting
              ? Material(
                  color: colors.surface,
                  elevation: 0,
                  shadowColor: Colors.black12,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${_selected.length} selected',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                              ),
                              TextButton(
                                onPressed: _busy ? null : _cancel,
                                child: const Text('Cancel'),
                              ),
                            ],
                          ),
                          if (_busy)
                            const LinearProgressIndicator(
                              semanticsLabel: 'Updating notifications',
                            ),
                          Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            alignment: WrapAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                onPressed: _busy || _selected.isEmpty
                                    ? null
                                    : () => _act(true),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: colors.error,
                                ),
                                icon: const Icon(Icons.delete_outline_rounded),
                                label: const Text('Delete'),
                              ),
                              FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: colors.primary,
                                  foregroundColor: colors.onPrimary,
                                ),
                                onPressed: _busy || _selected.isEmpty
                                    ? null
                                    : () => _act(false),
                                icon: const Icon(Icons.check_rounded),
                                label: const Text('Mark as read'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : null,
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                child: Row(
                  children: [
                    for (final entry in const {
                      'All': Icons.notifications_none_rounded,
                      'Applications': Icons.description_outlined,
                      'Messages': Icons.chat_bubble_outline_rounded,
                      'System': Icons.settings_outlined,
                    }.entries)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(entry.key),
                          avatar: Icon(
                            entry.value,
                            size: 19,
                            color: _filter == entry.key
                                ? colors.onPrimary
                                : colors.onSurface,
                          ),
                          showCheckmark: false,
                          selected: _filter == entry.key,
                          selectedColor: colors.primary,
                          backgroundColor:
                              Theme.of(context).brightness == Brightness.dark
                              ? colors.surface
                              : Colors.white,
                          labelStyle: TextStyle(
                            fontFamily: 'NunitoSans',
                            color: _filter == entry.key
                                ? colors.onPrimary
                                : colors.onSurface,
                          ),
                          side: BorderSide.none,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 9,
                          ),
                          onSelected: _busy
                              ? null
                              : (_) => setState(() {
                                  _filter = entry.key;
                                  _selected.clear();
                                }),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  children: [
                    if (widget.refreshError)
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'Could not refresh. Pull down to try again.',
                          style: TextStyle(color: colors.error),
                        ),
                      ),
                    if (visible.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 60,
                          horizontal: 20,
                        ),
                        child: Text(
                          'No notifications in this category yet.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    for (final item in visible)
                      _NotificationCard(
                        key: ValueKey(_id(item)),
                        item: item,
                        selecting: _selecting,
                        selected: _selected.contains(_id(item)),
                        onTap: _busy
                            ? null
                            : () {
                                if (_selecting) {
                                  _toggle(_id(item));
                                } else {
                                  widget.onOpen(item);
                                }
                              },
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

class _NotificationCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool selecting, selected;
  final VoidCallback? onTap;
  const _NotificationCard({
    super.key,
    required this.item,
    required this.selecting,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final type = '${item['type'] ?? ''}'.toUpperCase();
    final (accent, icon) = switch (type) {
      final t when t.contains('CANCEL') || t.contains('REJECT') => (
        const Color(0xFFCE503A),
        Icons.cancel_outlined,
      ),
      final t when t.contains('MESSAGE') => (
        const Color(0xFF1687D3),
        Icons.chat_bubble_outline_rounded,
      ),
      final t when t.contains('NEW_APPLICATION') => (
        const Color(0xFF00A75B),
        Icons.post_add_rounded,
      ),
      final t when t.contains('APPLICATION') || t.contains('ADOPTION') => (
        const Color(0xFF9857DA),
        Icons.description_outlined,
      ),
      final t when t.contains('PET') => (
        const Color(0xFF00A75B),
        Icons.pets_rounded,
      ),
      _ => (const Color(0xFFAA7653), Icons.shield_outlined),
    };
    final message = '${item['message'] ?? item['body'] ?? 'New update'}';
    final match = RegExp(r' was | sent | the | by ').firstMatch(message);
    final split = match?.start ?? message.length;
    final date = DateTime.tryParse('${item['createdAt']}')?.toLocal();
    final localizations = MaterialLocalizations.of(context);
    final dateLabel = date == null
        ? null
        : '${localizations.formatMediumDate(date)}  \u00b7  ${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(date))}';
    final unread = item['isRead'] != true && item['isRead'] != 1;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Color.alphaBlend(
          accent.withValues(alpha: dark ? .12 : .045),
          colors.surface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: selected
                ? colors.error.withValues(alpha: .45)
                : accent.withValues(alpha: .12),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: Row(
              children: [
                if (selecting)
                  SizedBox(
                    width: 40,
                    child: Checkbox(
                      value: selected,
                      onChanged: onTap == null ? null : (_) => onTap!(),
                      semanticLabel: 'Select $message',
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                Container(
                  width: selecting ? 42 : 48,
                  height: selecting ? 42 : 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(alpha: dark ? .22 : .1),
                  ),
                  child: Icon(
                    icon,
                    size: 27,
                    color: dark ? Color.lerp(accent, Colors.white, .3) : accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: message.substring(0, split),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            TextSpan(text: message.substring(split)),
                          ],
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: colors.onSurface,
                        ),
                      ),
                      if (dateLabel != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          dateLabel,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurfaceVariant,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (unread)
                  Semantics(
                    label: 'Unread',
                    child: Icon(Icons.circle, size: 8, color: accent),
                  ),
                if (!selecting) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 21,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
