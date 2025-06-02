// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      uid: json['uid'] as String,
      role: $enumDecodeNullable(_$RoleEnumMap, json['role']),
      sex: json['sex'] as String?,
      email: json['email'] as String,
      name: json['name'] as String?,
      busy: json['busy'] as bool? ?? false,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
      tokens:
          (json['tokens'] as List<dynamic>?)?.map((e) => e as String).toList(),
      biography: json['biography'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
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
    };

const _$RoleEnumMap = {
  Role.admin: 'admin',
  Role.doctor: 'doctor',
  Role.patient: 'patient',
  Role.unknown: 'unknown',
};
