import '../../models.dart';

class Doctor extends User {
  const Doctor({
    required super.email,
    required super.uid,
    required super.name,
    required super.role,
    required super.busy,
    super.profilePictureUrl,
    super.createdAt,
    super.updatedAt,
    super.appointments,
    super.tokens,
    super.paymentIds,
    super.biography,
    this.sessionLength,
    this.specialties,
    this.reviewIds,
    this.servicesAndFees,
    this.availability,
    this.notes,
    this.clinicId,
  });

  /// list of doctor specialities ids
  final List<String>? specialties;

  /// List of review document IDs
  final List<String>? reviewIds;

  /// Example: {'consultation': 60}
  final Map<String, double>? servicesAndFees;

  /// Example: {'monday': ['09:00', '10:00']}
  final Map<String, List<String>>? availability;

  /// The length of each session in minutes.
  final int? sessionLength;

  /// IDs of Notes taken by the doctor during or after a consultation.
  final List<String>? notes;

  /// ID of clinic
  final String? clinicId;

  /// Returns a new [Doctor] with updated fields.
  @override
  Doctor copyWith({
    String? email,
    String? uid,
    String? name,
    String? role,
    String? profilePictureUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? appointments,
    bool? busy,
    String? biography,
    List<String>? tokens,
    List<String>? specialties,
    List<String>? reviewIds,
    Map<String, double>? servicesAndFees,
    Map<String, List<String>>? availability,
    int? sessionLength,
    List<String>? notes,
    List<String>? paymentIds,
    String? clinicId,
  }) {
    return Doctor(
      email: email ?? this.email,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      role: role ?? this.role,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      appointments: appointments ?? this.appointments,
      busy: busy ?? this.busy,
      tokens: tokens ?? this.tokens,
      specialties: specialties ?? this.specialties,
      reviewIds: reviewIds ?? this.reviewIds,
      servicesAndFees: servicesAndFees ?? this.servicesAndFees,
      availability: availability ?? this.availability,
      sessionLength: sessionLength ?? this.sessionLength,
      notes: notes ?? this.notes,
      paymentIds: paymentIds ?? this.paymentIds,
      clinicId: clinicId ?? this.clinicId,
    );
  }

  /// Converts a [Map<String, dynamic>] to a [Doctor].
  factory Doctor.fromMap(Map<String, dynamic> data) {
    return Doctor(
      email: data['email'],
      uid: data['uid'],
      name: data['name'],
      role: data['role'],
      profilePictureUrl: data['profilePictureUrl'],
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
      appointments: data['appointments'],
      busy: data['busy'],
      tokens: data['tokens'],
      paymentIds: data['paymentIds'],
      biography: data['biography'],
      specialties: data['specialties'],
      reviewIds: data['reviewIds'],
      servicesAndFees: data['servicesAndFees'],
      availability: data['availability'],
      sessionLength: data['sessionLength'],
      notes: data['notes'],
      clinicId: data['clinicId'],
    );
  }

  /// Converts a [Doctor] to a [Map<String, dynamic>].
  @override
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'uid': uid,
      'name': name,
      'role': role,
      'profilePictureUrl': profilePictureUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'appointments': appointments,
      'busy': busy,
      'tokens': tokens,
      'paymentIds': paymentIds,
      'biography': biography,
      'specialties': specialties,
      'reviewIds': reviewIds,
      'servicesAndFees': servicesAndFees,
      'availability': availability,
      'sessionLength': sessionLength,
      'notes': notes,
      'clinicId': clinicId,
    };
  }

  @override
  List<Object?> get props => [
        email,
        uid,
        name,
        role,
        profilePictureUrl,
        createdAt,
        updatedAt,
        appointments,
        busy,
        tokens,
        specialties,
        reviewIds,
        servicesAndFees,
        availability,
        sessionLength,
        notes,
        paymentIds,
        clinicId,
      ];
}
