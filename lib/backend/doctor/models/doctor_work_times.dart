import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'doctor_work_times.g.dart';

@JsonSerializable(explicitToJson: true)
class WorkingHours extends Equatable {
  final bool isWorking;
  final String startTime;
  final String endTime;
  final List<BreakTime> breaks;

  const WorkingHours({
    required this.isWorking,
    required this.startTime,
    required this.endTime,
    this.breaks = const [],
  });

  factory WorkingHours.fromJson(Map<String, dynamic> json) =>
      _$WorkingHoursFromJson(json);

  Map<String, dynamic> toJson() => _$WorkingHoursToJson(this);

  @override
  List<Object> get props => [isWorking, startTime, endTime, breaks];
}

@JsonSerializable()
class BreakTime extends Equatable {
  final String? title;
  final String startTime;
  final String endTime;

  const BreakTime({
    this.title,
    required this.startTime,
    required this.endTime,
  });

  factory BreakTime.fromJson(Map<String, dynamic> json) =>
      _$BreakTimeFromJson(json);

  Map<String, dynamic> toJson() => _$BreakTimeToJson(this);

  @override
  List<Object?> get props => [title, startTime, endTime];
}
