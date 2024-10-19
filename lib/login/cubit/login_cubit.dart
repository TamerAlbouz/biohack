import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase/firebase.dart';
import 'package:formz/formz.dart';
import 'package:formz_inputs/formz_inputs.dart';
import 'package:models/models.dart';
import 'package:p_logger/p_logger.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._authenticationRepository, this._patientRepository)
      : super(const LoginState());

  final IPatientInterface _patientRepository;
  final IAuthenticationRepository _authenticationRepository;

  void signInEmailChanged(String value) {
    final email = Email.dirty(value);
    emit(
      state.copyWith(
        signInEmail: email,
        isValid: Formz.validate([email, state.signInPassword]),
      ),
    );
  }

  void signInPasswordChanged(String value) {
    final password = Password.dirty(value);
    emit(
      state.copyWith(
        signInPassword: password,
        isValid: Formz.validate([state.signInEmail, password]),
      ),
    );
  }

  void signUpEmailChanged(String value) {
    final email = Email.dirty(value);
    emit(
      state.copyWith(
        signUpEmail: email,
        isValid: Formz.validate([email, state.signUpPassword]),
      ),
    );
  }

  void signUpPasswordChanged(String value) {
    final password = Password.dirty(value);

    // also check if the password and confirm password match
    if (state.signUpConfirmPassword != value) {
      emit(
        state.copyWith(
          signUpPassword: password,
          isValid: false,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        signUpPassword: password,
        isValid: Formz.validate([state.signUpEmail, password]),
      ),
    );
  }

  void signUpConfirmPasswordChanged(String value) {
    // also check if the password and confirm password match
    if (state.signUpPassword.value != value) {
      emit(
        state.copyWith(
          signUpConfirmPassword: value,
          isValid: false,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        signUpConfirmPassword: value,
        isValid: Formz.validate([
          state.signUpEmail,
          state.signUpPassword,
        ]),
      ),
    );
  }

  Future<void> logInWithCredentials() async {
    if (!state.isValid) return;
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await _authenticationRepository.logInWithEmailAndPassword(
        email: state.signInPassword.value,
        password: state.signInPassword.value,
      );
      logger.i('User logged in with email and password');
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } on LogInWithEmailAndPasswordFailure catch (e) {
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

  Future<void> logInWithGoogle() async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await _authenticationRepository.logInWithGoogle();

      // check if user exists
      final authUser = _authenticationRepository.currentUser;

      final Patient? user = await _patientRepository.getPatient(authUser.uid);

      if (user == null) {
        // create user
        final Patient user = Patient(
          email: authUser.email,
          uid: authUser.uid,
          name: authUser.name,
          role: Role.patient,
          profilePictureUrl: authUser.profilePictureUrl,
          createdAt: DateTime.now(),
        );

        _patientRepository.addPatient(user);
        logger.i('Patient created successfully');
      }

      emit(state.copyWith(status: FormzSubmissionStatus.success));
      logger.i('User logged in with Google');
    } on FirebaseException catch (e) {
      await _authenticationRepository.logOut();
      logger.e(e.message);
      emit(
        state.copyWith(
          errorMessage: e.message,
          status: FormzSubmissionStatus.failure,
        ),
      );
    } on LogInWithGoogleFailure catch (e) {
      await _authenticationRepository.logOut();
      logger.e(e.message);
      emit(
        state.copyWith(
          errorMessage: e.message,
          status: FormzSubmissionStatus.failure,
        ),
      );
    } catch (e) {
      await _authenticationRepository.logOut();
      logger.e(e);
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
    }
  }

  Future<void> logInAnonymously() async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await _authenticationRepository.logInAnonymously();
      logger.i('User logged in anonymously');
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } on LogInAnonymouslyFailure {
      emit(
        state.copyWith(
          errorMessage: 'An unknown error occurred',
          status: FormzSubmissionStatus.failure,
        ),
      );
    } catch (e) {
      logger.e(e);
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
    }
  }

  Future<void> signUpWithCredential() async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await _authenticationRepository.signUp(
        email: state.signUpEmail.value,
        password: state.signUpPassword.value,
      );
      logger.i('User signed up successfully');

      final authUser = _authenticationRepository.currentUser;
      // create user
      final Patient user = Patient(
        email: authUser.email,
        uid: authUser.uid,
        name: authUser.name,
        role: Role.patient,
        profilePictureUrl: authUser.profilePictureUrl,
        createdAt: DateTime.now(),
      );

      _patientRepository.addPatient(user);
      logger.i('Patient created successfully');
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } on SignUpWithEmailAndPasswordFailure catch (e) {
      logger.e(e.message);
      emit(
        state.copyWith(
          errorMessage: e.message,
          status: FormzSubmissionStatus.failure,
        ),
      );
    } on FirebaseException catch (e) {
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

  void resetStatus() {
    logger.i('Resetting status');
    emit(state.copyWith(
        status: FormzSubmissionStatus.initial, errorMessage: null));
  }
}
