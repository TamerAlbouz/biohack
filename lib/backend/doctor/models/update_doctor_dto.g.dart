// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_doctor_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateDoctorDto _$UpdateDoctorDtoFromJson(Map<String, dynamic> json) =>
    UpdateDoctorDto(
      uid: json['uid'] as String,
      availability: (json['availability'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k,
            e == null
                ? null
                : WorkingHours.fromJson(e as Map<String, dynamic>)),
      ),
      profilePictureUrl: json['profilePictureUrl'] as String?,
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      biography: json['biography'] as String?,
      locationNotes: json['locationNotes'] as String?,
      qualifications: (json['qualifications'] as List<dynamic>?)
          ?.map((e) => Qualification.fromJson(e as Map<String, dynamic>))
          .toList(),
      location: json['location'] as String?,
    );

Map<String, dynamic> _$UpdateDoctorDtoToJson(UpdateDoctorDto instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'biography': instance.biography,
      'profilePictureUrl': instance.profilePictureUrl,
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'availability':
          instance.availability.map((k, e) => MapEntry(k, e?.toJson())),
      'locationNotes': instance.locationNotes,
      'location': instance.location,
      'qualifications':
          instance.qualifications?.map((e) => e.toJson()).toList(),
    };
