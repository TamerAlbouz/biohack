// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      uid: json['uid'] as String,
      role: $enumDecodeNullable(_$RoleEnumMap, json['role']),
      email: json['email'] as String,
      name: json['name'] as String?,
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
      emailVerified: json['emailVerified'] as bool? ?? false,
      biography: json['biography'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
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
    };

const _$RoleEnumMap = {
  Role.admin: 'admin',
  Role.doctor: 'doctor',
  Role.patient: 'patient',
  Role.unknown: 'unknown',
};
