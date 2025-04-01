part of 'forgot_password_bloc.dart';

sealed class ForgotPasswordEvent extends Equatable {
  const ForgotPasswordEvent();
}

class SendEmailVerification extends ForgotPasswordEvent {
  const SendEmailVerification();

  @override
  List<Object> get props => [];
}

class PasswordChanged extends ForgotPasswordEvent {
  const PasswordChanged(this.password);

  final String password;

  @override
  List<Object> get props => [password];
}

class ConfirmPasswordChanged extends ForgotPasswordEvent {
  const ConfirmPasswordChanged(this.confirmPassword);

  final String confirmPassword;

  @override
  List<Object> get props => [confirmPassword];
}

class CheckEmailVerificationCode extends ForgotPasswordEvent {
  const CheckEmailVerificationCode(this.verificationCode);

  final String verificationCode;

  @override
  List<Object> get props => [verificationCode];
}

class RecoveryCodeChanged extends ForgotPasswordEvent {
  const RecoveryCodeChanged(this.recoveryCode);

  final String recoveryCode;

  @override
  List<Object> get props => [recoveryCode];
}

class EmailChanged extends ForgotPasswordEvent {
  const EmailChanged(this.email);

  final String email;

  @override
  List<Object> get props => [email];
}

class ResetPasswordWithCode extends ForgotPasswordEvent {
  const ResetPasswordWithCode({required this.newRecoveryCode});

  final String newRecoveryCode;

  @override
  List<Object> get props => [newRecoveryCode];
}
