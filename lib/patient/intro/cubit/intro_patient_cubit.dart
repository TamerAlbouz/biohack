import 'package:backend/backend.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:formz_inputs/formz_inputs.dart';
import 'package:intl/intl.dart';
import 'package:p_logger/p_logger.dart';

part 'intro_patient_state.dart';

class IntroPatientCubit extends Cubit<IntroPatientState> {
  IntroPatientCubit(this._patientRepository) : super(const IntroPatientState());

  final IPatientRepository _patientRepository;

  void fullNameChanged(String value) {
    final fullName = FullName.dirty(value);
    emit(
      state.copyWith(
        fullName: fullName,
        isValid: Formz.validate([
          fullName,
          state.biography,
          state.bloodGroup,
          state.height,
          state.dateOfBirth,
          state.weight,
          state.sex,
        ]),
      ),
    );
  }

  void biographyChanged(String value) {
    final biography = Biography.dirty(value);
    emit(
      state.copyWith(
        biography: biography,
        isValid: Formz.validate([
          state.fullName,
          biography,
          state.bloodGroup,
          state.height,
          state.dateOfBirth,
          state.weight,
          state.sex,
        ]),
      ),
    );
  }

  void bloodGroupChanged(String value) {
    final bloodGroup = BloodGroup.dirty(value);
    emit(
      state.copyWith(
        bloodGroup: bloodGroup,
        isValid: Formz.validate([
          state.fullName,
          state.biography,
          bloodGroup,
          state.height,
          state.dateOfBirth,
          state.weight,
          state.sex,
        ]),
      ),
    );
  }

  void heightChanged(String value) {
    final height = Height.dirty(value);
    emit(
      state.copyWith(
        height: height,
        isValid: Formz.validate([
          state.fullName,
          state.biography,
          state.bloodGroup,
          height,
          state.dateOfBirth,
          state.weight,
          state.sex,
        ]),
      ),
    );
  }

  void dateOfBirthChanged(String value) {
    final dateOfBirth = DateOfBirth.dirty(value);
    emit(
      state.copyWith(
        dateOfBirth: dateOfBirth,
        isValid: Formz.validate([
          state.fullName,
          state.biography,
          state.bloodGroup,
          state.height,
          dateOfBirth,
          state.weight,
          state.sex,
        ]),
      ),
    );
  }

  void weightChanged(String value) {
    final weight = Weight.dirty(value);
    emit(
      state.copyWith(
        weight: weight,
        isValid: Formz.validate([
          state.fullName,
          state.biography,
          state.bloodGroup,
          state.height,
          state.dateOfBirth,
          weight,
          state.sex,
        ]),
      ),
    );
  }

  void sexChanged(String value) {
    final sex = Sex.dirty(value);
    emit(
      state.copyWith(
        sex: sex,
        isValid: Formz.validate([
          state.fullName,
          state.biography,
          state.bloodGroup,
          state.height,
          state.dateOfBirth,
          state.weight,
          sex,
        ]),
      ),
    );
  }

  Future<void> createPatient(String email, String uid) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    DateFormat formatter = DateFormat('dd/MM/yyyy');
    try {
      Patient patient = Patient(
        email: email,
        name: state.fullName.value,
        biography: state.biography.value,
        bloodType: state.bloodGroup.value,
        height: double.parse(state.height.value),
        dateOfBirth: formatter.parse(state.dateOfBirth.value),
        weight: double.parse(state.weight.value),
        sex: state.sex.value,
        role: Role.patient,
        uid: uid,
        busy: false,
        createdAt: DateTime.now(),
      );

      await _patientRepository.addPatient(patient);
      emit(state.copyWith(status: FormzSubmissionStatus.success));
      logger.i('User logged in with Google');
    } on FirebaseException catch (e) {
      logger.e(e.message);
      emit(
        state.copyWith(
          errorMessage: e.message,
          status: FormzSubmissionStatus.failure,
        ),
      );
    } on LogInWithGoogleFailure catch (e) {
      logger.e(e.message);
      emit(
        state.copyWith(
          errorMessage: e.message,
          status: FormzSubmissionStatus.failure,
        ),
      );
    } catch (e) {
      logger.e(e);
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
    }
  }
}
