import 'package:authentication/authentication.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:formz_inputs/formz_inputs.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._authenticationRepository) : super(const LoginState());

  final AuthenticationRepository _authenticationRepository;

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
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } on LogInWithEmailAndPasswordFailure catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.message,
          status: FormzSubmissionStatus.failure,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
    }
  }

  Future<void> logInWithGoogle() async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await _authenticationRepository.logInWithGoogle();
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } on LogInWithGoogleFailure catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.message,
          status: FormzSubmissionStatus.failure,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
    }
  }

  Future<void> logInAnonymously() async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await _authenticationRepository.logInAnonymously();
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } on LogInAnonymouslyFailure {
      emit(
        state.copyWith(
          errorMessage: 'An unknown error occurred',
          status: FormzSubmissionStatus.failure,
        ),
      );
    } catch (_) {
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
    } on SignUpWithEmailAndPasswordFailure catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.message,
          status: FormzSubmissionStatus.failure,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
    }
  }

  void resetStatus() {
    emit(state.copyWith(
        status: FormzSubmissionStatus.initial, errorMessage: null));
  }
}
