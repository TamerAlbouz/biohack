part of 'signup_patient_bloc.dart';

abstract class SignUpPatientEvent extends Equatable {
  const SignUpPatientEvent();

  @override
  List<Object?> get props => [];
}

class RequestSubscription extends SignUpPatientEvent {}

class SignUpEmailChanged extends SignUpPatientEvent {
  final String email;

  const SignUpEmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

class SignUpPasswordChanged extends SignUpPatientEvent {
  final String password;

  const SignUpPasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

class SignUpConfirmPasswordChanged extends SignUpPatientEvent {
  final String confirmPassword;

  const SignUpConfirmPasswordChanged(this.confirmPassword);

  @override
  List<Object?> get props => [confirmPassword];
}

class FullNameChanged extends SignUpPatientEvent {
  final String fullName;

  const FullNameChanged(this.fullName);

  @override
  List<Object?> get props => [fullName];
}

class DateOfBirthChanged extends SignUpPatientEvent {
  final String dateOfBirth;

  const DateOfBirthChanged(this.dateOfBirth);

  @override
  List<Object?> get props => [dateOfBirth];
}

class SubmitSignUp extends SignUpPatientEvent {}

class CheckEmailVerification extends SignUpPatientEvent {}

class GenerateKeys extends SignUpPatientEvent {
  final String recoveryCode;

  const GenerateKeys(this.recoveryCode);

  @override
  List<Object?> get props => [recoveryCode];
}

class ResendVerificationEmail extends SignUpPatientEvent {}

class ResetStatus extends SignUpPatientEvent {}

class SexChanged extends SignUpPatientEvent {
  final String sex;

  const SexChanged(this.sex);

  @override
  List<Object?> get props => [sex];
}
