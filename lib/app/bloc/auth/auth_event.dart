part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class AuthSubscriptionRequested extends AuthEvent {}

final class AuthLogoutPressed extends AuthEvent {}
