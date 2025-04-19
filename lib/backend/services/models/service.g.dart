// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Service _$ServiceFromJson(Map<String, dynamic> json) => Service(
      uid: json['uid'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      duration: (json['duration'] as num).toInt(),
      price: (json['price'] as num).toInt(),
      isOnline: json['isOnline'] as bool,
      isInPerson: json['isInPerson'] as bool,
      isHomeVisit: json['isHomeVisit'] as bool,
      preAppointmentInstructions: json['preAppointmentInstructions'] as String?,
      customAvailability: json['customAvailability'] == null
          ? null
          : ServiceAvailability.fromJson(
              json['customAvailability'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ServiceToJson(Service instance) => <String, dynamic>{
      'uid': instance.uid,
      'title': instance.title,
      'description': instance.description,
      'duration': instance.duration,
      'price': instance.price,
      'isOnline': instance.isOnline,
      'isInPerson': instance.isInPerson,
      'isHomeVisit': instance.isHomeVisit,
      'preAppointmentInstructions': instance.preAppointmentInstructions,
      'customAvailability': instance.customAvailability,
    };

ServiceAvailability _$ServiceAvailabilityFromJson(Map<String, dynamic> json) =>
    ServiceAvailability(
      days: (json['days'] as List<dynamic>).map((e) => e as bool).toList(),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
    );

Map<String, dynamic> _$ServiceAvailabilityToJson(
        ServiceAvailability instance) =>
    <String, dynamic>{
      'days': instance.days,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
    };
