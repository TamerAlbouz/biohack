part of 'auth_bloc.dart';

final class AuthState extends Equatable {
  AuthState({User user = User.empty})
      : this._(
          status: user == User.empty
              ? AuthStatus.unauthenticated
              : AuthStatus.authenticated,
          user: user,
          role: user.role,
        );

  const AuthState._(
      {required this.status, this.user = User.empty, this.role? = Role.patient});

  final AuthStatus status;
  final User user;
  final Role? role;

  @override
  List<Object> get props => [status, user];
}
