part of 'patient_profile_bloc.dart';

sealed class PatientProfileEvent extends Equatable {
  const PatientProfileEvent();
}

final class LoadPatientProfile extends PatientProfileEvent {
  final String patientId;

  const LoadPatientProfile(this.patientId);

  @override
  List<Object> get props => [patientId];
}

class UpdatePatientProfile extends PatientProfileEvent {
  final String? name;
  final String? biography;
  final String? bloodType;
  final double? height;
  final double? weight;
  final String? sex;
  final DateTime? dateOfBirth;

  const UpdatePatientProfile({
    this.name,
    this.biography,
    this.bloodType,
    this.height,
    this.weight,
    this.sex,
    this.dateOfBirth,
  });

  @override
  List<Object?> get props =>
      [name, biography, bloodType, height, weight, sex, dateOfBirth];
}
