part of 'auth_bloc.dart';

final class AuthState extends Equatable {
  @override
  List<Object> get props => [];
}

final class AuthInitial extends AuthState {
  final User user;

  AuthInitial({required this.user});

  @override
  List<Object> get props => [user];
}

final class AuthChooseRole extends AuthState {
  @override
  List<Object> get props => [];
}

final class AuthLoading extends AuthState {
  @override
  List<Object> get props => [];
}

final class AuthSuccess extends AuthState {
  final User user;
  final Role role;
  final AuthStatus status;

  AuthSuccess(this.user,
      {this.role = Role.unknown, this.status = AuthStatus.unauthenticated});

  @override
  List<Object> get props => [user, role, status];
}

final class AuthLogin extends AuthState {
  final Role role;

  AuthLogin(this.role);

  @override
  List<Object> get props => [role];
}

final class AuthFailure extends AuthState {
  final String message;

  AuthFailure(this.message);

  @override
  List<Object> get props => [message];
}
