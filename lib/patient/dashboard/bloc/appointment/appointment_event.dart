part of 'appointment_bloc.dart';

sealed class PatientAppointmentEvent extends Equatable {
  const PatientAppointmentEvent();
}

class LoadPatientAppointment extends PatientAppointmentEvent {
  final String appointmentId;

  const LoadPatientAppointment(this.appointmentId);

  @override
  List<Object> get props => [appointmentId];
}
