import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase/firebase.dart';
import 'package:models/models.dart';
import 'package:p_logger/p_logger.dart';

part 'patient_event.dart';
part 'patient_state.dart';

class PatientBloc extends Bloc<PatientEvent, PatientState> {
  PatientBloc({
    required IPatientRepository patientRepo,
    required IAuthenticationRepository authRepo,
  })  : _patientRepo = patientRepo,
        _authRepo = authRepo,
        super(PatientInitial()) {
    on<LoadPatient>(_onLoadPatient);
  }

  final IPatientRepository _patientRepo;
  final IAuthenticationRepository _authRepo;
  late Patient? _patient;

  Future<void> _onLoadPatient(
      LoadPatient event, Emitter<PatientState> emit) async {
    await emit.onEach(_authRepo.user, onData: (patient) async {
      if (patient != User.empty) {
        _patient = await _patientRepo.getPatient(patient.uid);
        logger.i('Patient found in database: $_patient');
        emit(PatientLoaded(_patient!));
      }
    }, onError: (error, stackTrace) {
      addError(error, stackTrace);
      emit(PatientError(error.toString()));
    });
  }
}
