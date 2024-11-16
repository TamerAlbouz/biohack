import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'setup_appointment_event.dart';
part 'setup_appointment_state.dart';

class SetupAppointmentBloc
    extends Bloc<SetupAppointmentEvent, SetupAppointmentState> {
  bool reBuild = false;

  SetupAppointmentBloc() : super(AppointmentInitial()) {
    on<ToggleRebuild>((event, emit) {
      reBuild = !reBuild;
      emit(AppointmentRebuild(reBuild));
    });
  }
}
