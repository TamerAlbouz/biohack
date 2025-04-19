import 'package:json_annotation/json_annotation.dart';
import 'package:medtalk/backend/authentication/enums/role.dart';
import 'package:medtalk/backend/doctor/models/doctor_work_times.dart';
import 'package:medtalk/backend/services/models/service.dart';
import 'package:medtalk/backend/user/models/user.dart';

part 'doctor.g.dart';

@JsonSerializable(explicitToJson: true)
class Doctor extends User {
  const Doctor({
    required super.email,
    required super.uid,
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
    this.services,
    this.patientIds,
    // New fields from the signup form
    this.previousName,
    this.licenseType,
    this.zone,
    this.location,
    this.isAtlanticRegistry,
    this.registryHomeJurisdiction,
    this.registrantType,
    this.termsAccepted,
  });

  /// URL of the doctor's government ID.
  final String govIdUrl;

  /// URL of the doctor's medical license.
  final String medicalLicenseUrl;

  /// Whether the doctor is active or not.
  final bool active;

  /// License Number
  final String licNum;

  /// list of doctor specialties (simple titles)
  final List<String>? specialties;

  /// Example: {'monday': ['09:00', '10:00']}
  final Map<String, WorkingHours?> availability;

  /// List of patient IDs associated with this doctor.
  final List<String>? patientIds;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final List<Service>? services;

  /// Previous name of the doctor if applicable
  final String? previousName;

  /// Type of license that the doctor holds
  final String? licenseType;

  /// Zone where the doctor practices (e.g., 'Central Zone', 'Eastern Zone')
  final String? zone;

  /// Specific location where the doctor practices
  final String? location;

  /// Whether the doctor is part of the Atlantic Registry
  final bool? isAtlanticRegistry;

  /// Home jurisdiction if part of Atlantic Registry
  final String? registryHomeJurisdiction;

  /// Type of registrant (e.g., 'Family Physicians', 'Specialty')
  final String? registrantType;

  /// Whether the doctor has accepted CPSNS Virtual Care Standards
  final bool? termsAccepted;

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
    Map<String, WorkingHours?>? availability,
    List<String>? patientIds,
    List<Service>? services,
    // New fields
    String? previousName,
    String? licenseType,
    String? zone,
    String? location,
    bool? isAtlanticRegistry,
    String? registryHomeJurisdiction,
    String? registrantType,
    bool? termsAccepted,
  }) {
    return Doctor(
      active: active ?? this.active,
      email: email ?? this.email,
      uid: uid,
      name: name ?? this.name,
      sex: sex ?? this.sex,
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
      patientIds: patientIds ?? this.patientIds,
      services: services ?? this.services,
      // New fields
      previousName: previousName ?? this.previousName,
      licenseType: licenseType ?? this.licenseType,
      zone: zone ?? this.zone,
      location: location ?? this.location,
      isAtlanticRegistry: isAtlanticRegistry ?? this.isAtlanticRegistry,
      registryHomeJurisdiction:
          registryHomeJurisdiction ?? this.registryHomeJurisdiction,
      registrantType: registrantType ?? this.registrantType,
      termsAccepted: termsAccepted ?? this.termsAccepted,
    );
  }

  /// Converts a [Map<String, dynamic>] to a [Doctor].
  factory Doctor.fromMap(String docId, Map<String, dynamic> data) {
    return Doctor(
      email: data['email'],
      uid: docId,
      active: data['active'],
      name: data['name'],
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
          .map((k, v) => MapEntry(k, WorkingHours.fromJson(v))),
      patientIds: data['patientIds'] != null
          ? List<String>.from(data['patientIds'])
          : null,
      services: data['services'] != null
          ? (data['services'] as List<dynamic>)
              .map((e) => Service.fromJson(e))
              .toList()
          : null,
      // New fields
      previousName: data['previousName'],
      licenseType: data['licenseType'],
      zone: data['zone'],
      location: data['location'],
      isAtlanticRegistry: data['isAtlanticRegistry'],
      registryHomeJurisdiction: data['registryHomeJurisdiction'],
      registrantType: data['registrantType'],
      termsAccepted: data['termsAccepted'],
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
      'patientIds': patientIds,
      // New fields
      'previousName': previousName,
      'licenseType': licenseType,
      'zone': zone,
      'location': location,
      'isAtlanticRegistry': isAtlanticRegistry,
      'registryHomeJurisdiction': registryHomeJurisdiction,
      'registrantType': registrantType,
      'termsAccepted': termsAccepted,
    };
  }

  @override
  List<Object?> get props => [
        email,
        uid,
        name,
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
        patientIds,
        services,
        // New fields
        previousName,
        licenseType,
        zone,
        location,
        isAtlanticRegistry,
        registryHomeJurisdiction,
        registrantType,
        termsAccepted,
      ];

  factory Doctor.fromJson(Map<String, dynamic> json) => _$DoctorFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DoctorToJson(this);
}
