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

class SexChanged extends SignUpDoctorEvent {
  final String sex;

  const SexChanged(this.sex);

  @override
  List<Object?> get props => [sex];
}

class PreviousNameChanged extends SignUpDoctorEvent {
  final String previousName;

  const PreviousNameChanged(this.previousName);

  @override
  List<Object?> get props => [previousName];
}

class LicenseTypeChanged extends SignUpDoctorEvent {
  final String licenseType;

  const LicenseTypeChanged(this.licenseType);

  @override
  List<Object?> get props => [licenseType];
}

class LicenseNumberChanged extends SignUpDoctorEvent {
  final String licenseNumber;

  const LicenseNumberChanged(this.licenseNumber);

  @override
  List<Object?> get props => [licenseNumber];
}

class LocationChanged extends SignUpDoctorEvent {
  final String location;

  const LocationChanged(this.location);

  @override
  List<Object?> get props => [location];
}

class ZoneChanged extends SignUpDoctorEvent {
  final String zone;

  const ZoneChanged(this.zone);

  @override
  List<Object?> get props => [zone];
}

class AtlanticRegistryChanged extends SignUpDoctorEvent {
  final String isAtlanticRegistry;

  const AtlanticRegistryChanged(this.isAtlanticRegistry);

  @override
  List<Object?> get props => [isAtlanticRegistry];
}

class RegistryHomeChanged extends SignUpDoctorEvent {
  final String registryHome;

  const RegistryHomeChanged(this.registryHome);

  @override
  List<Object?> get props => [registryHome];
}

class RegistrantTypeChanged extends SignUpDoctorEvent {
  final String registrantType;

  const RegistrantTypeChanged(this.registrantType);

  @override
  List<Object?> get props => [registrantType];
}

class SpecialtyChanged extends SignUpDoctorEvent {
  final String specialty;

  const SpecialtyChanged(this.specialty);

  @override
  List<Object?> get props => [specialty];
}

class GovernmentIdUploaded extends SignUpDoctorEvent {
  final PlatformFile file;

  const GovernmentIdUploaded(this.file);

  @override
  List<Object?> get props => [file];
}

class MedicalLicenseUploaded extends SignUpDoctorEvent {
  final PlatformFile file;

  const MedicalLicenseUploaded(this.file);

  @override
  List<Object?> get props => [file];
}

class TermsAcceptedChanged extends SignUpDoctorEvent {
  final bool accepted;

  const TermsAcceptedChanged(this.accepted);

  @override
  List<Object?> get props => [accepted];
}

// 1. First, add this new event to signup_doctor_event.dart:
class CheckEmailExists extends SignUpDoctorEvent {
  final String email;

  const CheckEmailExists(this.email);

  @override
  List<Object?> get props => [email];
}

class NextStep extends SignUpDoctorEvent {}

class PreviousStep extends SignUpDoctorEvent {}

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
