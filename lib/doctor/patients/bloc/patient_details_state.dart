part of 'patient_details_bloc.dart';

abstract class PatientDetailsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PatientDetailsInitial extends PatientDetailsState {}

class PatientDetailsLoading extends PatientDetailsState {}

class PatientDetailsLoaded extends PatientDetailsState {
  final Patient patient;
  final List<Appointment> appointments;
  final List<Message> messages;
  final List<PatientDocument> documents;

  PatientDetailsLoaded({
    required this.patient,
    required this.appointments,
    required this.messages,
    required this.documents,
  });

  @override
  List<Object?> get props => [patient, appointments, messages, documents];
}

class PatientDetailsError extends PatientDetailsState {
  final String message;

  PatientDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}
