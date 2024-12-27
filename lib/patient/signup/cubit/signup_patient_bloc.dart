import 'dart:convert';
import 'dart:typed_data';

import 'package:backend/backend.dart';
import 'package:bloc/bloc.dart';
import 'package:crypton/crypton.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:formz_inputs/formz_inputs.dart';
import 'package:intl/intl.dart';
import 'package:p_logger/p_logger.dart';

part 'signup_patient_event.dart';
part 'signup_patient_state.dart';

class SignUpPatientBloc extends Bloc<SignUpPatientEvent, SignUpPatientState> {
  final IPatientRepository _patientRepository;
  final ICryptoRepository _crypto;
  final IAuthenticationRepository _authenticationRepository;
  final IEncryptionRepository _encryptionRepository;
  final ISecureStorageRepository _secureStorageRepository;

  SignUpPatientBloc(
    this._crypto,
    this._authenticationRepository,
    this._encryptionRepository,
    this._patientRepository,
    this._secureStorageRepository,
  ) : super(const SignUpPatientState()) {
    on<SignUpEmailChanged>(_onEmailChanged);
    on<SignUpPasswordChanged>(_onPasswordChanged);
    on<SignUpConfirmPasswordChanged>(_onConfirmPasswordChanged);
    on<FullNameChanged>(_onFullNameChanged);
    on<DateOfBirthChanged>(_onDateOfBirthChanged);
    on<SexChanged>(_onSexChanged);
    on<SubmitSignUp>(_onSubmitSignUp);
    on<CheckEmailVerification>(_onCheckEmailVerification);
    on<GenerateKeys>(_onGenerateKeys);
    on<ResendVerificationEmail>(_onResendVerificationEmail);
    on<RequestSubscription>(_onRequestSubscription);
    on<ResetStatus>(_onResetStatus);
  }

  void _onRequestSubscription(
      RequestSubscription event, Emitter<SignUpPatientState> emit) {
    logger.i('Requesting subscription...');
    emit(state.copyWith(
        status: FormzSubmissionStatus.success, requestSubscription: true));
  }

  Future<void> _onResendVerificationEmail(
      ResendVerificationEmail event, Emitter<SignUpPatientState> emit) async {
    try {
      logger.i('Resending verification email...');
      await _authenticationRepository.sendEmailVerification();
      emit(state.copyWith(errorMessage: null));
    } catch (e) {
      logger.e('Error resending verification email: $e');
      emit(state.copyWith(
          errorMessage: e.toString(), status: FormzSubmissionStatus.failure));
    }
  }

  void _onDateOfBirthChanged(
      DateOfBirthChanged event, Emitter<SignUpPatientState> emit) {
    logger.i('Date of birth changed to: ${event.dateOfBirth}');
    final dateOfBirth = DateOfBirth.dirty(event.dateOfBirth);
    emit(state.copyWith(
      dateOfBirth: dateOfBirth,
      isValid: Formz.validate([
        state.signUpEmail,
        state.signUpPassword,
        state.fullName,
        dateOfBirth,
        state.sex,
      ]),
    ));
  }

  void _onSexChanged(SexChanged event, Emitter<SignUpPatientState> emit) {
    logger.i("Sex changed to: ${event.sex}");
    final sex = Sex.dirty(event.sex);
    emit(state.copyWith(
      sex: sex,
      isValid: Formz.validate([
        state.signUpEmail,
        state.signUpPassword,
        state.fullName,
        state.dateOfBirth,
        sex,
      ]),
    ));
  }

  void _onFullNameChanged(
      FullNameChanged event, Emitter<SignUpPatientState> emit) {
    logger.i('Full name changed to: ${event.fullName}');
    final fullName = FullName.dirty(event.fullName);
    emit(state.copyWith(
      fullName: fullName,
      isValid: Formz.validate([
        state.signUpEmail,
        state.signUpPassword,
        fullName,
        state.dateOfBirth,
        state.sex,
      ]),
    ));
  }

  void _onEmailChanged(
      SignUpEmailChanged event, Emitter<SignUpPatientState> emit) {
    logger.i('Email changed to: ${event.email}');
    final email = Email.dirty(event.email);
    emit(state.copyWith(
      signUpEmail: email,
      isValid: Formz.validate([
        email,
        state.signUpPassword,
        state.fullName,
        state.dateOfBirth,
        state.sex,
      ]),
    ));
  }

  void _onPasswordChanged(
      SignUpPasswordChanged event, Emitter<SignUpPatientState> emit) {
    logger.i('Password changed');
    final password = Password.dirty(event.password);
    final passwordsMatch = event.password == state.signUpConfirmPassword.value;

    if (!passwordsMatch) {
      logger.w('Passwords do not match');
    }

    emit(state.copyWith(
      signUpPassword: password,
      isValid: passwordsMatch &&
          Formz.validate([
            state.signUpEmail,
            password,
            state.fullName,
            state.dateOfBirth,
            state.sex,
          ]),
    ));
  }

  void _onConfirmPasswordChanged(
      SignUpConfirmPasswordChanged event, Emitter<SignUpPatientState> emit) {
    logger.i('Confirm password changed');
    final confirmPassword = Password.dirty(event.confirmPassword);
    final passwordsMatch = event.confirmPassword == state.signUpPassword.value;

    if (!passwordsMatch) {
      logger.w('Confirm password does not match the entered password');
    }

    emit(state.copyWith(
      signUpConfirmPassword: confirmPassword,
      isValid: passwordsMatch &&
          Formz.validate([
            state.signUpEmail,
            state.signUpPassword,
            state.fullName,
            state.dateOfBirth,
            state.sex,
          ]),
    ));
  }

