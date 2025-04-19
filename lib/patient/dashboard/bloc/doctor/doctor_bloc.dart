// Doctor Bloc

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:medtalk/backend/doctor/interfaces/doctor_interface.dart';
import 'package:medtalk/backend/doctor/models/doctor.dart';

part 'doctor_event.dart';
part 'doctor_state.dart';

@injectable
class PatientDoctorBloc extends Bloc<PatientDoctorEvent, PatientDoctorState> {
  PatientDoctorBloc(this._doctorRepo) : super(PatientDoctorsInitial()) {
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
