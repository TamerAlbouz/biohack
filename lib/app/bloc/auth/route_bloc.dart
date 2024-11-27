import 'package:backend/backend.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:p_logger/p_logger.dart';

part 'route_event.dart';
part 'route_state.dart';

class RouteBloc extends Bloc<RouteEvent, RouteState> {
  RouteBloc({
    required IAuthenticationRepository authRepo,
    required UserPreferences userPreferences,
    required IPatientRepository patientRepository,
    required IDoctorRepository doctorRepository,
  })  : _authRepo = authRepo,
        _userPreferences = userPreferences,
        _patientRepository = patientRepository,
        _doctorRepository = doctorRepository,
        super(RouteInitial(user: authRepo.currentUser)) {
    on<InitialRun>(_onInitialRun);
    on<AuthSubscriptionRequested>(_onSubscriptionRequested);
    on<AuthLogoutPressed>(_onLogoutPressed);
    on<ChooseRole>(_onChooseRole);
  }

  final IAuthenticationRepository _authRepo;
  final UserPreferences _userPreferences;
  final IPatientRepository _patientRepository;
  final IDoctorRepository _doctorRepository;

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

    var user;

    switch (role) {
      case Role.patient:
        user = await _patientRepository.getPatient(authUser.uid);
        break;
      case Role.doctor:
        user = await _doctorRepository.getDoctor(authUser.uid);
        break;
      default:
        emit(AuthFailure('Role not found'));
        return;
    }

    if (user == null) {
      logger.i('${role.name} first time: ${authUser.uid}');
      emit(AuthSuccess(authUser,
          role: role, status: AuthStatus.firstTimeAuthentication));
    } else {
      logger.i('${role.name} authenticated: ${authUser.uid}');
      emit(AuthSuccess(authUser, role: role, status: AuthStatus.authenticated));
    }
  }

  void _onLogoutPressed(
    AuthLogoutPressed event,
    Emitter<RouteState> emit,
  ) async {
    emit(AuthLoading());
    await signOut();
  }

  Future<void> signOut() async {
    await _userPreferences.clear();

    // empty the secure storage
    ISecureEncryptionStorage secureEncryptionStorage =
        getIt<ISecureEncryptionStorage>();

    await secureEncryptionStorage.deleteKeys();

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
      logger.e('Error choosing role: $e');
      emit(AuthFailure('Error choosing role'));
    }
  }
}
