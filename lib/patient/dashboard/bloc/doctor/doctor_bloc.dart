// Doctor Bloc
import 'package:backend/backend.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'doctor_event.dart';
part 'doctor_state.dart';

class PatientDoctorBloc extends Bloc<PatientDoctorEvent, PatientDoctorState> {
  PatientDoctorBloc({
    required IDoctorRepository doctorRepo,
  })  : _doctorRepo = doctorRepo,
        super(PatientDoctorsInitial()) {
    on<LoadPatientDoctors>(_onLoadPatientDoctors);
  }

  final IDoctorRepository _doctorRepo;

  Future<void> _onLoadPatientDoctors(
      LoadPatientDoctors event, Emitter<PatientDoctorState> emit) async {
    emit(PatientDoctorsLoading());
    try {
      final doctors = await _doctorRepo.getPatientDoctors(event.patientId);
      emit(PatientDoctorsLoaded(doctors));
    } catch (e) {
      emit(PatientDoctorsError(e.toString()));
    }
  }
}
