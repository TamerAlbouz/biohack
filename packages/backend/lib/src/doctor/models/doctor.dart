import 'package:json_annotation/json_annotation.dart';

import '../../../backend.dart';

part 'doctor.g.dart';

@JsonSerializable()
class Doctor extends User {
  const Doctor({
    required super.email,
    required super.uid,
    super.name,
    required super.role,
    super.busy,
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
    this.availability,
    this.notes,
    this.clinicId,
  });

  /// list of doctor specialties (simple titles)
  final List<String>? specialties;

  /// List of review document IDs
  final List<String>? reviewIds;

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
    String? name,
    bool? firstTime,
    String? profilePictureUrl,
    DateTime? updatedAt,
    List<String>? appointments,
    bool? busy,
    List<String>? tokens,
    List<String>? paymentIds,
    String? biography,
    List<String>? specialties,
    List<String>? reviewIds,
    Map<String, List<String>>? availability,
    int? sessionLength,
    List<String>? notes,
    String? clinicId,
  }) {
    return Doctor(
      email: email ?? this.email,
      uid: uid,
      name: name ?? this.name,
      role: role,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      appointments: appointments ?? this.appointments,
      busy: busy ?? this.busy,
      tokens: tokens ?? this.tokens,
      paymentIds: paymentIds ?? this.paymentIds,
      biography: biography ?? this.biography,
      sessionLength: sessionLength ?? this.sessionLength,
      specialties: specialties ?? this.specialties,
      reviewIds: reviewIds ?? this.reviewIds,
      availability: availability ?? this.availability,
      notes: notes ?? this.notes,
      clinicId: clinicId ?? this.clinicId,
    );
  }

  /// Converts a [Map<String, dynamic>] to a [Doctor].
  factory Doctor.fromMap(String docId, Map<String, dynamic> data) {
    return Doctor(
      email: data['email'],
      uid: docId,
      name: data['name'],
      role: Role.values.byName(data['role']),
      profilePictureUrl: data['profilePictureUrl'],
      createdAt: data['createdAt'].toDate(),
      updatedAt: data['updatedAt']?.toDate(),
      appointments: data['appointments'] != null
          ? List<String>.from(data['appointments'])
          : [],
      busy: data['busy'],
      tokens: data['tokens'],
      paymentIds: data['paymentIds'],
      biography: data['biography'],
      specialties: data['specialties'] != null
          ? List<String>.from(data['specialties'])
          : null,
      reviewIds: data['reviewIds'] != null
          ? List<String>.from(data['reviewIds'])
          : null,
      availability: data['availability'] != null
          ? (data['availability'] as Map<String, dynamic>)
              .map((k, v) => MapEntry(k, List<String>.from(v)))
          : null,
      sessionLength: data['sessionLength'],
      notes: data['notes'] != null ? List<String>.from(data['notes']) : null,
      clinicId: data['clinicId'],
    );
  }

  /// Converts a [Doctor] to a [Map<String, dynamic>].
  Map<String, dynamic> get toMap {
    return {
      'email': email,
      'uid': uid,
      'name': name,
      'role': role!.name,
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
        paymentIds,
        biography,
        specialties,
        reviewIds,
        availability,
        sessionLength,
        notes,
        clinicId,
      ];

  factory Doctor.fromJson(Map<String, dynamic> json) => _$DoctorFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DoctorToJson(this);
}
