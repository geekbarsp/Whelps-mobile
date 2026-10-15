import '../../models/models.dart';

class FieldSpec {
  final String label;
  final List<String>? options;
  final bool optional;
  final int lines;
  const FieldSpec(
    this.label, {
    this.options,
    this.optional = false,
    this.lines = 1,
  });
}

class FormStep {
  final String title, subtitle;
  final List<FieldSpec> fields;
  final bool photos, documents;
  const FormStep(
    this.title,
    this.subtitle,
    this.fields, {
    this.photos = false,
    this.documents = false,
  });
}

List<FormStep> workflowSteps(SubmissionKind kind) =>
    kind == SubmissionKind.adoption
    ? [
        FormStep(
          'Let’s get to know you',
          'The beginning of a wonderful connection.',
          [
            const FieldSpec('Full name'),
            const FieldSpec('Email'),
            const FieldSpec('Phone number'),
            const FieldSpec('Location'),
          ],
        ),
        const FormStep(
          'A place to call home',
          'Help us understand the home you can offer.',
          [
            FieldSpec(
              'Home type',
              options: ['House', 'Apartment', 'Condominium', 'Other'],
            ),
            FieldSpec(
              'Housing arrangement',
              options: [
                'Owned',
                'Rented with permission',
                'Living with family with permission',
              ],
            ),
            FieldSpec('Pets allowed by housing', options: ['Yes', 'No']),
            FieldSpec('Household members'),
            FieldSpec(
              'Household agreement',
              options: ['Everyone agrees', 'Still discussing'],
            ),
            FieldSpec('Safe space for the pet', lines: 3),
          ],
        ),
        const FormStep(
          'Care, every single day',
          'There is no perfect answer. Just tell us your plan.',
          [
            FieldSpec(
              'Pet experience',
              options: [
                'First-time pet parent',
                'Had pets before',
                'Currently have pets',
              ],
            ),
            FieldSpec('Current pets', optional: true, lines: 2),
            FieldSpec('Daily care and time alone', lines: 3),
            FieldSpec(
              'Monthly household income range',
              options: [
                'Below ₱15,000',
                '₱15,000–₱29,999',
                '₱30,000–₱49,999',
                '₱50,000 or above',
                'Prefer to discuss with Whelps',
              ],
            ),
            FieldSpec('Veterinary and financial care plan', lines: 3),
          ],
        ),
        const FormStep(
          'Why this little friend?',
          'Tell us what makes this connection special.',
          [
            FieldSpec('Reason for adoption', lines: 5),
            FieldSpec(
              'Long-term care commitment',
              options: ['I can provide lifelong care', 'I would like guidance'],
            ),
          ],
        ),
        const FormStep(
          'Supporting documents',
          'Add any helpful supporting information. Documents are optional.',
          [],
          documents: true,
        ),
        const FormStep(
          'One last look',
          'Review your answers before sending your application.',
          [],
        ),
      ]
    : [
        const FormStep(
          'Meet your pet',
          'Start with the little details that make them unique.',
          [
            FieldSpec('Pet name'),
            FieldSpec('Species', options: ['Dog', 'Cat', 'Other']),
            FieldSpec('Breed'),
            FieldSpec('Age in months'),
            FieldSpec('Sex', options: ['Male', 'Female', 'Unknown']),
            FieldSpec('Size', options: ['Small', 'Medium', 'Large']),
            FieldSpec('Location'),
          ],
        ),
        const FormStep(
          'Their best side',
          'Add 1–3 clear photos. Let their personality shine.',
          [],
          photos: true,
        ),
        const FormStep(
          'Health & wellbeing',
          'Being open helps a new family prepare.',
          [
            FieldSpec(
              'Vaccination status',
              options: [
                'Up to date',
                'Partially vaccinated',
                'Not vaccinated',
                'Unknown',
              ],
            ),
            FieldSpec('Spayed or neutered', options: ['Yes', 'No', 'Unknown']),
            FieldSpec('Health and care needs', lines: 4),
          ],
          documents: true,
        ),
        const FormStep(
          'Their story matters',
          'Share their personality and why they need a new home.',
          [
            FieldSpec('Personality and behavior', lines: 3),
            FieldSpec('Compatibility with pets and children', lines: 3),
            FieldSpec('Reason for rehoming', lines: 4),
          ],
        ),
        FormStep(
          'Who is caring for them?',
          'A reviewer will use these details to follow up.',
          [
            const FieldSpec('Full name'),
            const FieldSpec('Email'),
            const FieldSpec('Phone number'),
            const FieldSpec(
              'Relationship to pet',
              options: ['Owner', 'Foster carer', 'Authorized carer'],
            ),
            const FieldSpec(
              'Ownership or authorization',
              options: ['I am authorized to rehome this pet'],
            ),
          ],
        ),
        const FormStep(
          'Ready for a fresh start',
          'Check the details. Every submission gets human review.',
          [],
        ),
      ];

String? validateAnswer(FieldSpec field, String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) {
    return field.optional ? null : 'Please enter ${field.label.toLowerCase()}.';
  }
  if (field.label == 'Email' &&
      !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(text)) {
    return 'Enter a valid email address.';
  }
  if (field.label == 'Phone number' &&
      text.replaceAll(RegExp(r'\D'), '').length < 7) {
    return 'Enter a valid phone number.';
  }
  if (field.label == 'Age in months' &&
      (int.tryParse(text) == null ||
          int.parse(text) < 0 ||
          int.parse(text) > 600)) {
    return 'Enter an age from 0 to 600 months.';
  }
  return null;
}
