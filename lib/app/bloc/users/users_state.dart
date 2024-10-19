part of 'users_bloc.dart';

sealed class UsersState extends Equatable {
  const UsersState();
}

final class UsersInitial extends UsersState {
  @override
  List<Object> get props => [];
}

final class UsersLoading extends UsersState {
  @override
  List<Object> get props => [];
}

final class UsersLoaded extends UsersState {
  final List<User> users;

  const UsersLoaded(this.users);

  @override
  List<Object> get props => [users];
}

final class UsersError extends UsersState {
  final String message;

  const UsersError(this.message);

  @override
  List<Object> get props => [message];
}

final class UserOperationSuccess extends UsersState {
  final String message;

  const UserOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}
