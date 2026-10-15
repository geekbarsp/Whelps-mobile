import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../core/app_controller.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../widgets/components.dart';
import 'workflow_fields.dart';
import 'activity_screen.dart';

void openWorkflow(BuildContext context, Submission submission) {
  Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => submission.status == ApplicationStatus.draft
          ? WorkflowScreen(submission: submission)
          : SubmissionDetail(id: submission.id),
    ),
  );
}

class WorkflowScreen extends StatefulWidget {
  final Submission submission;
  const WorkflowScreen({super.key, required this.submission});
  @override
  State<WorkflowScreen> createState() => _WorkflowScreenState();
}

class _WorkflowScreenState extends State<WorkflowScreen> {
  late Submission draft = widget.submission;
  late final Map<String, String> answers = {...draft.answers};
  late List<Attachment> attachments = [...draft.attachments];
  late int step = draft.step;
  final form = GlobalKey<FormState>();
  final scroll = ScrollController();
  Timer? debounce;
  Future<void> pending = Future.value();
  bool busy = false, agreed = false, canLeave = false;
  String saveLabel = 'Progress saved on this device';
  late AppController app;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    app = AppScope.of(context);
  }

  @override
  void dispose() {
    debounce?.cancel();
    scroll.dispose();
    super.dispose();
  }

  List<FormStep> get steps => workflowSteps(draft.kind);
  Submission snapshot() => draft.copyWith(
    answers: {...answers},
    attachments: [...attachments],
    step: step,
  );
  Future<void> save() {
    debounce?.cancel();
    final item = snapshot();
    final next = pending
        .catchError((Object _) {})
        .then((_) => app.saveSubmission(item));
    pending = next;
    return next;
  }

  void changed(String key, String value) {
    answers[key] = value;
    setState(() => saveLabel = 'Saving draft…');
    debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 550), () async {
      try {
        await save();
        if (mounted) {
          setState(() => saveLabel = 'Progress saved on this device');
        }
      } catch (_) {
        if (mounted) {
          setState(
            () => saveLabel = 'Could not save. Use Save & exit to retry.',
          );
        }
      }
    });
  }

  Future<void> exit() async {
    if (busy) return;
    setState(() => busy = true);
    try {
      await save();
      if (!mounted) return;
      setState(() => canLeave = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
    } catch (e) {
      if (mounted) {
        showError(context, e);
        setState(() => busy = false);
      }
    }
  }

  Future<void> pick(bool image) async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: image
            ? ['jpg', 'jpeg', 'png', 'webp']
            : ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (file == null || !mounted) return;
      final length = await file.length();
      if (length == null || length == 0 || length > 5 * 1024 * 1024) {
        throw StateError('Choose a file between 1 byte and 5 MB.');
      }
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      if (attachments.where((a) => a.isImage == image).length >=
          (image ? 3 : 3)) {
        throw StateError(
          'You can add up to 3 ${image ? 'photos' : 'documents'}.',
        );
      }
      setState(
        () => attachments.add(
          Attachment(file.name, isImage: image, bytes: bytes),
        ),
      );
      await save();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> next() async {
    if (!form.currentState!.validate()) return;
    if (steps[step].photos &&
        !attachments.any((a) => a.isImage && a.bytes != null)) {
      showError(context, 'Add at least one pet photo to continue.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => busy = true);
    try {
      if (step < steps.length - 1) {
        setState(() => step++);
        await save();
        if (scroll.hasClients) scroll.jumpTo(0);
      } else {
        for (var i = 0; i < steps.length - 1; i++) {
          if (steps[i].fields.any(
            (f) => validateAnswer(f, answers[f.label]) != null,
          )) {
            setState(() => step = i);
            throw StateError('Please complete the highlighted section.');
          }
        }
        if (!agreed) {
          throw StateError('Please confirm the agreement before submitting.');
        }
        await save();
        await app.submit(snapshot());
        if (!mounted) return;
        setState(() => canLeave = true);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute<void>(
                builder: (_) =>
                    SubmissionDetail(id: draft.id, justSubmitted: true),
              ),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) showError(context, e);
    }
    if (mounted) setState(() => busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final current = steps[step];
    final pet = app.petById(draft.petId);
    return PopScope(
      canPop: canLeave,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) exit();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Save and go back',
            onPressed: exit,
            icon: const Icon(Icons.arrow_back),
          ),
          title: Text(
            draft.kind == SubmissionKind.adoption
                ? 'Adopt ${pet?.name ?? 'a pet'}'
                : 'Rehome a pet',
          ),
          actions: [
            TextButton(
              onPressed: busy ? null : exit,
              child: const Text('Save & exit'),
            ),
          ],
        ),
        body: PageBody(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STEP ${step + 1} OF ${steps.length}',
                      style: const TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (step + 1) / steps.length,
                        minHeight: 6,
                        backgroundColor: FurUColors.sage,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scroll,
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Form(
                    key: form,
                    child: AnimatedSwitcher(
                      duration: motionDuration(
                        context,
                        const Duration(milliseconds: 300),
                      ),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(.06, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      ),
                      child: Column(
                        key: ValueKey(step),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            current.title,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 10),
                          Text(current.subtitle),
                          const SizedBox(height: 26),
                          for (final field in current.fields)
                            field.options != null
                                ? FurUDropdown(
                                    label: field.label,
                                    options: field.options!,
                                    value: answers[field.label],
                                    onChanged: (v) => changed(field.label, v!),
                                  )
                                : FurUTextField(
                                    label: field.optional
                                        ? '${field.label} (optional)'
                                        : field.label,
                                    initialValue: answers[field.label],
                                    lines: field.lines,
                                    keyboardType: field.label == 'Email'
                                        ? TextInputType.emailAddress
                                        : field.label == 'Phone number'
                                        ? TextInputType.phone
                                        : field.label == 'Age in months'
                                        ? TextInputType.number
                                        : null,
                                    validator: (v) => validateAnswer(field, v),
                                    onChanged: (v) => changed(field.label, v),
                                  ),
                          if (current.photos || current.documents) ...[
                            if (current.documents)
                              const FurUSectionCard(
                                color: FurUColors.sage,
                                child: Text(
                                  'Supporting documents are optional. Files stay in this session; select them again after restarting. Avoid sensitive documents until private uploads are available.',
                                ),
                              ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: () => pick(current.photos),
                              icon: Icon(
                                current.photos
                                    ? Icons.add_photo_alternate_outlined
                                    : Icons.upload_file_outlined,
                              ),
                              label: Text(
                                current.photos
                                    ? 'Choose a pet photo'
                                    : 'Choose a document',
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'JPG / PNG / PDF for documents · up to 5 MB each',
                              style: TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 18),
                            for (final a in attachments.where(
                              (a) => a.isImage == current.photos,
                            ))
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: FurUSectionCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (a.isImage && a.bytes != null)
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          child: Image.memory(
                                            a.bytes!,
                                            height: 140,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, _, _) =>
                                                const Text(
                                                  'Image preview unavailable',
                                                ),
                                          ),
                                        ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              a.name,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          IconButton(
                                            tooltip: 'Remove ${a.name}',
                                            onPressed: () async {
                                              setState(
                                                () => attachments.remove(a),
                                              );
                                              try {
                                                await save();
                                              } catch (e) {
                                                if (context.mounted) {
                                                  showError(context, e);
                                                }
                                              }
                                            },
                                            icon: const Icon(Icons.close),
                                          ),
                                        ],
                                      ),
                                      if (a.bytes == null)
                                        const Text(
                                          'Reselect this file: remove it, then add it again.',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                          if (step == steps.length - 1) ...[
                            for (var i = 0; i < steps.length - 1; i++)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: FurUSectionCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              steps[i].title,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () => setState(() {
                                              step = i;
                                              agreed = false;
                                            }),
                                            child: const Text('Edit'),
                                          ),
                                        ],
                                      ),
                                      for (final f in steps[i].fields)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 10,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                f.label,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Text(
                                                answers[f.label]?.isNotEmpty ==
                                                        true
                                                    ? answers[f.label]!
                                                    : 'Not provided',
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      if (steps[i].photos || steps[i].documents)
                                        Text(
                                          '${attachments.where((a) => a.isImage == steps[i].photos).length} file(s) selected',
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                              value: agreed,
                              onChanged: (v) => setState(() => agreed = v!),
                              title: const Text(
                                'I confirm these details are accurate and agree to human review.',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Your submission will be saved on this device. Online delivery is not connected yet. Approval and pet publication require human review.',
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              MediaQuery.viewInsetsOf(context).bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    if (step > 0) ...[
                      IconButton.outlined(
                        tooltip: 'Previous step',
                        onPressed: busy
                            ? null
                            : () {
                                setState(() => step--);
                                if (scroll.hasClients) scroll.jumpTo(0);
                              },
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: FurUPrimaryButton(
                        label: step == steps.length - 1
                            ? 'Submit for review'
                            : 'Continue',
                        icon: Icons.arrow_forward_rounded,
                        busy: busy,
                        onPressed: next,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(saveLabel, style: const TextStyle(fontSize: 11)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
