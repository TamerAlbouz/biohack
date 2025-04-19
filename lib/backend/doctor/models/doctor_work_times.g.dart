// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doctor_work_times.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkingHours _$WorkingHoursFromJson(Map<String, dynamic> json) => WorkingHours(
      isWorking: json['isWorking'] as bool,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      breaks: (json['breaks'] as List<dynamic>?)
              ?.map((e) => BreakTime.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$WorkingHoursToJson(WorkingHours instance) =>
    <String, dynamic>{
      'isWorking': instance.isWorking,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'breaks': instance.breaks.map((e) => e.toJson()).toList(),
    };

BreakTime _$BreakTimeFromJson(Map<String, dynamic> json) => BreakTime(
      title: json['title'] as String?,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
    );

Map<String, dynamic> _$BreakTimeToJson(BreakTime instance) => <String, dynamic>{
      'title': instance.title,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
    };
