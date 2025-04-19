import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:medtalk/backend/patient/interfaces/patient_interface.dart';
import 'package:medtalk/backend/patient/models/patient.dart';

part 'patient_profile_event.dart';
part 'patient_profile_state.dart';

@injectable
class PatientProfileBloc
    extends Bloc<PatientProfileEvent, PatientProfileState> {
  PatientProfileBloc(
    this._patientRepository,
    this.logger,
  ) : super(PatientProfileInitial()) {
    on<LoadPatientProfile>(_onLoadPatientProfile);
  }

  final IPatientRepository _patientRepository;
  final Logger logger;

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
