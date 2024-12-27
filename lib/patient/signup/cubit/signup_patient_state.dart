part of 'signup_patient_bloc.dart';

final class SignUpPatientState extends Equatable {
  const SignUpPatientState({
    this.signUpEmail = const Email.pure(),
    this.signUpPassword = const Password.pure(),
    this.signUpConfirmPassword = const Password.pure(),
    this.fullName = const FullName.pure(),
    this.dateOfBirth = const DateOfBirth.pure(),
    this.sex = const Sex.pure(),
    this.bloodGroup = const BloodGroup.pure(),
    this.height = const Height.pure(),
    this.weight = const Weight.pure(),
    this.biography = const Biography.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.generateKeys = false,
    this.requiresEmailVerification = false,
    this.isValid = false,
    this.errorMessage,
    this.showRecoveryCodes = false,
    this.requestSubscription = false,
  });

  final Email signUpEmail;
  final Password signUpPassword;
  final Password signUpConfirmPassword;
  final bool generateKeys;
  final FullName fullName;
  final DateOfBirth dateOfBirth;
  final Sex sex;
  final BloodGroup bloodGroup;
  final Height height;
  final Weight weight;
  final Biography biography;
  final bool showRecoveryCodes;
  final bool requiresEmailVerification;
  final FormzSubmissionStatus status;
  final bool isValid;
  final String? errorMessage;
  final bool requestSubscription;

  @override
  List<Object?> get props => [
        fullName,
        dateOfBirth,
        sex,
        bloodGroup,
        generateKeys,
        height,
        showRecoveryCodes,
        weight,
        biography,
        signUpEmail,
        signUpPassword,
        signUpConfirmPassword,
        requiresEmailVerification,
        status,
        isValid,
        errorMessage,
        requestSubscription,
      ];

  SignUpPatientState copyWith({
    Email? signUpEmail,
    Password? signUpPassword,
    Password? signUpConfirmPassword,
    FullName? fullName,
    bool? requiresEmailVerification,
    bool? showRecoveryCodes,
    DateOfBirth? dateOfBirth,
    bool? generateKeys,
    Sex? sex,
    BloodGroup? bloodGroup,
    Height? height,
    Weight? weight,
    Biography? biography,
    FormzSubmissionStatus? status,
    bool? isValid,
    String? errorMessage,
    bool? requestSubscription,
  }) {
    return SignUpPatientState(
      signUpEmail: signUpEmail ?? this.signUpEmail,
      signUpPassword: signUpPassword ?? this.signUpPassword,
      signUpConfirmPassword:
          signUpConfirmPassword ?? this.signUpConfirmPassword,
      showRecoveryCodes: showRecoveryCodes ?? this.showRecoveryCodes,
      generateKeys: generateKeys ?? this.generateKeys,
      fullName: fullName ?? this.fullName,
      requiresEmailVerification:
          requiresEmailVerification ?? this.requiresEmailVerification,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      sex: sex ?? this.sex,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      biography: biography ?? this.biography,
      status: status ?? this.status,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
      requestSubscription: requestSubscription ?? this.requestSubscription,
    );
  }
}
