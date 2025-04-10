import 'package:backend/backend.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'appointment_event.dart';
part 'appointment_state.dart';

// AppointmentBloc.dart
class PatientAppointmentBloc
    extends Bloc<PatientAppointmentEvent, PatientAppointmentState> {
  PatientAppointmentBloc({required IAppointmentRepository appointmentRepo})
      : _appointmentRepo = appointmentRepo,
        super(AppointmentInitial()) {
    on<LoadPatientAppointment>(_onLoadAppointment);
  }

  final IAppointmentRepository _appointmentRepo;
  late Appointment? _appointment;

  Future<void> _onLoadAppointment(LoadPatientAppointment event,
      Emitter<PatientAppointmentState> emit) async {
    try {
      _appointment =
          await _appointmentRepo.getPatientAppointmentLatest(event.patientId);
      emit(AppointmentLoaded(_appointment!));
    } catch (e) {
      emit(AppointmentError(e.toString()));
    }
  }
}
