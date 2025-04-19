import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:medtalk/backend/appointment/interfaces/appointment_interface.dart';
import 'package:medtalk/backend/appointment/models/appointment.dart';

part 'appointment_event.dart';
part 'appointment_state.dart';

@injectable
class PatientAppointmentBloc
    extends Bloc<PatientAppointmentEvent, PatientAppointmentState> {
  PatientAppointmentBloc(this._appointmentRepo) : super(AppointmentInitial()) {
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
