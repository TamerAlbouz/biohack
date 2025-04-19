// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CallDetails _$CallDetailsFromJson(Map<String, dynamic> json) => CallDetails(
      isCallStarted: json['isCallStarted'] as bool? ?? false,
      doctorJoinedAt: json['doctorJoinedAt'] == null
          ? null
          : DateTime.parse(json['doctorJoinedAt'] as String),
      patientJoinedAt: json['patientJoinedAt'] == null
          ? null
          : DateTime.parse(json['patientJoinedAt'] as String),
      callEndedAt: json['callEndedAt'] == null
          ? null
          : DateTime.parse(json['callEndedAt'] as String),
    );

Map<String, dynamic> _$CallDetailsToJson(CallDetails instance) =>
    <String, dynamic>{
      'isCallStarted': instance.isCallStarted,
      'doctorJoinedAt': instance.doctorJoinedAt?.toIso8601String(),
      'patientJoinedAt': instance.patientJoinedAt?.toIso8601String(),
      'callEndedAt': instance.callEndedAt?.toIso8601String(),
    };
