// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doctor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Doctor _$DoctorFromJson(Map<String, dynamic> json) => Doctor(
      email: json['email'] as String,
      uid: json['uid'] as String,
      licNum: json['licNum'] as String,
      govIdUrl: json['govIdUrl'] as String,
      medicalLicenseUrl: json['medicalLicenseUrl'] as String,
      active: json['active'] as bool,
      name: json['name'] as String?,
      role: $enumDecodeNullable(_$RoleEnumMap, json['role']),
      busy: json['busy'] as bool? ?? false,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      sex: json['sex'] as String?,
      tokens:
          (json['tokens'] as List<dynamic>?)?.map((e) => e as String).toList(),
      biography: json['biography'] as String?,
      specialties: (json['specialties'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      availability: (json['availability'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k,
            e == null
                ? null
                : WorkingHours.fromJson(e as Map<String, dynamic>)),
      ),
      patientIds: (json['patientIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      previousName: json['previousName'] as String?,
      licenseType: json['licenseType'] as String?,
      zone: json['zone'] as String?,
      location: json['location'] as String?,
      isAtlanticRegistry: json['isAtlanticRegistry'] as bool?,
      registryHomeJurisdiction: json['registryHomeJurisdiction'] as String?,
      registrantType: json['registrantType'] as String?,
      termsAccepted: json['termsAccepted'] as bool?,
    );

Map<String, dynamic> _$DoctorToJson(Doctor instance) => <String, dynamic>{
      'sex': instance.sex,
      'role': _$RoleEnumMap[instance.role],
      'profilePictureUrl': instance.profilePictureUrl,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'email': instance.email,
      'uid': instance.uid,
      'name': instance.name,
      'busy': instance.busy,
      'tokens': instance.tokens,
      'biography': instance.biography,
      'govIdUrl': instance.govIdUrl,
      'medicalLicenseUrl': instance.medicalLicenseUrl,
      'active': instance.active,
      'licNum': instance.licNum,
      'specialties': instance.specialties,
      'availability':
          instance.availability.map((k, e) => MapEntry(k, e?.toJson())),
      'patientIds': instance.patientIds,
      'previousName': instance.previousName,
      'licenseType': instance.licenseType,
      'zone': instance.zone,
      'location': instance.location,
      'isAtlanticRegistry': instance.isAtlanticRegistry,
      'registryHomeJurisdiction': instance.registryHomeJurisdiction,
      'registrantType': instance.registrantType,
      'termsAccepted': instance.termsAccepted,
    };

const _$RoleEnumMap = {
  Role.admin: 'admin',
  Role.doctor: 'doctor',
  Role.patient: 'patient',
  Role.unknown: 'unknown',
};
