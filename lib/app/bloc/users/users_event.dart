part of 'users_bloc.dart';

sealed class UsersEvent extends Equatable {
  const UsersEvent();
}

class LoadUsers extends UsersEvent {
  @override
  List<Object> get props => [];
}

class AddUser extends UsersEvent {
  final User user;

  const AddUser(this.user);

  @override
  List<Object> get props => [user];
}

class UpdateUser extends UsersEvent {
  final User user;

  const UpdateUser(this.user);

  @override
  List<Object> get props => [user];
}

class DeleteUser extends UsersEvent {
  final String id;

  const DeleteUser(this.id);

  @override
  List<Object> get props => [id];
}
