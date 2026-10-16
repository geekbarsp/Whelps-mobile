import 'package:flutter/material.dart';

import '../../core/app_controller.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../widgets/components.dart';
import '../applications/activity_screen.dart';
import '../applications/workflow_screen.dart';
import '../pets/discover_screen.dart';
import '../rescue/rescue_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _page(BuildContext context, String title, Widget child) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(title)),
          body: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final user = app.profile!;
    return PageBody(
      child: ListView(
        key: const PageStorageKey('profile-scroll'),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
        children: [
          _ProfileIdentityCard(user: user),
          const SizedBox(height: 12),
          _ProfileActionTile(
            crop: Rect.fromLTWH(164, 729, 615, 109),
            icon: Icons.pets_rounded,
            title: 'Contact for Rescue',
            subtitle: 'Find animal-welfare contacts',
            onTap: () => openRescue(context),
          ),
          _ProfileActionTile(
            crop: Rect.fromLTWH(164, 851, 615, 109),
            icon: Icons.person_outline_rounded,
            title: 'Personal information',
            subtitle: 'Keep your contact details up to date',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const EditProfileScreen(),
              ),
            ),
          ),
          _ProfileActionTile(
            crop: Rect.fromLTWH(164, 974, 615, 110),
            icon: Icons.lock_outline_rounded,
            title: 'Password & security',
            subtitle: 'Change your password',
            onTap: () {
              if (!app.hasPassword) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Password changes require a signed-in account.',
                    ),
                  ),
                );
                return;
              }
              _page(
                context,
                'Password & security',
                const ChangePasswordScreen(),
              );
            },
          ),
          _ProfileActionTile(
            crop: Rect.fromLTWH(164, 1097, 615, 108),
            icon: Icons.favorite_border_rounded,
            title: 'Saved pets',
            subtitle: '${app.favorites.length} little favorites',
            onTap: () => _page(
              context,
              'Saved pets',
              const DiscoverScreen(favoritesOnly: true),
            ),
          ),
          _ProfileActionTile(
            crop: Rect.fromLTWH(164, 1219, 615, 108),
            icon: Icons.description_outlined,
            title: 'Applications & submissions',
            subtitle: 'Track your adoption journey',
            onTap: () =>
                _page(context, 'Your activity', const ActivityScreen()),
          ),
          _ProfileActionTile(
            crop: Rect.fromLTWH(164, 1341, 615, 107),
            icon: Icons.support_agent_rounded,
            title: 'Help & support',
            subtitle: "We're here when you need us",
            onTap: () =>
                _page(context, 'Help & support', const HelpSupportScreen()),
          ),
          _ProfileNativeActionTile(
            icon: Icons.settings_outlined,
            title: 'Settings',
            subtitle: 'Theme, notifications, privacy, and more',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
          ),
          _ProfileActionTile(
            crop: Rect.fromLTWH(164, 1461, 615, 90),
            icon: Icons.logout_rounded,
            title: 'Sign out',
            subtitle: 'See you again soon!',
            destructive: true,
            onTap: () async {
              try {
                await app.signOut();
              } catch (error) {
                if (context.mounted) showError(context, error);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ProfileIdentityCard extends StatelessWidget {
  final UserProfile user;
  const _ProfileIdentityCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 177,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Stack(
        children: [
          if (!dark)
            const Positioned.fill(
              child: _ProfileReferenceSlice(
                crop: Rect.fromLTWH(164, 400, 615, 311),
              ),
            )
          else ...[
            Positioned(
              right: -18,
              bottom: -28,
              child: Icon(
                Icons.pets_rounded,
                size: 125,
                color: scheme.primary.withValues(alpha: .07),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 44,
              child: ColoredBox(
                color: scheme.primaryContainer.withValues(alpha: .45),
              ),
            ),
          ],
          if (!dark)
            const Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 113,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 14, 53),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 41,
                  backgroundColor: const Color(0xFFFFD8A5),
                  child: Text(
                    user.name.trim().isEmpty
                        ? 'F'
                        : user.name.trim()[0].toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Fraunces',
                      fontSize: 31,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2F1B11),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Fraunces',
                          fontSize: 18,
                          height: 1.05,
                          fontWeight: FontWeight.w800,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const _ProfileBadge(
                              icon: Icons.groups_rounded,
                              label: 'FurU community',
                            ),
                            const SizedBox(width: 7),
                            _ProfileBadge(
                              icon: Icons.verified_user_outlined,
                              label: user.verified
                                  ? 'Verified'
                                  : user.verificationRequested
                                  ? 'Review requested'
                                  : 'Not verified',
                              muted: true,
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
        ],
      ),
    );
  }
}

class _ProfileBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool muted;
  const _ProfileBadge({
    required this.icon,
    required this.label,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: dark
            ? (muted ? const Color(0xFF3A2924) : const Color(0xFF4B2C1B))
            : (muted ? const Color(0xFFF6E9E4) : const Color(0xFFFFEDDA)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFFB1501D)),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF9A421B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileActionTile extends StatelessWidget {
  final Rect crop;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool destructive;
  const _ProfileActionTile({
    required this.crop,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return _ProfileNativeActionTile(
        icon: icon,
        title: title,
        subtitle: subtitle,
        onTap: onTap,
        destructive: destructive,
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Semantics(
        button: true,
        label: '$title. $subtitle',
        child: AspectRatio(
          aspectRatio: crop.width / crop.height,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: IgnorePointer(child: _ProfileReferenceSlice(crop: crop)),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileReferenceSlice extends StatelessWidget {
  final Rect crop;
  const _ProfileReferenceSlice({required this.crop});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = constraints.maxWidth / crop.width;
      return ClipRect(
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              left: -crop.left * scale,
              top: -crop.top * scale,
              width: 941 * scale,
              height: 1672 * scale,
              child: Image.asset(
                'assets/brand/profile-reference.png',
                fit: BoxFit.fill,
                filterQuality: FilterQuality.high,
                excludeFromSemantics: true,
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _ProfileNativeActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool destructive;
  const _ProfileNativeActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF4A3022)
                      : const Color(0xFFF9EFE1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: destructive
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: destructive
                            ? Theme.of(context).colorScheme.error
                            : null,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    ),
  );
}

class LegacyProfileScreen extends StatelessWidget {
  const LegacyProfileScreen({super.key});
  void page(BuildContext context, String title, Widget child) => Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: child,
      ),
    ),
  );
  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final user = app.profile!;
    return PageBody(
      child: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          FurUSectionCard(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: FurUColors.peach,
                  child: Text(
                    user.name.isEmpty ? 'F' : user.name[0].toUpperCase(),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(height: 14),
                Text(user.name, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(user.email),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    const FurUStatusBadge('FurU community'),
                    FurUStatusBadge(
                      user.verified
                          ? 'Verified'
                          : user.verificationRequested
                          ? 'Review requested'
                          : 'Not verified',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _tile(
            Icons.support_agent_rounded,
            'Contact for Rescue',
            'Find animal-welfare contacts',
            () => openRescue(context),
          ),
          _tile(
            Icons.person_outline,
            'Personal information',
            'Keep your contact details up to date',
            () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const EditProfileScreen(),
              ),
            ),
          ),
          if (app.hasPassword)
            _tile(
              Icons.lock_outline_rounded,
              'Password & security',
              'Change your password',
              () => page(
                context,
                'Password & security',
                const ChangePasswordScreen(),
              ),
            ),
          _tile(
            Icons.favorite_outline,
            'Saved pets',
            '${app.favorites.length} little favorites',
            () => page(
              context,
              'Saved pets',
              const DiscoverScreen(favoritesOnly: true),
            ),
          ),
          _tile(
            Icons.assignment_outlined,
            'Applications & submissions',
            'Follow every step of your journey',
            () => page(context, 'Your activity', const ActivityScreen()),
          ),
          _tile(
            Icons.home_outlined,
            'Rehome a pet',
            'Help them find a fresh start',
            () => openWorkflow(context, app.newDraft(SubmissionKind.rehome)),
          ),
          _tile(
            Icons.folder_outlined,
            'My documents',
            'Files attached to your submissions',
            () => page(context, 'My documents', const DocumentsScreen()),
          ),
          _tile(
            Icons.verified_user_outlined,
            'Account verification',
            'Reviewed by a person',
            () => page(context, 'Verification', const VerificationScreen()),
          ),
          _tile(
            Icons.settings_outlined,
            'Settings & about',
            'Privacy, local storage, and help',
            () => page(context, 'Settings & about', const SettingsScreen()),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () async {
              try {
                await app.signOut();
              } catch (e) {
                if (context.mounted) showError(context, e);
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Made for a little more love.  ♡',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
        leading: CircleAvatar(
          backgroundColor: FurUColors.sage,
          child: Icon(icon, color: FurUColors.forest, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    ),
  );
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final form = GlobalKey<FormState>();
  final values = <String, String>{};
  bool busy = false;
  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final user = app.profile!;
    return Scaffold(
      appBar: AppBar(title: const Text('Personal information')),
      body: PageBody(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: form,
            child: Column(
              children: [
                for (final entry in {
                  'Name': user.name,
                  'Phone': user.phone,
                  'Location': user.location,
                }.entries)
                  FurUTextField(
                    label: entry.key,
                    initialValue: entry.value,
                    required: entry.key != 'Phone',
                    keyboardType: entry.key == 'Phone'
                        ? TextInputType.phone
                        : null,
                    onChanged: (v) => values[entry.key] = v,
                  ),
                const Text(
                  'Your contact details help with adoption and rehoming follow-ups.',
                ),
                const SizedBox(height: 24),
                FurUPrimaryButton(
                  label: 'Save changes',
                  busy: busy,
                  onPressed: () async {
                    if (!form.currentState!.validate()) return;
                    setState(() => busy = true);
                    try {
                      await app.updateProfile(
                        UserProfile(
                          name: (values['Name'] ?? user.name).trim(),
                          email: user.email,
                          phone: values['Phone'] ?? user.phone,
                          location: values['Location'] ?? user.location,
                          organization: user.organization,
                          accountType: user.accountType,
                          role: user.role,
                          verificationRequested: user.verificationRequested,
                          verified: user.verified,
                        ),
                      );
                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      if (context.mounted) showError(context, e);
                    }
                    if (mounted) setState(() => busy = false);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final form = GlobalKey<FormState>();
  final current = TextEditingController();
  final next = TextEditingController();
  final confirm = TextEditingController();
  bool busy = false;
  @override
  void dispose() {
    current.dispose();
    next.dispose();
    confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PageBody(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: FurUColors.sage,
              child: Icon(
                Icons.lock_outline_rounded,
                color: FurUColors.forest,
                size: 28,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Keep your account secure',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text('Choose a password you do not use anywhere else.'),
            const SizedBox(height: 26),
            FurUTextField(
              label: 'Current password',
              controller: current,
              obscure: true,
            ),
            FurUTextField(
              label: 'New password',
              controller: next,
              obscure: true,
              validator: (value) => (value?.length ?? 0) < 8
                  ? 'Use at least 8 characters.'
                  : null,
            ),
            FurUTextField(
              label: 'Confirm new password',
              controller: confirm,
              obscure: true,
              validator: (value) =>
                  value != next.text ? 'The passwords do not match.' : null,
            ),
            FurUPrimaryButton(
              label: 'Update password',
              busy: busy,
              onPressed: () async {
                if (!form.currentState!.validate()) return;
                setState(() => busy = true);
                try {
                  await AppScope.of(context)
                      .changePassword(current.text, next.text);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password updated.')),
                  );
                  Navigator.pop(context);
                } catch (e) {
                  if (context.mounted) showError(context, e);
                }
                if (mounted) setState(() => busy = false);
              },
            ),
          ],
        ),
      ),
    ),
  );
}

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final items = AppScope.of(context).submissions
        .expand((s) => s.attachments.map((a) => (s, a)))
        .toList();
    return PageBody(
      child: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          const FurUSectionCard(
            color: FurUColors.sage,
            child: Text(
              'Your attached files stay available during this session. After restarting, reselect files in your saved draft.',
            ),
          ),
          const SizedBox(height: 20),
          if (items.isEmpty)
            const EmptyState(
              icon: Icons.folder_open,
              title: 'No documents yet',
              message: 'Documents you add during an application or rehoming submission will appear here.',
            ),
          for (final item in items)
            ListTile(
              leading: Icon(
                item.$2.isImage
                    ? Icons.image_outlined
                    : Icons.description_outlined,
              ),
              title: Text(item.$2.name),
              subtitle: Text(
                '${item.$1.title} · ${item.$2.bytes == null ? 'Reselect file' : 'In this session'}',
              ),
              onTap: () => openWorkflow(context, item.$1),
            ),
        ],
      ),
    );
  }
}

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final user = app.profile!;
    return PageBody(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Icon(
            Icons.verified_user_outlined,
            size: 64,
            color: FurUColors.forest,
          ),
          const SizedBox(height: 24),
          Text(
            'Trust begins with care.',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          const Text(
            'A human reviewer checks account information. Requesting a review does not verify your identity or guarantee approval.',
          ),
          const SizedBox(height: 24),
          FurUSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FurUStatusBadge(
                  user.verified
                      ? 'Verified'
                      : user.verificationRequested
                      ? 'Review requested'
                      : 'Not verified',
                ),
                const SizedBox(height: 16),
                Text(user.name),
                const SizedBox(height: 8),
                Text(user.email),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Your request enters the FurU administrator review queue. You can return here to check its status.',
          ),
          const SizedBox(height: 24),
          FurUPrimaryButton(
            label: user.verified
                ? 'Account verified'
                : user.verificationRequested
                ? 'Request saved locally'
                : 'Request account review',
            onPressed: user.verificationRequested || user.verified
                ? null
                : () async {
                    try {
                      await app.updateProfile(
                        UserProfile(
                          name: user.name,
                          email: user.email,
                          phone: user.phone,
                          location: user.location,
                          organization: user.organization,
                          accountType: user.accountType,
                          role: user.role,
                          verificationRequested: true,
                          verified: user.verified,
                        ),
                      );
                    } catch (e) {
                      if (context.mounted) showError(context, e);
                    }
                  },
          ),
        ],
      ),
    );
  }
}

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) => PageBody(
    child: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Icon(
          Icons.support_agent_rounded,
          size: 56,
          color: FurUColors.forest,
        ),
        const SizedBox(height: 18),
        Text(
          'How can we help?',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        const Text(
          'Find answers, understand the adoption process, or reach an animal-welfare contact.',
        ),
        const SizedBox(height: 22),
        FurUSectionCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(
              backgroundColor: FurUColors.peach,
              child: Icon(Icons.pets_rounded, color: FurUColors.forest),
            ),
            title: const Text(
              'Contact for Rescue',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: const Text('Find animal-welfare contacts near you'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => openRescue(context),
          ),
        ),
        const SizedBox(height: 14),
        const FurUSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Adoption support',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 8),
              Text(
                'Browse a pet, complete the application, and wait for a human review. Approval is never automatic.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const FurUSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account and privacy',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 8),
              Text(
                'Your profile, favorites, and drafts are stored on this device. Avoid attaching financial or identity documents.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const FurUSectionCard(
          color: FurUColors.peach,
          child: Text(
            'For an animal in immediate danger, contact your local emergency service or animal-welfare authority.',
          ),
        ),
      ],
    ),
  );
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _removeAccount(BuildContext context, AppController app) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove account from this device?'),
        content: const Text(
          'Your profile, favorites, applications, and drafts will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep account'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove account'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      Navigator.pop(context);
      await app.deleteAccount();
    } catch (error) {
      if (context.mounted) showError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return Scaffold(
      body: SafeArea(
        child: PageBody(
          child: ListView(
            key: const PageStorageKey('settings-scroll'),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              const _SettingsReferenceHeader(),
              const SizedBox(height: 14),
              const _SettingsSectionTitle(
                icon: Icons.palette_outlined,
                title: 'Appearance',
              ),
              const SizedBox(height: 10),
              const _ThemePicker(),
              const SizedBox(height: 22),
              const _SettingsSectionTitle(
                icon: Icons.notifications_none_rounded,
                title: 'Notifications',
              ),
              const SizedBox(height: 10),
              _NotificationSettingsCard(app: app),
              const SizedBox(height: 22),
              const _SettingsSectionTitle(
                icon: Icons.menu_book_outlined,
                title: 'About & information',
              ),
              const SizedBox(height: 10),
              const _SettingsInfoTile(
                icon: Icons.description_outlined,
                iconColor: Color(0xFFA35422),
                iconBackground: Color(0xFFFFEFD8),
                title: 'Your saved progress',
                message: 'Your profile, favorites, and drafts stay on this device. Online submission and account services are not connected yet.',
              ),
              const SizedBox(height: 9),
              const _SettingsInfoTile(
                icon: Icons.shield_outlined,
                iconColor: Color(0xFFC7612D),
                iconBackground: Color(0xFFFFE8DE),
                title: 'Your privacy',
                message: 'Signing out keeps your drafts for your next visit. Device storage is not encrypted; avoid saving sensitive identification or financial documents. Files are kept for the current session only.',
              ),
              const SizedBox(height: 9),
              const _SettingsInfoTile(
                icon: Icons.accessibility_new_rounded,
                iconColor: Color(0xFFD17A00),
                iconBackground: Color(0xFFFFECCB),
                title: 'Accessibility',
                message: 'FurU follows your device text-size preference. Forms use visible labels, validation messages, and large touch controls.',
              ),
              const SizedBox(height: 9),
              const _SettingsInfoTile(
                icon: Icons.favorite_border_rounded,
                iconColor: Color(0xFFE16C4F),
                iconBackground: Color(0xFFFFE7DF),
                title: 'How adoption works',
                message: 'Discover a pet, complete your application, and submit for human review. Approval is never automatic. Rehoming submissions also require review before publication.',
              ),
              const SizedBox(height: 16),
              const Divider(),
              TextButton(
                onPressed: () => showLicensePage(
                  context: context,
                  applicationName: 'FurU',
                  applicationVersion: '1.0.0',
                ),
                child: const Text('Open-source licenses'),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                onPressed: () => _removeAccount(context, app),
                child: const Text('Remove account from this device'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsReferenceHeader extends StatelessWidget {
  const _SettingsReferenceHeader();

  @override
  Widget build(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const _DarkSettingsHeader()
      : AspectRatio(
          aspectRatio: 630 / 260,
          child: Stack(
            children: [
              Positioned.fill(
                child: Semantics(
                  image: true,
                  label:
                      'Settings. FurYou and Whelps. A kinder way to connect.',
                  child: const _SettingsReferenceSlice(
                    crop: Rect.fromLTWH(170, 122, 630, 260),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                width: 56,
                height: 48,
                child: TextButton(
                  onPressed: () => Navigator.maybePop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.transparent,
                    overlayColor: Colors.transparent,
                    splashFactory: NoSplash.splashFactory,
                  ),
                  child: const Text('Back'),
                ),
              ),
            ],
          ),
        );
}

class _DarkSettingsHeader extends StatelessWidget {
  const _DarkSettingsHeader();

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 178,
    child: Stack(
      children: [
        Positioned(
          right: -12,
          top: 12,
          child: Icon(
            Icons.pets_rounded,
            size: 105,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: .08),
          ),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: IconButton(
            tooltip: 'Back',
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        const Positioned(left: 48, top: 6, child: Brand(small: true)),
        Positioned(
          left: 4,
          right: 4,
          top: 92,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'A kinder way to connect.',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 5),
              Text(
                'Choose how FurU looks and behaves on this device.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SettingsReferenceSlice extends StatelessWidget {
  final Rect crop;
  const _SettingsReferenceSlice({required this.crop});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = constraints.maxWidth / crop.width;
      return ClipRect(
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              left: -crop.left * scale,
              top: -crop.top * scale,
              width: 941 * scale,
              height: 1672 * scale,
              child: Image.asset(
                'assets/brand/settings-reference.png',
                fit: BoxFit.fill,
                filterQuality: FilterQuality.high,
                excludeFromSemantics: true,
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _SettingsSectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SettingsSectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF4B2C1B)
              : const Color(0xFFFFE8C9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: Color(0xFFC15A18)),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontSize: 20),
          ),
        ),
      ),
    ],
  );
}

class _NotificationSettingsCard extends StatelessWidget {
  final AppController app;
  const _NotificationSettingsCard({required this.app});

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface,
    elevation: 1,
    shadowColor: const Color(0x14203B32),
    borderRadius: BorderRadius.circular(18),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Icon(
            Icons.notifications_none_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 27,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Activity notifications',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
                Text(
                  'Show updates and reminders inside FurU',
                  style: TextStyle(fontSize: 11.5),
                ),
              ],
            ),
          ),
          Switch(
            value: app.notificationsEnabled,
            onChanged: (value) async {
              try {
                await app.setNotifications(value);
              } catch (error) {
                if (context.mounted) showError(context, error);
              }
            },
          ),
        ],
      ),
    ),
  );
}

class _SettingsInfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String message;
  const _SettingsInfoTile({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface,
    elevation: 1,
    shadowColor: const Color(0x14203B32),
    borderRadius: BorderRadius.circular(18),
    child: InkWell(
      onTap: () => showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Color.alphaBlend(
                        iconColor.withValues(alpha: .22),
                        Theme.of(context).colorScheme.surface,
                      )
                    : iconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.primary
                    : iconColor,
                size: 23,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(fontSize: 11, height: 1.25),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
      ),
    ),
  );
}

class LegacySettingsScreen extends StatelessWidget {
  const LegacySettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return PageBody(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Brand(),
          const SizedBox(height: 24),
          Text(
            'A kinder way to connect.',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          const Text('Choose how FurU looks and behaves on this device.'),
          const SizedBox(height: 24),
          Text('Appearance', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          const _ThemePicker(),
          const SizedBox(height: 24),
          Text('Notifications', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          FurUSectionCard(
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(
                Icons.notifications_outlined,
                color: FurUColors.forest,
              ),
              title: const Text(
                'Activity notifications',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: const Text('Show updates and reminders inside FurU'),
              value: app.notificationsEnabled,
              onChanged: (value) async {
                try {
                  await app.setNotifications(value);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value
                              ? 'Notifications enabled.'
                              : 'Notifications paused.',
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) showError(context, e);
                }
              },
            ),
          ),
          const SizedBox(height: 18),
          const FurUSectionCard(
            child: Text(
              'Your saved progress\n\nYour profile, favorites, and drafts stay on this device. Online submission and account services are not connected yet.',
            ),
          ),
          const SizedBox(height: 18),
          const FurUSectionCard(
            child: Text(
              'Your privacy\n\nSigning out keeps your drafts for your next visit. Device storage is not encrypted; avoid saving sensitive identification or financial documents. Files are kept for the current session only.',
            ),
          ),
          const SizedBox(height: 18),
          const FurUSectionCard(
            child: Text(
              'Accessibility\n\nFurU follows your device text-size preference. Forms use visible labels, validation messages, and large touch controls.',
            ),
          ),
          const SizedBox(height: 18),
          const FurUSectionCard(
            child: Text(
              'How adoption works\n\nDiscover a pet, complete your application, and submit for human review. Approval is never automatic. Rehoming submissions also require review before publication.',
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => showLicensePage(
              context: context,
              applicationName: 'FurU',
              applicationVersion: '1.0.0',
            ),
            child: const Text('Open-source licenses'),
          ),
          if (app.profile!.email != 'guest@furu.local') ...[
            const SizedBox(height: 8),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Remove account from this device?'),
                    content: const Text(
                      'Your profile, favorites, applications, and drafts will be permanently removed.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Keep account'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Remove account'),
                      ),
                    ],
                  ),
                );
                if (confirmed != true || !context.mounted) return;
                try {
                  Navigator.pop(context);
                  await app.deleteAccount();
                } catch (e) {
                  if (context.mounted) showError(context, e);
                }
              },
              child: const Text('Remove account from this device'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ThemePicker extends StatelessWidget {
  const _ThemePicker();

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    const choices = [
      (
        AppThemePreference.defaultTheme,
        'Default',
        'FurU cream',
        Icons.auto_awesome_rounded,
      ),
      (
        AppThemePreference.dark,
        'Dark',
        'Easy on the eyes',
        Icons.dark_mode_rounded,
      ),
      (
        AppThemePreference.light,
        'Light',
        'Bright and clean',
        Icons.light_mode_rounded,
      ),
      (
        AppThemePreference.system,
        'System',
        'Follow your phone',
        Icons.phone_android_rounded,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final choice in choices)
              SizedBox(
                width: width,
                child: _ThemeChoice(
                  preference: choice.$1,
                  title: choice.$2,
                  subtitle: choice.$3,
                  icon: choice.$4,
                  selected: app.themePreference == choice.$1,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ThemeChoice extends StatelessWidget {
  final AppThemePreference preference;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  const _ThemeChoice({
    required this.preference,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: selected
        ? (Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF57321F)
              : const Color(0xFFFFE8DD))
        : Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: () async {
        try {
          await AppScope.of(context).setThemePreference(preference);
        } catch (error) {
          if (context.mounted) showError(context, error);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? const Color(0xFFB64F18)
                : Theme.of(context).dividerColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 29,
              color: selected
                  ? const Color(0xFFB64F18)
                  : Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(fontSize: 10.5),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                size: 22,
                color: Color(0xFFB64F18),
              ),
          ],
        ),
      ),
    ),
  );
}
