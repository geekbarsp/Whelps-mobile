import 'dart:typed_data';

enum AccountType { individual, organization }

enum AccountRole { adopter, individualRehomer, organization, admin }

enum PetAvailability { available, pending, adopted, unavailable }

extension PetAvailabilityLabel on PetAvailability {
  String get label => switch (this) {
    PetAvailability.available => 'Available',
    PetAvailability.pending => 'Pending adoption',
    PetAvailability.adopted => 'Adopted',
    PetAvailability.unavailable => 'Unavailable',
  };
}

enum SubmissionKind { adoption, rehome }

enum ApplicationStatus {
  draft,
  submitted,
  underReview,
  approved,
  rejected,
  cancelled,
}

extension StatusLabel on ApplicationStatus {
  String get label => switch (this) {
    ApplicationStatus.underReview => 'Under review',
    _ => name[0].toUpperCase() + name.substring(1),
  };
}

class UserProfile {
  final String name, email, phone, location, region, city, organization;
  final AccountType accountType;
  final AccountRole role;
  final bool verificationRequested, verified;
  const UserProfile({
    required this.name,
    required this.email,
    this.phone = '',
    this.location = '',
    this.region = '',
    this.city = '',
    this.organization = '',
    this.accountType = AccountType.individual,
    this.role = AccountRole.adopter,
    this.verificationRequested = false,
    this.verified = false,
  });
  bool get isAdmin => role == AccountRole.admin;
  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? location,
    String? region,
    String? city,
    String? organization,
    AccountType? accountType,
    AccountRole? role,
    bool? verificationRequested,
    bool? verified,
  }) => UserProfile(
    name: name ?? this.name,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    location: location ?? this.location,
    region: region ?? this.region,
    city: city ?? this.city,
    organization: organization ?? this.organization,
    accountType: accountType ?? this.accountType,
    role: role ?? this.role,
    verificationRequested: verificationRequested ?? this.verificationRequested,
    verified: verified ?? this.verified,
  );
  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'location': location,
    'region': region,
    'city': city,
    'organization': organization,
    'accountType': accountType.name,
    'role': role.name,
    'verificationRequested': verificationRequested,
    'verified': verified,
  };
  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
    name: j['name'],
    email: j['email'],
    phone: j['phone'] ?? '',
    location: j['location'] ?? '',
    region: j['region'] ?? '',
    city: j['city'] ?? '',
    organization: j['organization'] ?? '',
    accountType: AccountType.values.firstWhere(
      (value) => value.name == j['accountType'],
      orElse: () => AccountType.individual,
    ),
    role: AccountRole.values.firstWhere(
      (value) => value.name == j['role'],
      orElse: () => AccountRole.adopter,
    ),
    verificationRequested: j['verificationRequested'] ?? false,
    verified: j['verified'] ?? false,
  );
}

class Pet {
  final String id,
      name,
      species,
      breed,
      sex,
      size,
      location,
      photo,
      description,
      rehomer;
  final int ageMonths;
  final PetAvailability availability;
  final List<String> traits, health;
  const Pet({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.sex,
    required this.size,
    required this.location,
    required this.photo,
    required this.ageMonths,
    required this.description,
    required this.traits,
    required this.health,
    this.rehomer = 'FurU community',
    this.availability = PetAvailability.available,
  });
  String get age => ageMonths < 12
      ? '$ageMonths months'
      : '${ageMonths ~/ 12} ${ageMonths ~/ 12 == 1 ? 'year' : 'years'}';
  String get status => availability.label;
  Pet copyWith({PetAvailability? availability}) => Pet(
    id: id,
    name: name,
    species: species,
    breed: breed,
    sex: sex,
    size: size,
    location: location,
    photo: photo,
    ageMonths: ageMonths,
    description: description,
    traits: traits,
    health: health,
    rehomer: rehomer,
    availability: availability ?? this.availability,
  );
}

class Attachment {
  final String name;
  final bool isImage;
  final Uint8List? bytes;
  const Attachment(this.name, {this.isImage = false, this.bytes});
  Map<String, dynamic> toJson() => {'name': name, 'isImage': isImage};
  factory Attachment.fromJson(Map<String, dynamic> j) =>
      Attachment(j['name'], isImage: j['isImage'] ?? false);
}

class Submission {
  final String id;
  final SubmissionKind kind;
  final String? petId;
  final Map<String, String> answers;
  final List<Attachment> attachments;
  final ApplicationStatus status;
  final int step;
  final DateTime updatedAt;
  final String reviewNote;
  final DateTime? reviewedAt;
  const Submission({
    required this.id,
    required this.kind,
    this.petId,
    required this.answers,
    this.attachments = const [],
    this.status = ApplicationStatus.draft,
    this.step = 0,
    required this.updatedAt,
    this.reviewNote = '',
    this.reviewedAt,
  });
  String get title => kind == SubmissionKind.adoption
      ? 'Adoption application'
      : 'Rehoming submission';
  Submission copyWith({
    Map<String, String>? answers,
    List<Attachment>? attachments,
    ApplicationStatus? status,
    int? step,
    String? reviewNote,
    DateTime? reviewedAt,
  }) => Submission(
    id: id,
    kind: kind,
    petId: petId,
    answers: answers ?? this.answers,
    attachments: attachments ?? this.attachments,
    status: status ?? this.status,
    step: step ?? this.step,
    updatedAt: DateTime.now(),
    reviewNote: reviewNote ?? this.reviewNote,
    reviewedAt: reviewedAt ?? this.reviewedAt,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind.name,
    'petId': petId,
    'answers': answers,
    'attachments': attachments.map((a) => a.toJson()).toList(),
    'status': status.name,
    'step': step,
    'updatedAt': updatedAt.toIso8601String(),
    'reviewNote': reviewNote,
    'reviewedAt': reviewedAt?.toIso8601String(),
  };
  factory Submission.fromJson(Map<String, dynamic> j) => Submission(
    id: j['id'],
    kind: SubmissionKind.values.byName(j['kind']),
    petId: j['petId'],
    answers: Map<String, String>.from(j['answers']),
    attachments: (j['attachments'] as List)
        .map((a) => Attachment.fromJson(Map<String, dynamic>.from(a)))
        .toList(),
    status: ApplicationStatus.values.byName(j['status']),
    step: j['step'],
    updatedAt: DateTime.parse(j['updatedAt']),
    reviewNote: j['reviewNote'] ?? '',
    reviewedAt: j['reviewedAt'] == null
        ? null
        : DateTime.parse(j['reviewedAt']),
  );
}

class AdminReviewCase {
  final UserProfile owner;
  final Submission submission;
  const AdminReviewCase({required this.owner, required this.submission});
}
