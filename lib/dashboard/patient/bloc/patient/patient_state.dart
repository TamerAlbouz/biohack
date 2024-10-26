part of 'patient_bloc.dart';

sealed class PatientState extends Equatable {
  const PatientState();
}

final class PatientInitial extends PatientState {
  @override
  List<Object> get props => [];
}

final class PatientLoading extends PatientState {
  @override
  List<Object> get props => [];
}

final class PatientLoaded extends PatientState {
  final Patient patient;

  const PatientLoaded(this.patient);

  @override
  List<Object> get props => [patient];
}

final class PatientError extends PatientState {
  final String message;

  const PatientError(this.message);

  @override
  List<Object> get props => [message];
}
