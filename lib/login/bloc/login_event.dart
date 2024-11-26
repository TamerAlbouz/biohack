part of 'login_bloc.dart';

sealed class LoginEvent extends Equatable {
  const LoginEvent();
}

class SignInEmailChanged extends LoginEvent {
  const SignInEmailChanged(this.email);

  final String email;

  @override
  List<Object> get props => [email];
}

class SignInPasswordChanged extends LoginEvent {
  const SignInPasswordChanged(this.password);

  final String password;

  @override
  List<Object> get props => [password];
}

class SignUpEmailChanged extends LoginEvent {
  const SignUpEmailChanged(this.email);

  final String email;

  @override
  List<Object> get props => [email];
}

class SignUpPasswordChanged extends LoginEvent {
  const SignUpPasswordChanged(this.password);

  final String password;

  @override
  List<Object> get props => [password];
}

class SignUpConfirmPasswordChanged extends LoginEvent {
  const SignUpConfirmPasswordChanged(this.password);

  final String password;

  @override
  List<Object> get props => [password];
}

class LogInWithCredentials extends LoginEvent {
  const LogInWithCredentials();

  @override
  List<Object> get props => [];
}

class LogInAnonymously extends LoginEvent {
  const LogInAnonymously();

  @override
  List<Object> get props => [];
}

class CheckEmailVerification extends LoginEvent {
  const CheckEmailVerification();

  @override
  List<Object> get props => [];
}

class ResendVerificationEmail extends LoginEvent {
  const ResendVerificationEmail();

  @override
  List<Object> get props => [];
}

class SignUpWithCredential extends LoginEvent {
  const SignUpWithCredential();

  @override
  List<Object> get props => [];
}

class ResetStatus extends LoginEvent {
  const ResetStatus();

  @override
  List<Object> get props => [];
}
