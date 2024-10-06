import 'package:authentication/authentication.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required AuthenticationRepository authRepo,
  })  : _authRepo = authRepo,
        super(AuthState(user: authRepo.currentUser)) {
    on<AuthSubscriptionRequested>(_onSubscriptionRequested);
    on<AuthLogoutPressed>(_onLogoutPressed);
  }

  final AuthenticationRepository _authRepo;

  Future<void> _onSubscriptionRequested(
    AuthSubscriptionRequested event,
    Emitter<AuthState> emit,
  ) {
    return emit.onEach(
      _authRepo.user,
      onData: (user) => emit(AuthState(user: user)),
      onError: addError,
    );
  }

  void _onLogoutPressed(
    AuthLogoutPressed event,
    Emitter<AuthState> emit,
  ) {
    _authRepo.logOut();
  }
}
