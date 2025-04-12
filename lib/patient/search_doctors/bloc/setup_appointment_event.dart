part of 'setup_appointment_bloc.dart';

abstract class SetupAppointmentEvent extends Equatable {
  const SetupAppointmentEvent();

  @override
  List<Object?> get props => [];
}

class ToggleRebuild extends SetupAppointmentEvent {}

class LoadInitialData extends SetupAppointmentEvent {
  final String doctorId;
  final String specialty;

  const LoadInitialData(this.doctorId, this.specialty);

  @override
  List<Object?> get props => [doctorId, specialty];
}

class LoadServiceTypes extends SetupAppointmentEvent {}

class UpdateServiceType extends SetupAppointmentEvent {
  final SelectionItem serviceType;

  const UpdateServiceType(this.serviceType);

  @override
  List<Object?> get props => [serviceType];
}

class UpdateDoctorInfo extends SetupAppointmentEvent {
  final String doctorId;
  final String specialty;

  const UpdateDoctorInfo(this.doctorId, this.specialty);

  @override
  List<Object?> get props => [doctorId, specialty];
}

class UpdateAppointmentDate extends SetupAppointmentEvent {
  final DateTime date;

  const UpdateAppointmentDate(this.date);

  @override
  List<Object?> get props => [date];
}

class UpdateAppointmentTime extends SetupAppointmentEvent {
  final TimeOfDay time;

  const UpdateAppointmentTime(this.time);

  @override
  List<Object?> get props => [time];
}

class SelectCreditCard extends SetupAppointmentEvent {
  final String cardId;

  const SelectCreditCard(this.cardId);

  @override
  List<Object?> get props => [cardId];
}

class AddCreditCard extends SetupAppointmentEvent {
  final SavedCreditCard card;

  const AddCreditCard(this.card);

  @override
  List<Object?> get props => [card];
}

class UpdateAppointmentType extends SetupAppointmentEvent {
  final AppointmentType appointmentType;
  final String appointmentLocation;

  const UpdateAppointmentType(this.appointmentType, this.appointmentLocation);

  @override
  List<Object?> get props => [appointmentType, appointmentLocation];
}

class UpdatePaymentType extends SetupAppointmentEvent {
  final PaymentType paymentType;

  const UpdatePaymentType(this.paymentType);

  @override
  List<Object?> get props => [paymentType];
}

class ToggleTermsAccepted extends SetupAppointmentEvent {
  final bool value;

  const ToggleTermsAccepted(this.value);

  @override
  List<Object?> get props => [value];
}

class BookAppointment extends SetupAppointmentEvent {}

class ResetError extends SetupAppointmentEvent {}
