part of 'setup_appointment_bloc.dart';

sealed class SetupAppointmentEvent extends Equatable {
  const SetupAppointmentEvent();
}

class ToggleRebuild extends SetupAppointmentEvent {
  @override
  List<Object?> get props => [];
}
