import 'dart:convert';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:medtalk/backend/authentication/exceptions/auth_exception.dart';
import 'package:medtalk/backend/authentication/interfaces/auth_interface.dart';
import 'package:medtalk/backend/encryption/exceptions/encryption_exception.dart';
import 'package:medtalk/backend/encryption/interfaces/crypto_interface.dart';
import 'package:medtalk/backend/encryption/interfaces/encryption_interface.dart';
import 'package:medtalk/backend/encryption/models/private_key_decryption_result.dart';
import 'package:medtalk/backend/secure_storage/interfaces/secure_storage_interface.dart';
import 'package:medtalk/formz_inputs/login/email.dart';
import 'package:medtalk/formz_inputs/login/password.dart';

part 'login_event.dart';
part 'login_state.dart';

@injectable
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc(this._authenticationRepository, this._encryptionRepository,
      this._secureStorageRepository, this._crypto, this.logger)
      : super(const LoginState()) {
    on<SignInEmailChanged>(_signInEmailChanged);
    on<SignInPasswordChanged>(_signInPasswordChanged);
    on<LogInWithCredentials>(_logInWithCredentials);
    on<LogInAnonymously>(_logInAnonymously);
    on<ResetStatus>(_resetStatus);
  }

  final IAuthenticationRepository _authenticationRepository;
  final IEncryptionRepository _encryptionRepository;
  final ISecureStorageRepository _secureStorageRepository;
  final ICryptoRepository _crypto;
  final Logger logger;

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

  Future<void> _logInWithCredentials(
      LogInWithCredentials event, Emitter<LoginState> emit) async {
    if (!state.isValid) return;
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await _authenticationRepository.logInWithEmailAndPassword(
        email: state.signInEmail.value,
        password: state.signInPassword.value,
      );

      // if email is not verified delete the user
      if (!await _authenticationRepository.isEmailVerified()) {
        await _authenticationRepository.deleteUser();
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: 'Email not verified. Please sign up again',
        ));
        return;
      }

      final encryptedData = await _encryptionRepository
          .getEncryptedData(_authenticationRepository.currentUser.uid);

      logger.i('Decrypting private key');

      // Step 1: Generate pbkdfKey using the random salt stored in DB and user's password
      logger.i('Step 1: Generating PBKDF key');
      Uint8List pbkdfKey = await _crypto.generateKey(
        state.signInPassword.value,
        encryptedData![0].randomSaltOne,
      );

      // Step 2: Decrypt private key using the pbkdfKey generated above
      // and the second random slat stored in DB
      logger.i('Step 2: Decrypting private key');
      final Uint8List decryptedPrivateKey = _crypto.symmetricDecrypt(
        pbkdfKey,
        Uint8List.fromList(encryptedData[0].randomSaltTwo.codeUnits),
        Uint8List.fromList(encryptedData[0].encryptedPrivateKey.codeUnits),
      );

      final PrivateKeyDecryptionResult result = PrivateKeyDecryptionResult(
        publicKey: encryptedData[0].publicKey,
        privateKey: String.fromCharCodes(decryptedPrivateKey),
        randomSaltOne: encryptedData[0].randomSaltOne,
        randomSaltTwo: encryptedData[0].randomSaltTwo,
      );

      // Step 3: Save the private key in secure storage
      logger.i('Step 3: Saving private key in secure storage');
      await _secureStorageRepository.write(
          'rsaKeys', jsonEncode(result.toJson()));

      logger.i('Private key decrypted and saved');

      emit(state.copyWith(
        status: FormzSubmissionStatus.success,
      ));
    } on LogInWithEmailAndPasswordFailure catch (e) {
      logger.e(e.message);
      emit(
        state.copyWith(
          errorMessage: e.message,
          status: FormzSubmissionStatus.failure,
        ),
      );
    } on EncryptionException catch (e) {
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

  void _resetStatus(ResetStatus event, Emitter<LoginState> emit) {
    logger.i('Resetting status');
    emit(state.copyWith(
        status: FormzSubmissionStatus.initial, errorMessage: null));
  }
}
