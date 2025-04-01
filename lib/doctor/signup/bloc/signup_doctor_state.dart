part of 'signup_doctor_bloc.dart';

final class SignUpDoctorState extends Equatable {
  const SignUpDoctorState({
    this.signUpEmail = const Email.pure(),
    this.signUpPassword = const Password.pure(),
    this.signUpConfirmPassword = const Password.pure(),
    this.fullName = const FullName.pure(),
    this.dateOfBirth = const DateOfBirth.pure(),
    this.sex = const Sex.pure(),
    this.biography = const Biography.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.generateKeys = false,
    this.requiresEmailVerification = false,
    this.isValid = false,
    this.errorMessage,
    this.showRecoveryCodes = false,
    this.requestSubscription = false,
    this.state = '',
    this.licNum = '',
  });

  final Email signUpEmail;
  final Password signUpPassword;
  final Password signUpConfirmPassword;
  final bool generateKeys;
  final FullName fullName;
  final DateOfBirth dateOfBirth;
  final Sex sex;
  final Biography biography;
  final bool showRecoveryCodes;
  final bool requiresEmailVerification;
  final String state;
  final String licNum;
  final FormzSubmissionStatus status;
  final bool isValid;
  final String? errorMessage;
  final bool requestSubscription;

  @override
  List<Object?> get props => [
        fullName,
        dateOfBirth,
        sex,
        generateKeys,
        showRecoveryCodes,
        state,
        licNum,
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

  SignUpDoctorState copyWith({
    Email? signUpEmail,
    Password? signUpPassword,
    Password? signUpConfirmPassword,
    String? state,
    String? licNum,
    FullName? fullName,
    bool? requiresEmailVerification,
    bool? showRecoveryCodes,
    DateOfBirth? dateOfBirth,
    bool? generateKeys,
    Sex? sex,
    Biography? biography,
    FormzSubmissionStatus? status,
    bool? isValid,
    String? errorMessage,
    bool? requestSubscription,
  }) {
    return SignUpDoctorState(
      signUpEmail: signUpEmail ?? this.signUpEmail,
      signUpPassword: signUpPassword ?? this.signUpPassword,
      signUpConfirmPassword:
          signUpConfirmPassword ?? this.signUpConfirmPassword,
      state: state ?? this.state,
      licNum: licNum ?? this.licNum,
      showRecoveryCodes: showRecoveryCodes ?? this.showRecoveryCodes,
      generateKeys: generateKeys ?? this.generateKeys,
      fullName: fullName ?? this.fullName,
      requiresEmailVerification:
          requiresEmailVerification ?? this.requiresEmailVerification,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      sex: sex ?? this.sex,
      biography: biography ?? this.biography,
      status: status ?? this.status,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
      requestSubscription: requestSubscription ?? this.requestSubscription,
    );
  }
}
