import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:medtalk/backend/authentication/enums/role.dart';
import 'package:medtalk/backend/doctor/models/doctor_work_times.dart';
import 'package:medtalk/backend/doctor/models/qualification.dart';
import 'package:medtalk/backend/extensions/timestamp_converter.dart';
import 'package:medtalk/backend/services/models/service.dart';
import 'package:medtalk/backend/user/models/user.dart';

part 'doctor.g.dart';

@JsonSerializable(explicitToJson: true, converters: [
  TimestampConverter(),
])
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
    this.locationNotes,
    this.qualifications,
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

  /// Notes about the doctor's location
  final String? locationNotes;

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

  /// List of qualifications the doctor holds
  final List<Qualification>? qualifications;

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
    Timestamp? updatedAt,
    bool? busy,
    List<String>? tokens,
    String? biography,
    List<String>? specialties,
    Map<String, WorkingHours?>? availability,
    List<String>? patientIds,
    List<Service>? services,
    String? locationNotes,
    List<Qualification>? qualifications,
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
      locationNotes: locationNotes ?? this.locationNotes,
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
      qualifications: qualifications ?? this.qualifications,
    );
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
        locationNotes,
        qualifications,
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
