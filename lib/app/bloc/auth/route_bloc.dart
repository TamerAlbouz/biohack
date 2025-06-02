import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:medtalk/backend/authentication/enums/auth_status.dart';
import 'package:medtalk/backend/authentication/enums/role.dart';
import 'package:medtalk/backend/authentication/interfaces/auth_interface.dart';
import 'package:medtalk/backend/cache/shared_preferences.dart';
import 'package:medtalk/backend/secure_storage/interfaces/secure_storage_interface.dart';
import 'package:medtalk/backend/user/models/user.dart';

part 'route_event.dart';
part 'route_state.dart';

@injectable
class RouteBloc extends Bloc<RouteEvent, RouteState> {
  RouteBloc(
    this._authRepo,
    this._userPreferences,
    this._secureStorageRepository,
    this.logger,
  ) : super(RouteInitial(user: User.empty)) {
    on<InitialRun>(_onInitialRun);
    on<AuthSubscriptionRequested>(_onSubscriptionRequested);
    on<AuthLogoutPressed>(_onLogoutPressed);
    on<ChooseRole>(_onChooseRole);
    on<SwitchRoles>(_onSwitchRoles);

    // Initialize with the current user after constructor
    if (_authRepo.currentUser != User.empty) {
      add(InitialRun());
    }
  }

  final IAuthenticationRepository _authRepo;
  final UserPreferences _userPreferences;
  final ISecureStorageRepository _secureStorageRepository;
  final Logger logger;

  String getRole() {
    return _userPreferences.getRole()?.name ?? '';
  }

  void _onSwitchRoles(
    SwitchRoles event,
    Emitter<RouteState> emit,
  ) {
    // empty roles
    _userPreferences.clearRole();
    emit(AuthChooseRole());
  }

  // on initial run, check if user is already signed in, and his email is verified
  Future<void> _onInitialRun(
    InitialRun event,
    Emitter<RouteState> emit,
  ) async {
    logger.i('Initial run');
    final user = _authRepo.currentUser;

    if (user == User.empty) {
      emit(AuthChooseRole());
      return;
    }

    final Role? role = _userPreferences.getRole();

    if (role == null) {
      emit(AuthChooseRole());
      return;
    }

    // check if email is verified
    final isEmailVerified = await _authRepo.isEmailVerified();
    if (!isEmailVerified) {
      logger.i('Email not verified');
      await signOut();
      return;
    }
  }

  Future<void> _onSubscriptionRequested(
    AuthSubscriptionRequested event,
    Emitter<RouteState> emit,
  ) {
    return emit.onEach(
      _authRepo.user,
      onData: (authUser) async {
        // if state is already loading, don't emit another loading state
        if (state is! AuthLoading) {
          emit(AuthLoading());
        }

        logger.i('Subscription requested');
        final Role? role = _userPreferences.getRole();

        if (role == null || authUser == User.empty) {
          logger.i('Role not found');
          return emit(AuthChooseRole());
        }

        // was user deleted from the database?
        if (await _authRepo.wasDeleted()) {
          logger.i('User was deleted');
          await signOut();
          return;
        }

        //if email is not verified, don't proceed
        if (!await _authRepo.isEmailVerified()) {
          logger.i('Email not verified');
          return;
        }

        _handleAuthFlow(authUser, emit, role);
      },
      onError: (error, stack) {
        addError(error, stack);
        emit(AuthFailure(error.toString()));
      },
    );
  }

  Future<void> _handleAuthFlow(
      User authUser, Emitter<RouteState> emit, Role role) async {
    emit(AuthLoading());

    // if user signed in anonymously, go straight to a premade workflow
    if (_authRepo.isAnonymous) {
      logger.i('Anonymous user ${role.name}: ${authUser.uid}');
      emit(AuthSuccess(authUser, role: role, status: AuthStatus.anonymous));
      return;
    }

    logger.i('${role.name} authenticated');
    emit(AuthSuccess(authUser, role: role, status: AuthStatus.authenticated));
  }

  void _onLogoutPressed(
    AuthLogoutPressed event,
    Emitter<RouteState> emit,
  ) async {
    emit(AuthLoading());
    await signOut();
  }

  Future<void> signOut() async {
    await _userPreferences.clearRole();

    // Use the injected secure storage
    await _secureStorageRepository.deleteAll();

    _authRepo.logOut();

    logger.i('User logged out');
  }

  Future<void> _onChooseRole(
    ChooseRole event,
    Emitter<RouteState> emit,
  ) async {
    try {
      await _userPreferences.setRole(event.role);
      logger.i('Role chosen: ${event.role}');
      emit(AuthLogin(event.role));
    } catch (e) {
      addError(e);
      emit(AuthFailure('Error choosing role'));
    }
  }
}
