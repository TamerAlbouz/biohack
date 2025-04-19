import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'call_details.g.dart';

@JsonSerializable()
class CallDetails extends Equatable {
  const CallDetails({
    this.isCallStarted = false,
    this.doctorJoinedAt,
    this.patientJoinedAt,
    this.callEndedAt,
  });

  /// Indicates if the call is started.
  final bool isCallStarted;

  /// Date and time when the doctor joined the call.
  final DateTime? doctorJoinedAt;

  /// Date and time when the patient joined the call.
  final DateTime? patientJoinedAt;

  /// Date and time when the call ended.
  final DateTime? callEndedAt;

  /// Returns a new [CallDetails] with updated fields.
  CallDetails copyWith({
    bool? isCallStarted,
    DateTime? doctorJoinedAt,
    DateTime? patientJoinedAt,
    DateTime? callEndedAt,
  }) {
    return CallDetails(
      isCallStarted: isCallStarted ?? this.isCallStarted,
      doctorJoinedAt: doctorJoinedAt ?? this.doctorJoinedAt,
      patientJoinedAt: patientJoinedAt ?? this.patientJoinedAt,
      callEndedAt: callEndedAt ?? this.callEndedAt,
    );
  }

  /// Converts a [Map<String, dynamic>] to a [CallDetails].
  factory CallDetails.fromMap(Map<String, dynamic> data) {
    return CallDetails(
      isCallStarted: data['isCallStarted'],
      doctorJoinedAt: data['doctorJoinedAt'] != null
          ? DateTime.parse(data['doctorJoinedAt'])
          : null,
      patientJoinedAt: data['patientJoinedAt'] != null
          ? DateTime.parse(data['patientJoinedAt'])
          : null,
      callEndedAt: data['callEndedAt'] != null
          ? DateTime.parse(data['callEndedAt'])
          : null,
    );
  }

  /// Converts a [CallDetails] to a [Map<String, dynamic>].
  Map<String, dynamic> toMap() {
    return {
      'isCallStarted': isCallStarted,
      'doctorJoinedAt': doctorJoinedAt?.toIso8601String(),
      'patientJoinedAt': patientJoinedAt?.toIso8601String(),
      'callEndedAt': callEndedAt?.toIso8601String(),
    };
  }

  factory CallDetails.fromJson(Map<String, dynamic> json) =>
      _$CallDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$CallDetailsToJson(this);

  @override
  List<Object?> get props => [
        isCallStarted,
        doctorJoinedAt,
        patientJoinedAt,
        callEndedAt,
      ];
}
