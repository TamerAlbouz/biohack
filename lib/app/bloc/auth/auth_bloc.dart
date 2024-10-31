import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase/firebase.dart';
import 'package:flutter/material.dart';
import 'package:models/models.dart';
import 'package:p_logger/p_logger.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required IAuthenticationRepository authRepo,
    required UserPreferences userPreferences,
    required IPatientRepository patientRepository,
  })  : _authRepo = authRepo,
        _userPreferences = userPreferences,
        _patientRepository = patientRepository,
        super(AuthInitial(user: authRepo.currentUser)) {
    on<AuthSubscriptionRequested>(_onSubscriptionRequested);
    on<AuthLogoutPressed>(_onLogoutPressed);
    on<ChooseRole>(_onChooseRole);
  }

  final IAuthenticationRepository _authRepo;
  final UserPreferences _userPreferences;
  final IPatientRepository _patientRepository;

  Future<void> _onSubscriptionRequested(
    AuthSubscriptionRequested event,
    Emitter<AuthState> emit,
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
      User user, Emitter<AuthState> emit, Role role) async {
    emit(AuthLoading());

    // if user signed in anonymously, go straight to a premade workflow
    // if (user.isAnonymous) {
    //   logger.i('Anonymous user');
    //   emit(AuthSuccess(user,
    //       role: Role.patient, status: AuthStatus.firstTimeAuthentication));
    //   return;
    // }

    final patient = await _patientRepository.getPatient(user.uid);

    if (patient == null) {
      logger.i('Patient not found');
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
    Emitter<AuthState> emit,
  ) async {
    await _userPreferences.clear();
    _authRepo.logOut();
    logger.i('User logged out');
  }

  Future<void> _onChooseRole(
    ChooseRole event,
    Emitter<AuthState> emit,
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
