import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase/firebase.dart';
import 'package:models/models.dart';

part 'appointment_event.dart';
part 'appointment_state.dart';

// AppointmentBloc.dart
class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  AppointmentBloc({required IAppointmentRepository appointmentRepo})
      : _appointmentRepo = appointmentRepo,
        super(AppointmentInitial()) {
    on<LoadAppointment>(_onLoadAppointment);
  }

  final IAppointmentRepository _appointmentRepo;
  late Appointment? _appointment;

  Future<void> _onLoadAppointment(
      LoadAppointment event, Emitter<AppointmentState> emit) async {
    try {
      _appointment = await _appointmentRepo.getAppointment(event.appointmentId);
      emit(AppointmentLoaded(_appointment!));
    } catch (e, stackTrace) {
      emit(AppointmentError(e.toString()));
    }
  }
}
