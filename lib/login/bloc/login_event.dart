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

class ResetStatus extends LoginEvent {
  const ResetStatus();

  @override
  List<Object> get props => [];
}
