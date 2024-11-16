part of 'setup_appointment_bloc.dart';

sealed class SetupAppointmentState extends Equatable {
  const SetupAppointmentState();
}

final class AppointmentInitial extends SetupAppointmentState {
  @override
  List<Object> get props => [];
}

class AppointmentRebuild extends SetupAppointmentState {
  final bool reBuild;

  const AppointmentRebuild(this.reBuild);

  @override
  // TODO: implement props
  List<Object?> get props => [reBuild];
}
