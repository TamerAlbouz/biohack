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
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
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
      locationNotes: json['locationNotes'] as String?,
      qualifications: (json['qualifications'] as List<dynamic>?)
          ?.map((e) => Qualification.fromJson(e as Map<String, dynamic>))
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
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
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
      'locationNotes': instance.locationNotes,
      'licenseType': instance.licenseType,
      'zone': instance.zone,
      'location': instance.location,
      'isAtlanticRegistry': instance.isAtlanticRegistry,
      'registryHomeJurisdiction': instance.registryHomeJurisdiction,
      'registrantType': instance.registrantType,
      'termsAccepted': instance.termsAccepted,
      'qualifications':
          instance.qualifications?.map((e) => e.toJson()).toList(),
    };

const _$RoleEnumMap = {
  Role.admin: 'admin',
  Role.doctor: 'doctor',
  Role.patient: 'patient',
  Role.unknown: 'unknown',
};
