part of 'forgot_password_bloc.dart';

final class ForgotPasswordState extends Equatable {
  const ForgotPasswordState(
      {this.email = const Email.pure(),
      this.password = const Password.pure(),
      this.confirmPassword = '',
      this.status = FormzSubmissionStatus.initial,
      this.isValid = false,
      this.errorMessage,
      this.emailVerificationCode,
      this.recoveryCode = '',
      this.showCodeCheck = false,
      this.showResetPassword = false,
      this.showRecovery = false});

  final Email email;
  final Password password;
  final String confirmPassword;
  final FormzSubmissionStatus status;
  final bool isValid;
  final String? errorMessage;
  final String? emailVerificationCode;
  final String recoveryCode;
  final bool showCodeCheck;
  final bool showResetPassword;
  final bool showRecovery;

  @override
  List<Object?> get props => [
        email,
        password,
        confirmPassword,
        status,
        isValid,
        errorMessage,
        emailVerificationCode,
        recoveryCode,
        showCodeCheck,
        showResetPassword,
        showRecovery,
      ];

  ForgotPasswordState copyWith(
      {Email? email,
      Password? password,
      String? confirmPassword,
      FormzSubmissionStatus? status,
      bool? isValid,
      String? errorMessage,
      String? emailVerificationCode,
      String? recoveryCode,
      bool? showCodeCheck,
      bool? showResetPassword,
      bool? showRecovery}) {
    return ForgotPasswordState(
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      status: status ?? this.status,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
      emailVerificationCode:
          emailVerificationCode ?? this.emailVerificationCode,
      recoveryCode: recoveryCode ?? this.recoveryCode,
      showCodeCheck: showCodeCheck ?? this.showCodeCheck,
      showResetPassword: showResetPassword ?? this.showResetPassword,
      showRecovery: showRecovery ?? this.showRecovery,
    );
  }
}
