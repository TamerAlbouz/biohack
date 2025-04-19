// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Appointment _$AppointmentFromJson(Map<String, dynamic> json) => Appointment(
      appointmentId: json['appointmentId'] as String?,
      doctorId: json['doctorId'] as String,
      patientId: json['patientId'] as String,
      specialty: json['specialty'] as String,
      status: $enumDecode(_$AppointmentStatusEnumMap, json['status']),
      serviceName: json['serviceName'] as String,
      fee: (json['fee'] as num).toInt(),
      appointmentDate: DateTime.parse(json['appointmentDate'] as String),
      duration: (json['duration'] as num?)?.toInt(),
      location: json['location'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      appointmentType:
          $enumDecode(_$AppointmentTypeEnumMap, json['appointmentType']),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AppointmentToJson(Appointment instance) =>
    <String, dynamic>{
      'appointmentId': instance.appointmentId,
      'doctorId': instance.doctorId,
      'patientId': instance.patientId,
      'specialty': instance.specialty,
      'status': _$AppointmentStatusEnumMap[instance.status]!,
      'serviceName': instance.serviceName,
      'fee': instance.fee,
      'appointmentDate': instance.appointmentDate.toIso8601String(),
      'duration': instance.duration,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'appointmentType': _$AppointmentTypeEnumMap[instance.appointmentType]!,
      'location': instance.location,
    };

const _$AppointmentStatusEnumMap = {
  AppointmentStatus.scheduled: 'scheduled',
  AppointmentStatus.confirmed: 'confirmed',
  AppointmentStatus.cancelled: 'cancelled',
  AppointmentStatus.inProgress: 'inProgress',
  AppointmentStatus.completed: 'completed',
  AppointmentStatus.missed: 'missed',
  AppointmentStatus.rescheduled: 'rescheduled',
};

const _$AppointmentTypeEnumMap = {
  AppointmentType.inPerson: 'inPerson',
  AppointmentType.online: 'online',
  AppointmentType.homeVisit: 'homeVisit',
};
