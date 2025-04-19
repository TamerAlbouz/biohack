import 'dart:convert';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:crypton/crypton.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:formz/formz.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:medtalk/backend/authentication/enums/role.dart';
import 'package:medtalk/backend/authentication/interfaces/auth_interface.dart';
import 'package:medtalk/backend/doctor/interfaces/doctor_interface.dart';
import 'package:medtalk/backend/doctor/models/doctor.dart';
import 'package:medtalk/backend/encryption/interfaces/crypto_interface.dart';
import 'package:medtalk/backend/encryption/interfaces/encryption_interface.dart';
import 'package:medtalk/backend/encryption/models/private_key_decryption_result.dart';
import 'package:medtalk/backend/encryption/models/private_key_encryption_result.dart';
import 'package:medtalk/backend/patient/interfaces/patient_interface.dart';
import 'package:medtalk/backend/secure_storage/interfaces/secure_storage_interface.dart';
import 'package:medtalk/backend/storage/interfaces/storage_interface.dart';
import 'package:medtalk/formz_inputs/intro/patient/date_of_birth.dart';
import 'package:medtalk/formz_inputs/intro/patient/full_name.dart';
import 'package:medtalk/formz_inputs/intro/patient/sex.dart';
import 'package:medtalk/formz_inputs/login/email.dart';
import 'package:medtalk/formz_inputs/login/password.dart';

part 'signup_doctor_event.dart';
part 'signup_doctor_state.dart';

@injectable
class SignUpDoctorBloc extends Bloc<SignUpDoctorEvent, SignUpDoctorState> {
  final IDoctorRepository _doctorRepository;
  final IPatientRepository _doctorPatientRepository;
  final ICryptoRepository _crypto;
  final IAuthenticationRepository _authenticationRepository;
  final IEncryptionRepository _encryptionRepository;
  final ISecureStorageRepository _secureStorageRepository;
  final IStorageRepository _storageRepository;
  final Logger logger;

  SignUpDoctorBloc(
    this._crypto,
    this._authenticationRepository,
    this._encryptionRepository,
    this._doctorRepository,
    this._doctorPatientRepository,
    this._secureStorageRepository,
    this._storageRepository,
    this.logger,
  ) : super(const SignUpDoctorState()) {
    on<SignUpEmailChanged>(_onEmailChanged);
    on<SignUpPasswordChanged>(_onPasswordChanged);
    on<SignUpConfirmPasswordChanged>(_onConfirmPasswordChanged);
    on<FullNameChanged>(_onFullNameChanged);
    on<DateOfBirthChanged>(_onDateOfBirthChanged);
    on<SexChanged>(_onSexChanged);
    on<PreviousNameChanged>(_onPreviousNameChanged);
    on<LicenseTypeChanged>(_onLicenseTypeChanged);
    on<LicenseNumberChanged>(_onLicenseNumberChanged);
    on<LocationChanged>(_onLocationChanged);
    on<ZoneChanged>(_onZoneChanged);
    on<AtlanticRegistryChanged>(_onAtlanticRegistryChanged);
    on<RegistryHomeChanged>(_onRegistryHomeChanged);
    on<RegistrantTypeChanged>(_onRegistrantTypeChanged);
    on<SpecialtyChanged>(_onSpecialtyChanged);
    on<GovernmentIdUploaded>(_onGovernmentIdUploaded);
    on<MedicalLicenseUploaded>(_onMedicalLicenseUploaded);
    on<TermsAcceptedChanged>(_onTermsAcceptedChanged);
    on<NextStep>(_onNextStep);
    on<PreviousStep>(_onPreviousStep);
    on<SubmitSignUp>(_onSubmitSignUp);
    on<CheckEmailVerification>(_onCheckEmailVerification);
    on<GenerateKeys>(_onGenerateKeys);
    on<ResendVerificationEmail>(_onResendVerificationEmail);
    on<RequestSubscription>(_onRequestSubscription);
    on<ResetStatus>(_onResetStatus);
    on<CheckEmailExists>(_onCheckEmailExists);
  }

