// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Patient _$PatientFromJson(Map<String, dynamic> json) => Patient(
      email: json['email'] as String,
      uid: json['uid'] as String,
      name: json['name'] as String?,
      emailVerified: json['emailVerified'] as bool? ?? false,
      role: $enumDecodeNullable(_$RoleEnumMap, json['role']),
      busy: json['busy'] as bool? ?? false,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      appointments: (json['appointments'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      tokens:
          (json['tokens'] as List<dynamic>?)?.map((e) => e as String).toList(),
      paymentIds: (json['paymentIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      biography: json['biography'] as String?,
      medicalRecords: (json['medicalRecords'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      recentDoctors: (json['recentDoctors'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      sex: json['sex'] as String?,
      dateOfBirth: json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
      bloodType: json['bloodType'] as String?,
      weight: (json['weight'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$PatientToJson(Patient instance) => <String, dynamic>{
      'role': _$RoleEnumMap[instance.role],
      'profilePictureUrl': instance.profilePictureUrl,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'email': instance.email,
      'uid': instance.uid,
      'name': instance.name,
      'busy': instance.busy,
      'appointments': instance.appointments,
      'tokens': instance.tokens,
      'paymentIds': instance.paymentIds,
      'biography': instance.biography,
      'emailVerified': instance.emailVerified,
      'medicalRecords': instance.medicalRecords,
      'recentDoctors': instance.recentDoctors,
      'sex': instance.sex,
      'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
      'bloodType': instance.bloodType,
      'weight': instance.weight,
      'height': instance.height,
    };

const _$RoleEnumMap = {
  Role.admin: 'admin',
  Role.doctor: 'doctor',
  Role.patient: 'patient',
  Role.unknown: 'unknown',
};
