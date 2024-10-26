part of 'appointment_bloc.dart';

sealed class AppointmentState extends Equatable {
  const AppointmentState();
}

final class AppointmentInitial extends AppointmentState {
  @override
  List<Object> get props => [];
}

final class AppointmentLoading extends AppointmentState {
  @override
  List<Object> get props => [];
}

final class AppointmentLoaded extends AppointmentState {
  final Appointment appointment;

  const AppointmentLoaded(this.appointment);

  @override
  List<Object> get props => [appointment];
}

final class AppointmentError extends AppointmentState {
  final String message;

  const AppointmentError(this.message);

  @override
  List<Object> get props => [message];
}
