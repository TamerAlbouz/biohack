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

final class UpdatePatientProfile extends PatientProfileEvent {
  final Patient patient;

  const UpdatePatientProfile(this.patient);

  @override
  List<Object> get props => [patient];
}
