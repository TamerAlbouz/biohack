part of 'signup_doctor_bloc.dart';

abstract class SignUpDoctorEvent extends Equatable {
  const SignUpDoctorEvent();

  @override
  List<Object?> get props => [];
}

class RequestSubscription extends SignUpDoctorEvent {}

class SignUpEmailChanged extends SignUpDoctorEvent {
  final String email;

  const SignUpEmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

class SignUpPasswordChanged extends SignUpDoctorEvent {
  final String password;

  const SignUpPasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

class SignUpConfirmPasswordChanged extends SignUpDoctorEvent {
  final String confirmPassword;

  const SignUpConfirmPasswordChanged(this.confirmPassword);

  @override
  List<Object?> get props => [confirmPassword];
}

class FullNameChanged extends SignUpDoctorEvent {
  final String fullName;

  const FullNameChanged(this.fullName);

  @override
  List<Object?> get props => [fullName];
}

class DateOfBirthChanged extends SignUpDoctorEvent {
  final String dateOfBirth;

  const DateOfBirthChanged(this.dateOfBirth);

  @override
  List<Object?> get props => [dateOfBirth];
}

class SubmitSignUp extends SignUpDoctorEvent {}

class CheckEmailVerification extends SignUpDoctorEvent {}

class GenerateKeys extends SignUpDoctorEvent {
  final String recoveryCode;

  const GenerateKeys(this.recoveryCode);

  @override
  List<Object?> get props => [recoveryCode];
}

class ResendVerificationEmail extends SignUpDoctorEvent {}

class ResetStatus extends SignUpDoctorEvent {}

class SexChanged extends SignUpDoctorEvent {
  final String sex;

  const SexChanged(this.sex);

  @override
  List<Object?> get props => [sex];
}
