part of 'auth_bloc.dart';

final class AuthState extends Equatable {
  const AuthState({User user = User.empty})
      : this._(
          status: user == User.empty
              ? AuthStatus.unauthenticated
              : AuthStatus.authenticated,
          user: user,
        );

  const AuthState._({required this.status, this.user = User.empty});

  final AuthStatus status;
  final User user;

  @override
  List<Object> get props => [status, user];
}
