part of 'appointment_bloc.dart';

sealed class AppointmentEvent extends Equatable {
  const AppointmentEvent();
}

class LoadAppointment extends AppointmentEvent {
  final String appointmentId;

  const LoadAppointment(this.appointmentId);

  @override
  List<Object> get props => [appointmentId];
}
