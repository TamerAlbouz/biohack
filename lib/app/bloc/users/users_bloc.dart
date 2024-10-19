import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase/firebase.dart';
import 'package:models/models.dart';
import 'package:stream_transform/stream_transform.dart';

part 'users_event.dart';
part 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  UsersBloc({
    required IUserInterface usersRepo,
  })  : _usersRepo = usersRepo,
        super(UsersInitial()) {
    // on<LoadUsers>(_onLoadUsers, transformer: restartable());
    // on<AddUser>(_onAddUser);
  }

  final IUserInterface _usersRepo;

  //
  // Future<void> _onLoadUsers(LoadUsers event, Emitter<UsersState> emit) {
  //   return emit.onEach(_usersRepo.getUsers(),
  //       onData: (users) => emit(UsersLoaded(users)),
  //       onError: (error, stackTrace) {
  //         addError(error, stackTrace);
  //         emit(UsersError(error.toString()));
  //       });
  // }
  //
  // Future<void> _onAddUser(AddUser event, Emitter<UsersState> emit) {
  //   return _usersRepo.addUser(event.user).then(
  //       (_) => emit(const UserOperationSuccess('User added successfully')),
  //       onError: (error, stackTrace) {
  //     addError(error, stackTrace);
  //     emit(UsersError(error.toString()));
  //   });
  // }

  /// Process only one event by cancelling any pending events and
  /// processing the new event immediately.
  ///
  /// Avoid using [restartable] if you expect an event to have
  /// immediate results -- it should only be used with asynchronous APIs.
  ///
  /// **Note**: there is no event handler overlap and any currently running tasks
  /// will be aborted if a new event is added before a prior one completes.
  EventTransformer<Event> restartable<Event>() {
    return (events, mapper) => events.switchMap(mapper);
  }
}
