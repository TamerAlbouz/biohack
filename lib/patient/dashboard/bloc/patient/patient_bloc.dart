import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:medtalk/backend/authentication/interfaces/auth_interface.dart';
import 'package:medtalk/backend/patient/interfaces/patient_interface.dart';
import 'package:medtalk/backend/patient/models/patient.dart';

part 'patient_event.dart';
part 'patient_state.dart';

@injectable
class PatientBloc extends Bloc<PatientEvent, PatientState> {
  PatientBloc(this._patientRepo, this._authRepo, this.logger)
      : super(PatientInitial()) {
    on<LoadPatient>(_onLoadPatient);
  }

  final IPatientRepository _patientRepo;
  final IAuthenticationRepository _authRepo;
  static Patient? _patient;
  final Logger logger;

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
