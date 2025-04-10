part of 'appointment_bloc.dart';

sealed class PatientAppointmentEvent extends Equatable {
  const PatientAppointmentEvent();
}

class LoadPatientAppointment extends PatientAppointmentEvent {
  final String patientId;

  const LoadPatientAppointment(this.patientId);

  @override
  List<Object> get props => [patientId];
}
