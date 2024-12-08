part of 'setup_appointment_bloc.dart';

sealed class SetupAppointmentEvent extends Equatable {
  const SetupAppointmentEvent();
}

class ToggleRebuild extends SetupAppointmentEvent {
  @override
  List<Object?> get props => [];
}

class LoadServiceTypes extends SetupAppointmentEvent {
  @override
  List<Object?> get props => [];
}

class UpdateServiceType extends SetupAppointmentEvent {
  final SelectionItem serviceType;

  const UpdateServiceType(this.serviceType);

  @override
  List<Object?> get props => [serviceType];
}

class UpdateAppointmentTime extends SetupAppointmentEvent {
  final TimeOfDay time;

  const UpdateAppointmentTime(this.time);

  @override
  List<Object?> get props => [time];
}

class UpdateAppointmentDate extends SetupAppointmentEvent {
  final DateTime date;

  const UpdateAppointmentDate(this.date);

  @override
  List<Object?> get props => [date];
}

class UpdateAppointmentType extends SetupAppointmentEvent {
  final String appointmentType;
  final String appointmentLocation;

  const UpdateAppointmentType(this.appointmentType, this.appointmentLocation);

  @override
  List<Object?> get props => [appointmentType, appointmentLocation];
}

class BookAppointment extends SetupAppointmentEvent {
  @override
  List<Object?> get props => [];
}

class UpdatePaymentType extends SetupAppointmentEvent {
  final String paymentType;

  const UpdatePaymentType(this.paymentType);

  @override
  List<Object?> get props => [paymentType];
}
