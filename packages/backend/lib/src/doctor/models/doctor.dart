import 'package:json_annotation/json_annotation.dart';

import '../../../backend.dart';

part 'doctor.g.dart';

@JsonSerializable()
class Doctor extends User {
  const Doctor({
    required super.email,
    required super.uid,
    required this.state,
    required this.licNum,
    required this.govIdUrl,
    required this.medicalLicenseUrl,
    required this.active,
    super.name,
    required super.role,
    super.busy,
    super.profilePictureUrl,
    super.createdAt,
    super.updatedAt,
    super.appointments,
    super.sex,
    super.tokens,
    super.paymentIds,
    super.biography,
    this.specialties,
    this.reviewIds,
    required this.availability,
    this.notes,
    this.clinicId,
  });

  /// URL of the doctor's government ID.
  final String govIdUrl;

  /// URL of the doctor's medical license.
  final String medicalLicenseUrl;

  /// Whether the doctor is active or not.
  final bool active;

  /// The state in which the doctor is licensed.
  final String state;

  /// License Number
  final String licNum;

  /// list of doctor specialties (simple titles)
  final List<String>? specialties;

  /// List of review document IDs
  final List<String>? reviewIds;

  /// Example: {'monday': ['09:00', '10:00']}
  final Map<String, List<String>?> availability;

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
    String? sex,
    String? state,
    String? licNum,
    String? govIdUrl,
    String? medicalLicenseUrl,
    bool? active,
    String? profilePictureUrl,
    DateTime? updatedAt,
    List<String>? appointments,
    bool? busy,
    List<String>? tokens,
    List<String>? paymentIds,
    String? biography,
    List<String>? specialties,
    List<String>? reviewIds,
    Map<String, List<String>?>? availability,
    List<String>? notes,
    String? clinicId,
  }) {
    return Doctor(
      active: active ?? this.active,
      email: email ?? this.email,
      uid: uid,
      name: name ?? this.name,
      sex: sex ?? this.sex,
      state: state ?? this.state,
      licNum: licNum ?? this.licNum,
      govIdUrl: govIdUrl ?? this.govIdUrl,
      medicalLicenseUrl: medicalLicenseUrl ?? this.medicalLicenseUrl,
      role: role,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      appointments: appointments ?? this.appointments,
      busy: busy ?? this.busy,
      tokens: tokens ?? this.tokens,
      paymentIds: paymentIds ?? this.paymentIds,
      biography: biography ?? this.biography,
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
      active: data['active'],
      name: data['name'],
      state: data['state'],
      sex: data['sex'],
      licNum: data['licNum'],
      govIdUrl: data['govIdUrl'],
      medicalLicenseUrl: data['medicalLicenseUrl'],
      role: Role.doctor,
      profilePictureUrl: data['profilePictureUrl'],
      createdAt: data['createdAt'].toDate(),
      updatedAt: data['updatedAt']?.toDate(),
      appointments: data['appointments'] != null
          ? List<String>.from(data['appointments'])
          : [],
      busy: data['busy'],
      tokens: ["100"],
      paymentIds: [],
      biography: data['biography'],
      specialties: data['specialties'] != null
          ? List<String>.from(data['specialties'])
          : null,
      reviewIds: data['reviewIds'] != null
          ? List<String>.from(data['reviewIds'])
          : null,
      availability: (data['availability'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, List<String>.from(v))),
      notes: data['notes'] != null ? List<String>.from(data['notes']) : null,
      clinicId: data['clinicId'],
    );
  }

  /// Converts a [Doctor] to a [Map<String, dynamic>].
  Map<String, dynamic> get toMap {
    return {
      'email': email,
      'uid': uid,
      'active': active,
      'sex': sex,
      'name': name,
      'state': state,
      'licNum': licNum,
      'govIdUrl': govIdUrl,
      'medicalLicenseUrl': medicalLicenseUrl,
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
      'notes': notes,
      'clinicId': clinicId,
    };
  }

  @override
  List<Object?> get props => [
        email,
        uid,
        name,
        state,
        licNum,
        govIdUrl,
        medicalLicenseUrl,
        role,
        sex,
        profilePictureUrl,
        createdAt,
        active,
        updatedAt,
        appointments,
        busy,
        tokens,
        paymentIds,
        biography,
        specialties,
        reviewIds,
        availability,
        notes,
        clinicId,
      ];

  factory Doctor.fromJson(Map<String, dynamic> json) => _$DoctorFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DoctorToJson(this);
}