  Future<void> _onCheckEmailVerification(
      CheckEmailVerification event, Emitter<SignUpPatientState> emit) async {
    try {
      logger.i('Checking email verification...');
      final isVerified = await _authenticationRepository.isEmailVerified();
      if (isVerified) {
        logger.i('Email is verified');
        emit(state.copyWith(
          requiresEmailVerification: false,
          generateKeys: true,
        ));
      } else {
        logger.w('Email is not verified');
        emit(state.copyWith(
          requiresEmailVerification: true,
        ));
      }
    } catch (e) {
      logger.e('Error while checking email verification: $e');
      emit(state.copyWith(
          errorMessage: e.toString(),
          requiresEmailVerification: false,
          status: FormzSubmissionStatus.failure));
    }
  }

  Future<void> _onGenerateKeys(
      GenerateKeys event, Emitter<SignUpPatientState> emit) async {
    try {
      logger.i('Starting key generation process');

      // Step 1: Generate a random salt for PBKDF
      logger.i('Step 1: Generating random salt for PBKDF');
      final String randomSaltOne = _crypto.generateRandomSalt().toString();
      final String randomSaltOneRecovery =
          _crypto.generateRandomSalt().toString();

      // Step 2: Generate PBKDF key in chunks
      logger.i('Step 2: Generating PBKDF key in steps');
      Uint8List pbkdfKey = await _crypto.generateKey(
        state.signUpPassword.value,
        randomSaltOne,
      );

      Uint8List pbkdfKeyRecovery = await _crypto.generateKey(
        event.recoveryCode,
        randomSaltOneRecovery,
      );

      // Step 3: Generate RSA Key Pair
      logger.i('Step 3: Generating RSA key pair');
      final RSAKeypair keyPair = _crypto.getKeyPair();

      // Step 4: Encrypt Private Key
      logger.i('Step 4: Encrypting private key');
      final privateKeySalt = _crypto.generateRandomSalt().toString();
      final privateKeySaltRecovery = _crypto.generateRandomSalt().toString();

      final encryptedPrivateKey = _crypto.symmetricEncrypt(
        pbkdfKey,
        Uint8List.fromList(privateKeySalt.codeUnits),
        Uint8List.fromList(keyPair.privateKey.toFormattedPEM().codeUnits),
      );

      final encryptedPrivateKeyRecovery = _crypto.symmetricEncrypt(
        pbkdfKeyRecovery,
        Uint8List.fromList(privateKeySaltRecovery.codeUnits),
        Uint8List.fromList(keyPair.privateKey.toFormattedPEM().codeUnits),
      );

      // Step 5: Assemble Result
      logger.i('Step 5: Assembling encryption result');
      var result = PrivateKeyEncryptionResult(
        publicKey: keyPair.publicKey.toFormattedPEM(),
        encryptedPrivateKey: String.fromCharCodes(encryptedPrivateKey),
        randomSaltOne: randomSaltOne,
        randomSaltTwo: privateKeySalt,
      );

      var resultRecovery = PrivateKeyEncryptionResult(
        publicKey: keyPair.publicKey.toFormattedPEM(),
        encryptedPrivateKey: String.fromCharCodes(encryptedPrivateKeyRecovery),
        randomSaltOne: randomSaltOneRecovery,
        randomSaltTwo: privateKeySaltRecovery,
      );

      // Step 5.5: Decrypt key model
      logger.i('Step 5.5: Decrypting key model');
      final decryptResult = PrivateKeyDecryptionResult(
        publicKey: keyPair.publicKey.toFormattedPEM(),
        privateKey: keyPair.privateKey.toFormattedPEM(),
        randomSaltOne: randomSaltOne,
        randomSaltTwo: privateKeySalt,
      );

      // Step 6: Save the private key in secure storage
      logger.i('Step 6: Saving private key in secure storage');
      await _secureStorageRepository.write(
          'rsaKeys', jsonEncode(decryptResult.toJson()));

      // Step 7: Finalize
      logger.i('Step 7: Key generation complete');

      _encryptionRepository.addEncryptionData(
          _authenticationRepository.currentUser.uid, [result, resultRecovery]);

      logger.i('Keys generated successfully');
      emit(state.copyWith(
        generateKeys: false,
        showRecoveryCodes: true,
      ));
    } catch (e) {
      logger.e('Error generating keys: $e');
      emit(state.copyWith(
          errorMessage: e.toString(),
          generateKeys: false,
          status: FormzSubmissionStatus.failure));
    }
  }

  Future<void> _onSubmitSignUp(
      SubmitSignUp event, Emitter<SignUpPatientState> emit) async {
    logger.i('Submitting signup...');
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await _authenticationRepository.signUp(
        email: state.signUpEmail.value,
        password: state.signUpPassword.value,
      );

      logger.i('User signup successful. Creating patient profile...');
      final formatter = DateFormat('dd/MM/yyyy');
      final patient = Patient(
        email: state.signUpEmail.value,
        name: state.fullName.value,
        dateOfBirth: formatter.parse(state.dateOfBirth.value),
        sex: state.sex.value,
        uid: _authenticationRepository.currentUser.uid,
        createdAt: DateTime.now(),
        role: Role.patient,
      );

      await _patientRepository.addPatient(patient);
      _authenticationRepository.sendEmailVerification();
      logger.i('Patient profile created successfully');
      emit(state.copyWith(
          status: FormzSubmissionStatus.inProgress,
          requiresEmailVerification: true));
    } catch (e) {
      logger.e('Error during signup submission: $e');
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        requiresEmailVerification: false,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onResetStatus(ResetStatus event, Emitter<SignUpPatientState> emit) {
    logger.i('Resetting form status');
    emit(state.copyWith(status: FormzSubmissionStatus.initial));
  }
}
