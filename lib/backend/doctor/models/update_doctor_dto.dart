import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:medtalk/backend/doctor/models/doctor_work_times.dart';
import 'package:medtalk/backend/doctor/models/qualification.dart';
import 'package:medtalk/backend/services/models/service.dart';

part 'update_doctor_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class UpdateDoctorDto extends Equatable {
  const UpdateDoctorDto({
    required this.uid,
    required this.availability,
    this.profilePictureUrl,
    this.updatedAt,
    this.biography,
    this.services,
    this.locationNotes,
    this.qualifications,
    this.location,
  });

  /// Uid of the doctor
  final String uid;

  /// Biography of the doctor
  final String? biography;

  /// URL of the doctor's profile picture.
  final String? profilePictureUrl;

  /// Date when the doctor profile was last updated.
  final DateTime? updatedAt;

  /// Example: {'monday': ['09:00', '10:00']}
  final Map<String, WorkingHours?> availability;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final List<Service>? services;

  /// Notes about the doctor's location
  final String? locationNotes;

  /// Specific location where the doctor practices
  final String? location;

  /// List of qualifications the doctor holds
  final List<Qualification>? qualifications;

  @override
  List<Object?> get props => [
        uid,
        profilePictureUrl,
        updatedAt,
        biography,
        availability,
        services,
        locationNotes,
        qualifications,
        location,
      ];

  factory UpdateDoctorDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateDoctorDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateDoctorDtoToJson(this);
}
