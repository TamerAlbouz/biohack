import 'package:backend/backend.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:formz_inputs/formz_inputs.dart';
import 'package:p_logger/p_logger.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(
      this._authenticationRepository, this._encryptionRepository, this.crypto)
      : super(const LoginState());

  final IAuthenticationRepository _authenticationRepository;
  final IEncryptionRepository _encryptionRepository;
  final ISecureEncryptionStorage crypto;

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
        email: state.signInEmail.value,
        password: state.signInPassword.value,
      );

      emit(state.copyWith(status: FormzSubmissionStatus.success));

      // TODO: Run this in an isolate
      // run this process in the background in an isolate
      // to avoid blocking the main thread
      PrivateKeyEncryptionResult? encryptedData =
          await _encryptionRepository.getEncryptedData(
        _authenticationRepository.currentUser.uid,
      );

      if (encryptedData == null) {
        encryptedData =
            await crypto.generateAndSaveKeys(state.signInPassword.value);

        await _encryptionRepository.addEncryptionData(
          _authenticationRepository.currentUser.uid,
          encryptedData,
        );
        return;
      } else {
        await crypto.decryptAndSaveKey(
          encryptedData,
          state.signInPassword.value,
        );
      }

      logger.i('User logged in with email and password');
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

  // Future<void> logInWithGoogle() async {
  //   emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
  //   try {
  //     await _authenticationRepository.logInWithGoogle();
  //     emit(state.copyWith(status: FormzSubmissionStatus.success));
  //     logger.i('User logged in with Google');
  //   } on FirebaseException catch (e) {
  //     await _authenticationRepository.logOut();
  //     logger.e(e.message);
  //     emit(
  //       state.copyWith(
  //         errorMessage: e.message,
  //         status: FormzSubmissionStatus.failure,
  //       ),
  //     );
  //   } on LogInWithGoogleFailure catch (e) {
  //     logger.e(e.message);
  //     emit(
  //       state.copyWith(
  //         errorMessage: e.message,
  //         status: FormzSubmissionStatus.failure,
  //       ),
  //     );
  //   } catch (e) {
  //     await _authenticationRepository.logOut();
  //     logger.e(e);
  //     emit(state.copyWith(status: FormzSubmissionStatus.failure));
  //   }
  // }

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

      emit(state.copyWith(status: FormzSubmissionStatus.success));

      // TODO: Run this in an isolate
      final encryptionData =
          await crypto.generateAndSaveKeys(state.signUpPassword.value);

      await _encryptionRepository.addEncryptionData(
        _authenticationRepository.currentUser.uid,
        encryptionData,
      );

      logger.i('User signed up successfully');
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
