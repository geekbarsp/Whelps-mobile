part of 'admin_shell.dart';

class _NotificationsScreen extends StatefulWidget {
  const _NotificationsScreen();

  @override
  State<_NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<_NotificationsScreen> {
  bool _started = false;
  bool _loading = true;
  bool _failed = false;
  List<Map<String, dynamic>> _items = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      _load();
    }
  }

  Future<void> _load() async {
    final app = AppScope.of(context);
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final repository = app.repository;
      final items = repository is NotificationRepository
          ? await (repository as NotificationRepository).fetchNotifications()
          : _rows(app, 'notifications');
      if (mounted) {
        setState(() {
          _items = items;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _failed = true;
          _loading = false;
        });
      }
    }
  }

  void _open(Map<String, dynamic> item) {
    final applications = _rows(AppScope.of(context), 'applications');
    final matching = applications.where(
      (row) =>
          item['applicationId'] != null &&
          row['id'].toString() == item['applicationId'].toString(),
    );
    if (matching.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => _ApprovalDetail(kind: 1, row: matching.first),
        ),
      );
      return;
    }
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification'),
        content: SingleChildScrollView(
          child: Text('${item['message'] ?? item['body'] ?? ''}'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return RefreshIndicator(
      onRefresh: _load,
      child: FurUNotificationPage(
        emptyMessage: 'Application and monitoring updates will appear here.',
        child: _loading && _items.isEmpty
            ? const Center(
                child: CircularProgressIndicator(
                  semanticsLabel: 'Loading notifications',
                ),
              )
            : _failed && _items.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cloud_off_rounded,
                        size: 44,
                        color: colors.primary,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Couldn’t load your updates',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Please try again in a moment.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: _load,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try again'),
                      ),
                    ],
                  ),
                ),
              )
            : _items.isEmpty
            ? null
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                children: [
                  if (_failed)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        'Couldn’t refresh. Pull down to try again.',
                        style: TextStyle(color: colors.error),
                      ),
                    ),
                  for (final item in _items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: colors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(24),
                        clipBehavior: Clip.antiAlias,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: colors.primaryContainer,
                            foregroundColor: colors.onPrimaryContainer,
                            child: const Icon(Icons.notifications_none_rounded),
                          ),
                          title: Text(
                            '${item['message'] ?? item['body'] ?? 'New update'}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: _date(item['createdAt']) == null
                              ? null
                              : Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(_date(item['createdAt'])!),
                                ),
                          trailing:
                              item['isRead'] == true || item['isRead'] == 1
                              ? null
                              : Semantics(
                                  label: 'Unread',
                                  child: Icon(
                                    Icons.circle,
                                    size: 9,
                                    color: colors.primary,
                                  ),
                                ),
                          onTap: () => _open(item),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  String? _date(Object? value) {
    final date = DateTime.tryParse('$value')?.toLocal();
    return date == null
        ? null
        : MaterialLocalizations.of(context).formatMediumDate(date);
  }
}
