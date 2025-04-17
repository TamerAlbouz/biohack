part of 'signup_doctor_bloc.dart';

final class SignUpDoctorState extends Equatable {
  const SignUpDoctorState({
    this.signUpEmail = const Email.pure(),
    this.signUpPassword = const Password.pure(),
    this.signUpConfirmPassword = const Password.pure(),
    this.fullName = const FullName.pure(),
    this.dateOfBirth = const DateOfBirth.pure(),
    this.sex = const Sex.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.generateKeys = false,
    this.requiresEmailVerification = false,
    this.errorMessage,
    this.showRecoveryCodes = false,
    this.requestSubscription = false,
    this.currentStep = 0,
    this.previousName = '',
    this.licenseType = '',
    this.licenseNumber = '',
    this.location = '',
    this.zone = '',
    this.isAtlanticRegistry = '',
    this.registryHomeJurisdiction = '',
    this.registrantType = '',
    this.specialty = '',
    this.governmentIdFile,
    this.medicalLicenseFile,
    this.termsAccepted = false,
    this.isBasicInfoValid = false,
    this.isPersonalDetailsValid = false,
    this.isLocationValid = false,
    this.isSpecialtiesValid = false,
    this.isDocumentsValid = false,
  });

  // Basic info fields
  final Email signUpEmail;
  final Password signUpPassword;
  final Password signUpConfirmPassword;
  final FullName fullName;
  final DateOfBirth dateOfBirth;
  final bool isBasicInfoValid;

  // Personal details fields
  final Sex sex;
  final String licenseType;
  final String licenseNumber;
  final String previousName;
  final bool isPersonalDetailsValid;

  // Location fields
  final String location;
  final String zone;
  final String isAtlanticRegistry;
  final String registryHomeJurisdiction;
  final bool isLocationValid;

  // Specialties fields
  final String registrantType;
  final String specialty;
  final bool isSpecialtiesValid;

  // Documents fields
  final PlatformFile? governmentIdFile;
  final PlatformFile? medicalLicenseFile;
  final bool termsAccepted;
  final bool isDocumentsValid;

  // Multi-step form state
  final int currentStep;

  // Email verification and keys
  final bool generateKeys;
  final bool showRecoveryCodes;
  final bool requiresEmailVerification;
  final FormzSubmissionStatus status;
  final String? errorMessage;
  final bool requestSubscription;

  @override
  List<Object?> get props => [
        fullName,
        dateOfBirth,
        sex,
        generateKeys,
        showRecoveryCodes,
        licenseNumber,
        licenseType,
        previousName,
        signUpEmail,
        signUpPassword,
        signUpConfirmPassword,
        requiresEmailVerification,
        status,
        errorMessage,
        requestSubscription,
        currentStep,
        location,
        zone,
        isAtlanticRegistry,
        registryHomeJurisdiction,
        registrantType,
        specialty,
        governmentIdFile,
        medicalLicenseFile,
        termsAccepted,
        isBasicInfoValid,
        isPersonalDetailsValid,
        isLocationValid,
        isSpecialtiesValid,
        isDocumentsValid,
      ];

  SignUpDoctorState copyWith({
    Email? signUpEmail,
    Password? signUpPassword,
    Password? signUpConfirmPassword,
    FullName? fullName,
    DateOfBirth? dateOfBirth,
    Sex? sex,
    String? previousName,
    String? licenseType,
    String? licenseNumber,
    String? location,
    String? zone,
    String? isAtlanticRegistry,
    String? registryHomeJurisdiction,
    String? registrantType,
    String? specialty,
    PlatformFile? governmentIdFile,
    PlatformFile? medicalLicenseFile,
    bool? termsAccepted,
    int? currentStep,
    bool? requiresEmailVerification,
    bool? showRecoveryCodes,
    bool? generateKeys,
    FormzSubmissionStatus? status,
    String? errorMessage,
    bool? requestSubscription,
    bool? isBasicInfoValid,
    bool? isPersonalDetailsValid,
    bool? isLocationValid,
    bool? isSpecialtiesValid,
    bool? isDocumentsValid,
  }) {
    return SignUpDoctorState(
      signUpEmail: signUpEmail ?? this.signUpEmail,
      signUpPassword: signUpPassword ?? this.signUpPassword,
      signUpConfirmPassword:
          signUpConfirmPassword ?? this.signUpConfirmPassword,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      sex: sex ?? this.sex,
      previousName: previousName ?? this.previousName,
      licenseType: licenseType ?? this.licenseType,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      location: location ?? this.location,
      zone: zone ?? this.zone,
      isAtlanticRegistry: isAtlanticRegistry ?? this.isAtlanticRegistry,
      registryHomeJurisdiction:
          registryHomeJurisdiction ?? this.registryHomeJurisdiction,
      registrantType: registrantType ?? this.registrantType,
      specialty: specialty ?? this.specialty,
      governmentIdFile: governmentIdFile ?? this.governmentIdFile,
      medicalLicenseFile: medicalLicenseFile ?? this.medicalLicenseFile,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      currentStep: currentStep ?? this.currentStep,
      showRecoveryCodes: showRecoveryCodes ?? this.showRecoveryCodes,
      generateKeys: generateKeys ?? this.generateKeys,
      requiresEmailVerification:
          requiresEmailVerification ?? this.requiresEmailVerification,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      requestSubscription: requestSubscription ?? this.requestSubscription,
      isBasicInfoValid: isBasicInfoValid ?? this.isBasicInfoValid,
      isPersonalDetailsValid:
          isPersonalDetailsValid ?? this.isPersonalDetailsValid,
      isLocationValid: isLocationValid ?? this.isLocationValid,
      isSpecialtiesValid: isSpecialtiesValid ?? this.isSpecialtiesValid,
      isDocumentsValid: isDocumentsValid ?? this.isDocumentsValid,
    );
  }
}
