// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Patient _$PatientFromJson(Map<String, dynamic> json) => Patient(
      email: json['email'] as String,
      uid: json['uid'] as String,
      name: json['name'] as String?,
      role: $enumDecodeNullable(_$RoleEnumMap, json['role']),
      busy: json['busy'] as bool? ?? false,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
      tokens:
          (json['tokens'] as List<dynamic>?)?.map((e) => e as String).toList(),
      biography: json['biography'] as String?,
      medicalRecords: (json['medicalRecords'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      recentDoctors: (json['recentDoctors'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      sex: json['sex'] as String?,
      dateOfBirth: const TimestampConverter().fromJson(json['dateOfBirth']),
      bloodType: json['bloodType'] as String?,
      weight: (json['weight'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      savedCreditCards: (json['savedCreditCards'] as List<dynamic>?)
          ?.map((e) => SavedCreditCard.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PatientToJson(Patient instance) => <String, dynamic>{
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
      'medicalRecords': instance.medicalRecords,
      'recentDoctors': instance.recentDoctors,
      'dateOfBirth': const TimestampConverter().toJson(instance.dateOfBirth),
      'bloodType': instance.bloodType,
      'weight': instance.weight,
      'height': instance.height,
      'savedCreditCards':
          instance.savedCreditCards?.map((e) => e.toJson()).toList(),
    };

const _$RoleEnumMap = {
  Role.admin: 'admin',
  Role.doctor: 'doctor',
  Role.patient: 'patient',
  Role.unknown: 'unknown',
};

SavedCreditCard _$SavedCreditCardFromJson(Map<String, dynamic> json) =>
    SavedCreditCard(
      id: json['id'] as String,
      cardNumber: json['cardNumber'] as String,
      cardholderName: json['cardholderName'] as String,
      expiryDate: json['expiryDate'] as String,
      cardType: json['cardType'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
    );

Map<String, dynamic> _$SavedCreditCardToJson(SavedCreditCard instance) =>
    <String, dynamic>{
      'id': instance.id,
      'cardNumber': instance.cardNumber,
      'cardholderName': instance.cardholderName,
      'expiryDate': instance.expiryDate,
      'cardType': instance.cardType,
      'isDefault': instance.isDefault,
    };
