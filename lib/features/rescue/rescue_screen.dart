import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme.dart';
import '../../widgets/components.dart';

void openRescue(BuildContext context) => Navigator.push(
  context,
  MaterialPageRoute<void>(builder: (_) => const RescueScreen()),
);

/// Official public resources; these organizations are not represented as FurU partners.
const rescueContacts = [
  (
    name: 'Pawssion Project',
    detail: 'Rescue assistance & shelter inquiries',
    url: 'https://pawssionproject.org.ph/faqs/',
    note: 'Their official FAQ explains how to request help and links to their contact form.',
  ),
  (
    name: 'Philippine Animal Welfare Society',
    detail: 'Animal welfare & reporting guidance',
    url: 'https://paws.org.ph/contact/',
    note: 'Visit PAWS for contact information and guidance on rescue or animal-welfare concerns.',
  ),
];

class RescueScreen extends StatefulWidget {
  const RescueScreen({super.key});
  @override
  State<RescueScreen> createState() => _RescueScreenState();
}

class _RescueScreenState extends State<RescueScreen> {
  final form = GlobalKey<FormState>();
  final location = TextEditingController();
  final details = TextEditingController();
  @override
  void dispose() {
    location.dispose();
    details.dispose();
    super.dispose();
  }

  Future<void> openContact(String url) async {
    try {
      if (!await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      )) {
        throw StateError(
          'Could not open the website. You can copy its address below.',
        );
      }
    } catch (_) {
      if (!mounted) return;
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Open this contact page'),
          content: SelectableText(url),
          actions: [
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: url));
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Copy link'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Contact for Rescue')),
    body: PageBody(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 30),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [FurUColors.forest, Color(0xFF406C58)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFDFE9D9),
                  child: Icon(
                    Icons.volunteer_activism_outlined,
                    color: FurUColors.forest,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Be their first\nstep to safety.',
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Find people who care. Reach out directly through trusted public contact pages.',
                  style: TextStyle(color: Colors.white, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const FurUSectionCard(
            color: FurUColors.peach,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: FurUColors.forest),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Urgent situation? Contact a nearby veterinary clinic or your city veterinary office. Rescue groups may not respond immediately.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Who you can contact',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          const Text('Public resources in the Philippines'),
          const SizedBox(height: 16),
          for (final contact in rescueContacts)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: FurUSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          backgroundColor: FurUColors.sage,
                          child: Icon(
                            Icons.pets_outlined,
                            color: FurUColors.forest,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                contact.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                contact.detail,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(contact.note),
                    const SizedBox(height: 16),
                    FurUPrimaryButton(
                      label: 'Open official contact page',
                      icon: Icons.open_in_new,
                      onPressed: () => openContact(contact.url),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          const Text(
            'These are independent organizations. Availability and assistance depend on their capacity. Opening a page does not send a rescue request.',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 28),
          Text(
            'Make your message helpful',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'Include the exact location, what you observed, and a recent photo if you have one.',
          ),
          const SizedBox(height: 20),
          Form(
            key: form,
            child: Column(
              children: [
                FurUTextField(
                  label: 'Location or nearby landmark',
                  controller: location,
                ),
                FurUTextField(
                  label: 'What did you observe?',
                  hint: 'Number of animals, their condition, and when you saw them',
                  controller: details,
                  lines: 4,
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    if (!form.currentState!.validate()) return;
                    await Clipboard.setData(
                      ClipboardData(
                        text:
                            'Animal assistance request\nLocation: ${location.text.trim()}\nDetails: ${details.text.trim()}\n\nPlease let me know if you can assist and what information you need.',
                      ),
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Message copied. Paste it into the contact page you choose.',
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy_outlined),
                  label: const Text('Copy rescue message'),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Only copied to your clipboard. Nothing is sent automatically.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
