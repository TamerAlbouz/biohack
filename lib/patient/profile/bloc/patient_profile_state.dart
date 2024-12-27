part of 'patient_profile_bloc.dart';

sealed class PatientProfileState extends Equatable {
  const PatientProfileState();
}

final class PatientProfileInitial extends PatientProfileState {
  @override
  List<Object> get props => [];
}

final class PatientProfileLoading extends PatientProfileState {
  @override
  List<Object> get props => [];
}

final class PatientProfileLoaded extends PatientProfileState {
  final Patient patient;

  const PatientProfileLoaded(this.patient);

  @override
  List<Object> get props => [patient];
}

final class PatientProfileError extends PatientProfileState {
  final String message;

  const PatientProfileError(this.message);

  @override
  List<Object> get props => [message];
}
