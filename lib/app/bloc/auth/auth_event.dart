part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent extends Equatable {}

final class AuthSubscriptionRequested extends AuthEvent {
  @override
  List<Object> get props => [];
}

final class AuthLogoutPressed extends AuthEvent {
  @override
  List<Object> get props => [];
}

final class ChooseRole extends AuthEvent {
  final Role role;

  ChooseRole(this.role);

  @override
  List<Object> get props => [role];
}
