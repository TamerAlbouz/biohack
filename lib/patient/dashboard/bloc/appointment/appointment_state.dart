part of 'appointment_bloc.dart';

sealed class PatientAppointmentState extends Equatable {
  const PatientAppointmentState();
}

final class AppointmentInitial extends PatientAppointmentState {
  @override
  List<Object> get props => [];
}

final class AppointmentLoading extends PatientAppointmentState {
  @override
  List<Object> get props => [];
}

final class AppointmentLoaded extends PatientAppointmentState {
  final Appointment appointment;

  const AppointmentLoaded(this.appointment);

  @override
  List<Object> get props => [appointment];
}

final class AppointmentError extends PatientAppointmentState {
  final String message;

  const AppointmentError(this.message);

  @override
  List<Object> get props => [message];
}
