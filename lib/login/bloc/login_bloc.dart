import 'package:backend/backend.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:formz_inputs/formz_inputs.dart';
import 'package:p_logger/p_logger.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc(
    this._authenticationRepository,
    this._encryptionRepository,
    this._crypto,
  ) : super(const LoginState()) {
    on<SignInEmailChanged>(_signInEmailChanged);
    on<SignInPasswordChanged>(_signInPasswordChanged);
    on<SignUpEmailChanged>(_signUpEmailChanged);
    on<SignUpPasswordChanged>(_signUpPasswordChanged);
    on<SignUpConfirmPasswordChanged>(_signUpConfirmPasswordChanged);
    on<LogInWithCredentials>(_logInWithCredentials);
    on<LogInAnonymously>(_logInAnonymously);
    on<CheckEmailVerification>(_checkEmailVerification);
    on<ResendVerificationEmail>(_resendVerificationEmail);
    on<SignUpWithCredential>(_signUpWithCredential);
    on<ResetStatus>(_resetStatus);
  }

  final IAuthenticationRepository _authenticationRepository;
  final IEncryptionRepository _encryptionRepository;
  final ISecureEncryptionStorage _crypto;

  void _signInEmailChanged(SignInEmailChanged event, Emitter<LoginState> emit) {
    final email = Email.dirty(event.email);
    emit(
      state.copyWith(
        signInEmail: email,
        isValid: Formz.validate([email, state.signInPassword]),
      ),
    );
  }

  void _signInPasswordChanged(
      SignInPasswordChanged event, Emitter<LoginState> emit) {
    final password = Password.dirty(event.password);
    emit(
      state.copyWith(
        signInPassword: password,
        isValid: Formz.validate([state.signInEmail, password]),
      ),
    );
  }

  void _signUpEmailChanged(SignUpEmailChanged event, Emitter<LoginState> emit) {
    final email = Email.dirty(event.email);
    emit(
      state.copyWith(
        signUpEmail: email,
        isValid: Formz.validate([email, state.signUpPassword]),
      ),
    );
  }

  void _signUpPasswordChanged(
      SignUpPasswordChanged event, Emitter<LoginState> emit) {
    final password = Password.dirty(event.password);

    // also check if the password and confirm password match
    if (state.signUpConfirmPassword != event.password) {
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

  void _signUpConfirmPasswordChanged(
      SignUpConfirmPasswordChanged event, Emitter<LoginState> emit) {
    // also check if the password and confirm password match
    if (state.signUpPassword.value != event.password) {
      emit(
        state.copyWith(
          signUpConfirmPassword: event.password,
          passwordMatch: false,
          isValid: false,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        signUpConfirmPassword: event.password,
        passwordMatch: true,
        isValid: Formz.validate([
          state.signUpEmail,
          state.signUpPassword,
        ]),
      ),
    );
  }

  Future<void> _logInWithCredentials(
      LogInWithCredentials event, Emitter<LoginState> emit) async {
    if (!state.isValid) return;
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await _authenticationRepository.logInWithEmailAndPassword(
        email: state.signInEmail.value,
        password: state.signInPassword.value,
      );

      // check if the user is verified
      if (await _authenticationRepository.isEmailVerified()) {
        // get keys from db
        final encryptedData = await _encryptionRepository
            .getEncryptedData(_authenticationRepository.currentUser.uid);

        await _crypto.decryptAndSaveKey(
          encryptedData!,
          state.signInPassword.value,
        );

        emit(state.copyWith(
          status: FormzSubmissionStatus.success,
          requiresEmailVerification: false,
        ));
      } else {
        emit(state.copyWith(
          status: FormzSubmissionStatus.success,
          requiresEmailVerification: true,
        ));
      }
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

  Future<void> _logInAnonymously(
      LogInAnonymously event, Emitter<LoginState> emit) async {
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

  Future<void> _checkEmailVerification(
      CheckEmailVerification event, Emitter<LoginState> emit) async {
    try {
      logger.i('Checking email verification');
      final isVerified = await _authenticationRepository.isEmailVerified();
      if (isVerified) {
        logger.w('Email is verified. Generating Keys...');
        PrivateKeyEncryptionResult keys = await _crypto.generateNewKeys(
            state.signUpPassword.value == ""
                ? state.signInPassword.value
                : state.signUpPassword.value);

        // delete existing key
        await _crypto.deleteKeys();

        await _crypto.decryptAndSaveKey(
            keys,
            state.signUpPassword.value == ""
                ? state.signInPassword.value
                : state.signUpPassword.value);

        await _encryptionRepository.addEncryptionData(
          _authenticationRepository.currentUser.uid,
          keys,
        );

        logger.w('Keys generated');
        emit(state.copyWith(
          status: FormzSubmissionStatus.success,
          requiresEmailVerification: false,
        ));
      } else {
        emit(state.copyWith(
          requiresEmailVerification: true,
        ));
      }
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> _resendVerificationEmail(
      ResendVerificationEmail event, Emitter<LoginState> emit) async {
    try {
      await _authenticationRepository.sendEmailVerification();
      emit(state.copyWith(
        status: FormzSubmissionStatus.success,
        errorMessage: 'Verification email resent successfully',
      ));
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> _signUpWithCredential(
      SignUpWithCredential event, Emitter<LoginState> emit) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await _authenticationRepository.signUp(
        email: state.signUpEmail.value,
        password: state.signUpPassword.value,
      );

      emit(state.copyWith(
        requiresEmailVerification: true,
        isSignUp: true,
      ));
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

  void _resetStatus(ResetStatus event, Emitter<LoginState> emit) {
    logger.i('Resetting status');
    emit(state.copyWith(
        status: FormzSubmissionStatus.initial, errorMessage: null));
  }
}
