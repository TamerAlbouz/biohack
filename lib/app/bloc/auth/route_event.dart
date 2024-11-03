part of 'route_bloc.dart';

@immutable
sealed class RouteEvent extends Equatable {}

final class AuthSubscriptionRequested extends RouteEvent {
  @override
  List<Object> get props => [];
}

final class AuthLogoutPressed extends RouteEvent {
  @override
  List<Object> get props => [];
}

final class ChooseRole extends RouteEvent {
  final Role role;

  ChooseRole(this.role);

  @override
  List<Object> get props => [role];
}
