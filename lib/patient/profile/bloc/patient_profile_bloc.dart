import 'package:backend/backend.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:p_logger/p_logger.dart';

part 'patient_profile_event.dart';
part 'patient_profile_state.dart';

class PatientProfileBloc
    extends Bloc<PatientProfileEvent, PatientProfileState> {
  PatientProfileBloc(
    this._patientRepository,
  ) : super(PatientProfileInitial()) {
    on<LoadPatientProfile>(_onLoadPatientProfile);
  }

  final IPatientRepository _patientRepository;

  void _onLoadPatientProfile(
    LoadPatientProfile event,
    Emitter<PatientProfileState> emit,
  ) async {
    emit(PatientProfileLoading());
    try {
      logger.i('Loading patient profile');
      final Patient? patient =
          await _patientRepository.getPatient(event.patientId);

      if (patient == null) {
        emit(const PatientProfileError('Patient not found'));
        return;
      }

      logger.i('Patient profile loaded');
      emit(PatientProfileLoaded(patient));
    } catch (e) {
      logger.e('Error loading patient profile: $e');
      emit(PatientProfileError(e.toString()));
    }
  }
}
