part of 'route_bloc.dart';

final class RouteState extends Equatable {
  @override
  List<Object> get props => [];
}

final class RouteInitial extends RouteState {
  final User user;

  RouteInitial({required this.user});

  @override
  List<Object> get props => [user];
}

final class AuthChooseRole extends RouteState {
  @override
  List<Object> get props => [];
}

final class AuthLoading extends RouteState {
  @override
  List<Object> get props => [];
}

final class AuthSuccess extends RouteState {
  final User user;
  final Role role;
  final AuthStatus status;

  AuthSuccess(this.user,
      {this.role = Role.unknown, this.status = AuthStatus.unauthenticated});

  @override
  List<Object> get props => [user, role, status];
}

final class AuthLogin extends RouteState {
  final Role role;

  AuthLogin(this.role);

  @override
  List<Object> get props => [role];
}

final class AuthFailure extends RouteState {
  final String message;

  AuthFailure(this.message);

  @override
  List<Object> get props => [message];
}
