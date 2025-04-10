import 'package:json_annotation/json_annotation.dart';

import '../../../backend.dart';

part 'doctor.g.dart';

@JsonSerializable()
class Doctor extends User {
  const Doctor(
      {required super.email,
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
      super.sex,
      super.tokens,
      super.biography,
      this.specialties,
      required this.availability,
      this.notes,
      this.clinicId,
      this.patientIds});

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

  /// Example: {'monday': ['09:00', '10:00']}
  final Map<String, List<String>?> availability;

  /// IDs of Notes taken by the doctor during or after a consultation.
  final List<String>? notes;

  /// ID of clinic
  final String? clinicId;

  /// List of patient IDs associated with this doctor.
  final List<String>? patientIds;

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
    bool? busy,
    List<String>? tokens,
    String? biography,
    List<String>? specialties,
    Map<String, List<String>?>? availability,
    List<String>? notes,
    String? clinicId,
    List<String>? patientIds,
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
      busy: busy ?? this.busy,
      tokens: tokens ?? this.tokens,
      biography: biography ?? this.biography,
      specialties: specialties ?? this.specialties,
      availability: availability ?? this.availability,
      notes: notes ?? this.notes,
      clinicId: clinicId ?? this.clinicId,
      patientIds: patientIds ?? this.patientIds,
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
      busy: data['busy'],
      tokens: const ["100"],
      biography: data['biography'],
      specialties: data['specialties'] != null
          ? List<String>.from(data['specialties'])
          : null,
      availability: (data['availability'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, List<String>.from(v))),
      notes: data['notes'] != null ? List<String>.from(data['notes']) : null,
      clinicId: data['clinicId'],
      patientIds: data['patientIds'] != null
          ? List<String>.from(data['patientIds'])
          : null,
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
      'busy': busy,
      'tokens': tokens,
      'biography': biography,
      'specialties': specialties,
      'availability': availability,
      'notes': notes,
      'clinicId': clinicId,
      'patientIds': patientIds,
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
        busy,
        tokens,
        biography,
        specialties,
        availability,
        notes,
        clinicId,
        patientIds,
      ];

  factory Doctor.fromJson(Map<String, dynamic> json) => _$DoctorFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DoctorToJson(this);
}
