import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase/firebase.dart';
import 'package:flutter/material.dart';
import 'package:models/models.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required IAuthenticationRepository authRepo,
    required IUserInterface userRepo,
  })  : _authRepo = authRepo,
        _userRepo = userRepo,
        super(AuthState(user: authRepo.currentUser)) {
    on<AuthSubscriptionRequested>(_onSubscriptionRequested);
    on<AuthLogoutPressed>(_onLogoutPressed);
  }

  final IAuthenticationRepository _authRepo;
  final IUserInterface _userRepo;

  Future<void> _onSubscriptionRequested(
    AuthSubscriptionRequested event,
    Emitter<AuthState> emit,
  ) {
    return emit.onEach(
      _userRepo.user,
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