  // 2. Add this method to handle the event in the SignUpDoctorBloc:
  Future<void> _onCheckEmailExists(
      CheckEmailExists event, Emitter<SignUpDoctorState> emit) async {
    try {
      logger.i('Checking if email exists: ${event.email}');
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

      // Check if email exists using authentication repository
      final emailExists = await _doctorRepository.checkEmailExists(event.email);

      if (emailExists) {
        // Email already exists, show error
        logger.w('Email already exists: ${event.email}');
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage:
              'Email is already registered. Please use a different email or login.',
        ));
      } else {
        // Email doesn't exist, proceed to next step
        logger.i('Email is available, proceeding to next step');
        emit(state.copyWith(
          status: FormzSubmissionStatus.initial,
          currentStep: state.currentStep + 1,
        ));
      }
    } catch (e) {
      logger.e('Error checking if email exists: $e');
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Error checking email: $e',
      ));
    }
  }

  void _onRequestSubscription(
      RequestSubscription event, Emitter<SignUpDoctorState> emit) {
    logger.i('Requesting subscription...');
    emit(state.copyWith(
        status: FormzSubmissionStatus.success, requestSubscription: true));
  }

  Future<void> _onResendVerificationEmail(
      ResendVerificationEmail event, Emitter<SignUpDoctorState> emit) async {
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
      DateOfBirthChanged event, Emitter<SignUpDoctorState> emit) {
    logger.i('Date of birth changed to: ${event.dateOfBirth}');
    final dateOfBirth = DateOfBirth.dirty(event.dateOfBirth);
    emit(state.copyWith(
      dateOfBirth: dateOfBirth,
      isPersonalDetailsValid: _validatePersonalDetails(
          state.sex, state.licenseType, state.licenseNumber, dateOfBirth),
    ));
  }

  void _onSexChanged(SexChanged event, Emitter<SignUpDoctorState> emit) {
    logger.i("Sex changed to: ${event.sex}");
    final sex = Sex.dirty(event.sex);
    emit(state.copyWith(
      sex: sex,
      isPersonalDetailsValid: _validatePersonalDetails(
          sex, state.licenseType, state.licenseNumber, state.dateOfBirth),
    ));
  }

  void _onFullNameChanged(
      FullNameChanged event, Emitter<SignUpDoctorState> emit) {
    logger.i('Full name changed to: ${event.fullName}');
    final fullName = FullName.dirty(event.fullName);
    emit(state.copyWith(
      fullName: fullName,
      isBasicInfoValid: _validateBasicInfo(state.signUpEmail, fullName),
    ));
  }

  void _onEmailChanged(
      SignUpEmailChanged event, Emitter<SignUpDoctorState> emit) {
    logger.i('Email changed to: ${event.email}');
    final email = Email.dirty(event.email);
    emit(state.copyWith(
      signUpEmail: email,
      isBasicInfoValid: _validateBasicInfo(email, state.fullName),
    ));
  }

  void _onPasswordChanged(
      SignUpPasswordChanged event, Emitter<SignUpDoctorState> emit) {
    logger.i('Password changed');
    final password = Password.dirty(event.password);
    final passwordsMatch = event.password == state.signUpConfirmPassword.value;

    if (!passwordsMatch) {
      logger.w('Passwords do not match');
    }

    emit(state.copyWith(
      signUpPassword: password,
      isBasicInfoValid: passwordsMatch &&
          _validateBasicInfo(
            state.signUpEmail,
            state.fullName,
          ),
    ));
  }

  void _onConfirmPasswordChanged(
      SignUpConfirmPasswordChanged event, Emitter<SignUpDoctorState> emit) {
    logger.i('Confirm password changed');
    final confirmPassword = Password.dirty(event.confirmPassword);
    final passwordsMatch = event.confirmPassword == state.signUpPassword.value;

    if (!passwordsMatch) {
      logger.w('Confirm password does not match the entered password');
    }

    emit(state.copyWith(
      signUpConfirmPassword: confirmPassword,
      isBasicInfoValid: passwordsMatch &&
          _validateBasicInfo(
            state.signUpEmail,
            state.fullName,
          ),
    ));
  }

  void _onPreviousNameChanged(
      PreviousNameChanged event, Emitter<SignUpDoctorState> emit) {
    logger.i('Previous name changed to: ${event.previousName}');
    emit(state.copyWith(
      previousName: event.previousName,
    ));
  }

  void _onLicenseTypeChanged(
      LicenseTypeChanged event, Emitter<SignUpDoctorState> emit) {
    logger.i('License type changed to: ${event.licenseType}');
    emit(state.copyWith(
      licenseType: event.licenseType,
      isPersonalDetailsValid: _validatePersonalDetails(
          state.sex, event.licenseType, state.licenseNumber, state.dateOfBirth),
    ));
  }

  void _onLicenseNumberChanged(
      LicenseNumberChanged event, Emitter<SignUpDoctorState> emit) {
    logger.i('License number changed to: ${event.licenseNumber}');
    emit(state.copyWith(
      licenseNumber: event.licenseNumber,
      isPersonalDetailsValid: _validatePersonalDetails(
          state.sex, state.licenseType, event.licenseNumber, state.dateOfBirth),
    ));
  }

  void _onLocationChanged(
      LocationChanged event, Emitter<SignUpDoctorState> emit) {
    logger.i('Location changed to: ${event.location}');
    emit(state.copyWith(
      location: event.location,
      isLocationValid: _validateLocation(
        event.location,
        state.zone,
        state.isAtlanticRegistry,
        state.registryHomeJurisdiction,
      ),
    ));
  }

  void _onZoneChanged(ZoneChanged event, Emitter<SignUpDoctorState> emit) {
    logger.i('Zone changed to: ${event.zone}');
    emit(state.copyWith(
      zone: event.zone,
      isLocationValid: _validateLocation(
        state.location,
        event.zone,
        state.isAtlanticRegistry,
        state.registryHomeJurisdiction,
      ),
    ));
  }

  void _onAtlanticRegistryChanged(
      AtlanticRegistryChanged event, Emitter<SignUpDoctorState> emit) {
    logger.i('Atlantic registry changed to: ${event.isAtlanticRegistry}');
    // If Atlantic Registry is set to "No", clear registry home jurisdiction
    final registryHome =
        event.isAtlanticRegistry == 'No' ? '' : state.registryHomeJurisdiction;
    emit(state.copyWith(
      isAtlanticRegistry: event.isAtlanticRegistry,
      registryHomeJurisdiction: registryHome,
      isLocationValid: _validateLocation(
        state.location,
        state.zone,
        event.isAtlanticRegistry,
        registryHome,
      ),
    ));
  }

  void _onRegistryHomeChanged(
      RegistryHomeChanged event, Emitter<SignUpDoctorState> emit) {
    logger.i('Registry home changed to: ${event.registryHome}');
    emit(state.copyWith(
      registryHomeJurisdiction: event.registryHome,
      isLocationValid: _validateLocation(
        state.location,
        state.zone,
        state.isAtlanticRegistry,
        event.registryHome,
      ),
    ));
  }

  void _onRegistrantTypeChanged(
      RegistrantTypeChanged event, Emitter<SignUpDoctorState> emit) {
    logger.i('Registrant type changed to: ${event.registrantType}');
    emit(state.copyWith(
      registrantType: event.registrantType,
      isSpecialtiesValid: _validateSpecialties(
        event.registrantType,
        state.specialty,
      ),
    ));
  }

  void _onSpecialtyChanged(
      SpecialtyChanged event, Emitter<SignUpDoctorState> emit) {
    logger.i('Specialty changed to: ${event.specialty}');
    emit(state.copyWith(
      specialty: event.specialty,
      isSpecialtiesValid: _validateSpecialties(
        state.registrantType,
        event.specialty,
      ),
    ));
  }

  Future<void> _onGovernmentIdUploaded(
      GovernmentIdUploaded event, Emitter<SignUpDoctorState> emit) async {
    try {
      logger.i('Government ID file uploaded');
      emit(state.copyWith(
        governmentIdFile: event.file,
        isDocumentsValid: _validateDocuments(
          event.file,
          state.medicalLicenseFile,
          state.termsAccepted,
        ),
      ));
    } catch (e) {
      logger.e('Error uploading government ID: $e');
      emit(state.copyWith(
        errorMessage: 'Error uploading government ID: $e',
      ));
    }
  }

  Future<void> _onMedicalLicenseUploaded(
      MedicalLicenseUploaded event, Emitter<SignUpDoctorState> emit) async {
    try {
      logger.i('Medical license file uploaded');
      emit(state.copyWith(
        medicalLicenseFile: event.file,
        isDocumentsValid: _validateDocuments(
          state.governmentIdFile,
          event.file,
          state.termsAccepted,
        ),
      ));
    } catch (e) {
      logger.e('Error uploading medical license: $e');
      emit(state.copyWith(
        errorMessage: 'Error uploading medical license: $e',
      ));
    }
  }

  void _onTermsAcceptedChanged(
      TermsAcceptedChanged event, Emitter<SignUpDoctorState> emit) {
    logger.i('Terms accepted changed to: ${event.accepted}');
    emit(state.copyWith(
      termsAccepted: event.accepted,
      isDocumentsValid: _validateDocuments(
        state.governmentIdFile,
        state.medicalLicenseFile,
        event.accepted,
      ),
    ));
  }

  void _onNextStep(NextStep event, Emitter<SignUpDoctorState> emit) {
    if (state.currentStep < 4) {
      emit(state.copyWith(
        currentStep: state.currentStep + 1,
      ));
    }
  }

  void _onPreviousStep(PreviousStep event, Emitter<SignUpDoctorState> emit) {
    if (state.currentStep > 0) {
      emit(state.copyWith(
        currentStep: state.currentStep - 1,
      ));
    }
  }

  Future<void> _onCheckEmailVerification(
      CheckEmailVerification event, Emitter<SignUpDoctorState> emit) async {
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
      GenerateKeys event, Emitter<SignUpDoctorState> emit) async {
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
      SubmitSignUp event, Emitter<SignUpDoctorState> emit) async {
    logger.i('Submitting signup...');
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      // check if user is already signed up but as a patient, if so, keep the patient, but now create a doctor
      final exists = await _doctorPatientRepository
          .checkEmailExists(state.signUpEmail.value);

      final existsPatient = await _doctorPatientRepository
          .checkEmailExists(state.signUpEmail.value);

      if (!exists && !existsPatient) {
        await _authenticationRepository.createUserWithEmailAndPassword(
          email: state.signUpEmail.value,
          password: state.signUpPassword.value,
        );
      } else {
        await _authenticationRepository.logInWithEmailAndPassword(
          email: state.signUpEmail.value,
          password: state.signUpPassword.value,
        );
      }

      logger.i('User signup successful. Uploading documents...');

      String govIdUrl = '';
      String medLicenseUrl = '';

      if (state.governmentIdFile != null) {
        govIdUrl = await _uploadFile(state.governmentIdFile!,
            'government_id_${_authenticationRepository.currentUser.uid}');
      }

      if (state.medicalLicenseFile != null) {
        medLicenseUrl = await _uploadFile(state.medicalLicenseFile!,
            'medical_license_${_authenticationRepository.currentUser.uid}');
      }

      logger.i('Documents uploaded successfully. Creating doctor profile...');

      // Create a new doctor object
      final doctor = Doctor(
        email: state.signUpEmail.value,
        name: state.fullName.value,
        sex: state.sex.value,
        uid: _authenticationRepository.currentUser.uid,
        createdAt: DateTime.now(),
        role: Role.doctor,
        licNum: state.licenseNumber,
        govIdUrl: govIdUrl,
        medicalLicenseUrl: medLicenseUrl,
        availability: const {},
        active: false,
        previousName: state.previousName,
        licenseType: state.licenseType,
        zone: state.zone,
        location: state.location,
        isAtlanticRegistry: state.isAtlanticRegistry == 'Yes',
        registryHomeJurisdiction: state.registryHomeJurisdiction,
        registrantType: state.registrantType,
        termsAccepted: state.termsAccepted,
        specialties: state.specialty.isNotEmpty ? [state.specialty] : null,
      );

      await Future.wait([
        _doctorRepository.addDoctor(doctor),
        _authenticationRepository.updateProfile(doctor),
      ]);

      logger.i('Doctor profile created successfully');
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

  void _onResetStatus(ResetStatus event, Emitter<SignUpDoctorState> emit) {
    logger.i('Resetting form status');
    emit(state.copyWith(status: FormzSubmissionStatus.initial));
  }

  // Helper methods for validation
  bool _validateBasicInfo(Email email, FullName fullName) {
    return Formz.validate([email, fullName]);
  }

  bool _validatePersonalDetails(Sex sex, String licenseType,
      String licenseNumber, DateOfBirth dateOfBirth) {
    return sex.isValid &&
        licenseType.isNotEmpty &&
        licenseNumber.isNotEmpty &&
        dateOfBirth.isValid;
  }

  bool _validateLocation(String location, String zone,
      String isAtlanticRegistry, String registryHome) {
    if (location.isEmpty || zone.isEmpty || isAtlanticRegistry.isEmpty) {
      return false;
    }

    // If Atlantic Registry is "Yes", registry home must be selected
    if (isAtlanticRegistry == 'Yes' && registryHome.isEmpty) {
      return false;
    }

    return true;
  }

  bool _validateSpecialties(String registrantType, String specialty) {
    return registrantType.isNotEmpty && specialty.isNotEmpty;
  }

  bool _validateDocuments(
      PlatformFile? govId, PlatformFile? medLicense, bool termsAccepted) {
    return govId != null && medLicense != null && termsAccepted;
  }

  // Helper method for file upload
  Future<String> _uploadFile(PlatformFile file, String path) async {
    try {
      final fileBytes = file.bytes;
      if (fileBytes == null) {
        throw Exception('File bytes are null');
      }

      final fileExt = file.extension ?? 'file';
      final fileName = '$path.$fileExt';

      final url = await _storageRepository.uploadBytes(
        fileBytes,
        fileName,
        contentType: 'application/$fileExt',
      );

      return url;
    } catch (e) {
      logger.e('Error uploading file: $e');
      throw Exception('Failed to upload file: $e');
    }
  }
}
