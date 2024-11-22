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
  })  : _authRepo = authRepo,
        _userPreferences = userPreferences,
        _patientRepository = patientRepository,
        super(RouteInitial(user: authRepo.currentUser)) {
    on<AuthSubscriptionRequested>(_onSubscriptionRequested);
    on<AuthLogoutPressed>(_onLogoutPressed);
    on<ChooseRole>(_onChooseRole);
  }

  final IAuthenticationRepository _authRepo;
  final UserPreferences _userPreferences;
  final IPatientRepository _patientRepository;

  Future<void> _onSubscriptionRequested(
    AuthSubscriptionRequested event,
    Emitter<RouteState> emit,
  ) {
    return emit.onEach(
      _authRepo.user,
      onData: (user) async {
        emit(AuthLoading());
        logger.i('Subscription requested');
        final Role? role = _userPreferences.getRole();

        if (role == null || user == User.empty) {
          logger.i('Role not found');
          return emit(AuthChooseRole());
        }

        switch (role) {
          case Role.patient:
            logger.i('Patient role');
            await _handlePatientFlow(user, emit, role);
            break;
          case Role.doctor:
            break;
          default:
            emit(AuthFailure('Role not found'));
            break;
        }
      },
      onError: (error, stack) {
        addError(error, stack);
        emit(AuthFailure(error.toString()));
      },
    );
  }

  Future<void> _handlePatientFlow(
      User user, Emitter<RouteState> emit, Role role) async {
    emit(AuthLoading());

    // if user signed in anonymously, go straight to a premade workflow
    if (_authRepo.isAnonymous) {
      logger.i('Anonymous user');
      emit(AuthSuccess(user, role: Role.patient, status: AuthStatus.anonymous));
      return;
    }

    final patient = await _patientRepository.getPatient(user.uid);

    if (patient == null) {
      logger.i('Patient first time');
      emit(AuthSuccess(user,
          role: Role.patient, status: AuthStatus.firstTimeAuthentication));
    } else {
      logger.i('Patient authenticated');
      emit(AuthSuccess(user,
          role: Role.patient, status: AuthStatus.authenticated));
    }
  }

  void _onLogoutPressed(
    AuthLogoutPressed event,
    Emitter<RouteState> emit,
  ) async {
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
