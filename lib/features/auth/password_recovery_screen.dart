import 'package:flutter/material.dart';

import '../../core/app_controller.dart';
import '../../widgets/components.dart';

class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({super.key});
  @override
  State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final form = GlobalKey<FormState>();
  final password = TextEditingController();
  final confirmation = TextEditingController();
  bool busy = false;

  @override
  void dispose() {
    password.dispose();
    confirmation.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!form.currentState!.validate()) return;
    setState(() => busy = true);
    try {
      await AppScope.of(context).completePasswordRecovery(password.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your password has been updated.')),
        );
      }
    } catch (error) {
      if (mounted) showError(context, error);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: PageBody(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.lock_reset_rounded, size: 58),
                  const SizedBox(height: 20),
                  Text(
                    'Create a new password',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Use a unique password with at least eight characters.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FurUTextField(
                    label: 'New password',
                    controller: password,
                    obscure: true,
                    validator: (value) => (value?.length ?? 0) < 8
                        ? 'Use at least 8 characters.'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  FurUTextField(
                    label: 'Confirm new password',
                    controller: confirmation,
                    obscure: true,
                    validator: (value) => value != password.text
                        ? 'The passwords do not match.'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  FurUPrimaryButton(
                    label: 'Update password',
                    busy: busy,
                    onPressed: submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
