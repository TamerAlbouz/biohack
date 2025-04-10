import 'package:backend/backend.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
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
  static Patient? _patient;

  Future<void> _onLoadPatient(
      LoadPatient event, Emitter<PatientState> emit) async {
    emit(PatientLoading());
    try {
      if (_patient != null) {
        emit(PatientLoaded(_patient!));
      } else {
        _patient = await _patientRepo.getPatient(_authRepo.currentUser.uid);

        if (_patient == null) {
          emit(const PatientError('Patient not found'));
        } else {
          logger.i('Patient found in database: $_patient]');
          emit(PatientLoaded(_patient!));
        }
      }
    } catch (e) {
      logger.e(e);
      emit(PatientError(e.toString()));
    }
  }
}
