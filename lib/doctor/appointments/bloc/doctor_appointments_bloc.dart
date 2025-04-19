import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:medtalk/backend/appointment/enums/appointment_status.dart';
import 'package:medtalk/backend/appointment/interfaces/appointment_interface.dart';
import 'package:medtalk/backend/appointment/models/appointment.dart';
import 'package:medtalk/backend/authentication/interfaces/auth_interface.dart';
import 'package:medtalk/backend/patient/interfaces/patient_interface.dart';

import '../models/appointments_models.dart';

part 'doctor_appointments_event.dart';
part 'doctor_appointments_state.dart';

@injectable
class DoctorAppointmentsBloc
    extends Bloc<DoctorAppointmentsEvent, DoctorAppointmentsState> {
  final IAppointmentRepository _appointmentRepository;
  final IAuthenticationRepository _authRepository;
  final IPatientRepository _patientRepository;
  final Logger logger;

  DoctorAppointmentsBloc(
    this._appointmentRepository,
    this._authRepository,
    this._patientRepository,
    this.logger,
  ) : super(DoctorAppointmentsInitial()) {
    on<LoadDoctorAppointments>(_onLoadDoctorAppointments);
    on<FilterDoctorAppointments>(_onFilterDoctorAppointments);
    on<FilterAppointments>(_onFilterAppointments);
    on<ResetFilters>(_onResetFilters);
    on<UpdateAppointmentStatus>(_onUpdateAppointmentStatus);
    on<MarkAppointmentViewed>(_onMarkAppointmentViewed);
    on<ClearAllViewedBadges>(_onClearAllViewedBadges);
    on<ClearTabViewedBadges>(_onClearTabViewedBadges);
  }

  void _onMarkAppointmentViewed(
    MarkAppointmentViewed event,
    Emitter<DoctorAppointmentsState> emit,
  ) {
    if (state is DoctorAppointmentsLoaded) {
      final currentState = state as DoctorAppointmentsLoaded;
      final updatedViewedIds =
          Set<String>.from(currentState.viewedAppointmentIds)
            ..add(event.appointmentId);

      emit(currentState.copyWith(
        viewedAppointmentIds: updatedViewedIds,
      ));
    }
  }

  void _onClearAllViewedBadges(
    ClearAllViewedBadges event,
    Emitter<DoctorAppointmentsState> emit,
  ) {
    if (state is DoctorAppointmentsLoaded) {
      final currentState = state as DoctorAppointmentsLoaded;
      final allAppointmentIds = [
        ...currentState.upcomingAppointments,
        ...currentState.missedAppointments,
      ]
          .map((appointment) => appointment.appointment.appointmentId as String)
          .toSet();

      emit(currentState.copyWith(
        viewedAppointmentIds: allAppointmentIds,
      ));
    }
  }

  void _onClearTabViewedBadges(
    ClearTabViewedBadges event,
    Emitter<DoctorAppointmentsState> emit,
  ) {
    if (state is DoctorAppointmentsLoaded) {
      final currentState = state as DoctorAppointmentsLoaded;

      Set<String> tabAppointmentIds;

      switch (event.tab) {
        case AppointmentTab.upcoming:
          tabAppointmentIds = currentState.upcomingAppointments
              .map((appointment) =>
                  appointment.appointment.appointmentId as String)
              .toSet();
          break;
        case AppointmentTab.missed:
          tabAppointmentIds = currentState.missedAppointments
              .map((appointment) =>
                  appointment.appointment.appointmentId as String)
              .toSet();
          break;
        default:
          return; // No action needed for other tabs
      }

      final updatedViewedIds =
          Set<String>.from(currentState.viewedAppointmentIds)
            ..addAll(tabAppointmentIds);

      emit(currentState.copyWith(
        viewedAppointmentIds: updatedViewedIds,
      ));
    }
  }

  Future<void> _onLoadDoctorAppointments(
    LoadDoctorAppointments event,
    Emitter<DoctorAppointmentsState> emit,
  ) async {
    try {
      emit(DoctorAppointmentsLoading());

      // Get the current doctor ID
      final currentUser = _authRepository.currentUser;

      logger.d('Loading appointments for doctor: ${currentUser.uid}');

      // Get appointments for the doctor
      final appointments =
          await _appointmentRepository.getDoctorAppointments(currentUser.uid);

      logger.d('Retrieved ${appointments.length} appointments');

      // Process the appointments
      await _processAndEmitAppointments(
        emit,
        appointments,
        null,
        null,
        const AppointmentFilterCriteria(),
      );
    } catch (e) {
      logger.e('Error loading doctor appointments: $e');
      emit(DoctorAppointmentsError(e.toString()));
    }
  }

  Future<void> _onResetFilters(
    ResetFilters event,
    Emitter<DoctorAppointmentsState> emit,
  ) async {
    if (state is DoctorAppointmentsLoaded) {
      try {
        emit(DoctorAppointmentsLoading());

        // Get the current doctor ID
        final currentUser = _authRepository.currentUser;

        // Get appointments for the doctor
        final appointments =
            await _appointmentRepository.getDoctorAppointments(currentUser.uid);

        // Process with no filters
        await _processAndEmitAppointments(
          emit,
          appointments,
          null,
          null,
          const AppointmentFilterCriteria(),
        );
      } catch (e) {
        logger.e('Error resetting filters: $e');
        emit(DoctorAppointmentsError(e.toString()));
      }
    }
  }

  Future<void> _onFilterAppointments(
    FilterAppointments event,
    Emitter<DoctorAppointmentsState> emit,
  ) async {
    try {
      emit(DoctorAppointmentsLoading());

      // Get the current doctor ID
      final currentUser = _authRepository.currentUser;

      // Get all appointments for the doctor
      final appointments =
          await _appointmentRepository.getDoctorAppointments(currentUser.uid);

      // Process and apply the filter criteria
      await _processAndEmitAppointments(
        emit,
        appointments,
        event.filterCriteria.fromDate,
        event.filterCriteria.toDate,
        event.filterCriteria,
      );
    } catch (e) {
      logger.e('Error filtering appointments: $e');
      emit(DoctorAppointmentsError(e.toString()));
    }
  }

  Future<void> _onFilterDoctorAppointments(
    FilterDoctorAppointments event,
    Emitter<DoctorAppointmentsState> emit,
  ) async {
    try {
      emit(DoctorAppointmentsLoading());

      // Get the current doctor ID
      final currentUser = _authRepository.currentUser;

      // Get appointments for the doctor
      final appointments =
          await _appointmentRepository.getDoctorAppointments(currentUser.uid);

      // Create filter criteria from legacy event
      final filterCriteria = AppointmentFilterCriteria(
        fromDate: event.fromDate,
        toDate: event.toDate,
      );

      // Process and emit appointments
      await _processAndEmitAppointments(
        emit,
        appointments,
        event.fromDate,
        event.toDate,
        filterCriteria,
      );
    } catch (e) {
      logger.e('Error filtering doctor appointments: $e');
      emit(DoctorAppointmentsError(e.toString()));
    }
  }

  Future<void> _processAndEmitAppointments(
    Emitter<DoctorAppointmentsState> emit,
    List<Appointment> appointments,
    DateTime? fromDate,
    DateTime? toDate,
    AppointmentFilterCriteria filterCriteria,
  ) async {
    // Apply date and other filters if specified
    final filteredAppointments = appointments.where((appointment) {
      // Date range filter
      if (fromDate != null && appointment.appointmentDate.isBefore(fromDate)) {
        return false;
      }
      if (toDate != null &&
          appointment.appointmentDate
              .isAfter(toDate.add(const Duration(days: 1)))) {
        return false;
      }

      // Status filter
      if (filterCriteria.statusFilter != null &&
          !filterCriteria.statusFilter!.contains(appointment.status)) {
        return false;
      }

      // Service name filter
      if (filterCriteria.serviceNameFilter != null &&
          !appointment.serviceName
              .toLowerCase()
              .contains(filterCriteria.serviceNameFilter!.toLowerCase())) {
        return false;
      }

      // Location filter
      if (filterCriteria.locationFilter != null &&
          (appointment.location == null ||
              !appointment.location!
                  .toLowerCase()
                  .contains(filterCriteria.locationFilter!.toLowerCase()))) {
        return false;
      }

      return true;
    }).toList();

    // Categorize appointments
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    // Create lists to hold categorized appointments
    final List<Appointment> todayAppointmentsList = [];
    final List<Appointment> upcomingAppointmentsList = [];
    final List<Appointment> pastAppointmentsList = [];
    final List<Appointment> missedAppointmentsList = [];

    // Categorize appointments
    for (final appointment in filteredAppointments) {
      final appointmentDate = appointment.appointmentDate;
      final appointmentDay = DateTime(
          appointmentDate.year, appointmentDate.month, appointmentDate.day);

      // Check if it's a missed appointment
      if (appointment.status == AppointmentStatus.cancelled ||
          (appointmentDate.isBefore(now) &&
              appointment.status != AppointmentStatus.completed)) {
        missedAppointmentsList.add(appointment);
      }
      // Check if it's today's appointment
      else if (appointmentDate
              .isAfter(now.subtract(const Duration(hours: 2))) &&
          appointmentDay.isAtSameMomentAs(today)) {
        todayAppointmentsList.add(appointment);
      }
      // Check if it's an upcoming appointment
      else if (appointmentDate.isAfter(tomorrow)) {
        upcomingAppointmentsList.add(appointment);
      }
      // Otherwise, it's a past appointment
      else if (appointmentDate.isBefore(now)) {
        pastAppointmentsList.add(appointment);
      }
    }

    // Create AppointmentPatientCard objects for each category
    final todayAppointments =
        await _createAppointmentCards(todayAppointmentsList);
    final upcomingAppointments =
        await _createAppointmentCards(upcomingAppointmentsList);
    final pastAppointments =
        await _createAppointmentCards(pastAppointmentsList);
    final missedAppointments =
        await _createAppointmentCards(missedAppointmentsList);

    // Sort appointments by date
    todayAppointments.sort((a, b) =>
        a.appointment.appointmentDate.compareTo(b.appointment.appointmentDate));
    upcomingAppointments.sort((a, b) =>
        a.appointment.appointmentDate.compareTo(b.appointment.appointmentDate));
    pastAppointments.sort((a, b) => b.appointment.appointmentDate
        .compareTo(a.appointment.appointmentDate)); // Reverse for past
    missedAppointments.sort((a, b) => b.appointment.appointmentDate
        .compareTo(a.appointment.appointmentDate)); // Reverse for missed

    // Get viewed appointment IDs from current state if possible
    Set<String> viewedAppointmentIds = {};
    if (state is DoctorAppointmentsLoaded) {
      viewedAppointmentIds =
          (state as DoctorAppointmentsLoaded).viewedAppointmentIds;
    }

    // Emit loaded state with categorized appointments
    emit(DoctorAppointmentsLoaded(
      todayAppointments: todayAppointments,
      upcomingAppointments: upcomingAppointments,
      pastAppointments: pastAppointments,
      missedAppointments: missedAppointments,
      fromDate: fromDate,
      toDate: toDate,
      viewedAppointmentIds: viewedAppointmentIds,
      filterCriteria: filterCriteria,
    ));
  }

  Future<List<AppointmentPatientCard>> _createAppointmentCards(
      List<Appointment> appointments) async {
    final cards = <AppointmentPatientCard>[];

    for (final appointment in appointments) {
      try {
        final patient =
            await _patientRepository.getPatient(appointment.patientId);
        if (patient != null) {
          cards.add(AppointmentPatientCard(
            appointment: appointment,
            patient: patient,
          ));
        } else {
          logger.e(
              'Patient not found for appointment: ${appointment.appointmentId}');
        }
      } catch (e) {
        logger.e(
            'Error loading patient for appointment ${appointment.appointmentId}: $e');
        // Continue with other appointments
      }
    }

    return cards;
  }

  Future<void> _onUpdateAppointmentStatus(
    UpdateAppointmentStatus event,
    Emitter<DoctorAppointmentsState> emit,
  ) async {
    try {
      // Get current state
      if (state is! DoctorAppointmentsLoaded) {
        return;
      }

      final currentState = state as DoctorAppointmentsLoaded;

      // Update appointment status in the repository
      await _appointmentRepository.updateAppointmentStatus(
          event.appointmentId, event.newStatus);

      // Update all categories of appointments
      final updatedTodayAppointments = _updateAppointmentStatus(
          currentState.todayAppointments, event.appointmentId, event.newStatus);

      final updatedUpcomingAppointments = _updateAppointmentStatus(
          currentState.upcomingAppointments,
          event.appointmentId,
          event.newStatus);

      final updatedPastAppointments = _updateAppointmentStatus(
          currentState.pastAppointments, event.appointmentId, event.newStatus);

      final updatedMissedAppointments = _updateAppointmentStatus(
          currentState.missedAppointments,
          event.appointmentId,
          event.newStatus);

      // Recategorize appointments if needed
      final allAppointments = [
        ...updatedTodayAppointments,
        ...updatedUpcomingAppointments,
        ...updatedPastAppointments,
        ...updatedMissedAppointments,
      ];

      // If status changed to canceled, recategorize
      if (event.newStatus == AppointmentStatus.cancelled) {
        // Get the appointment
        final appointmentCard = allAppointments.firstWhere(
          (card) => card.appointment.appointmentId == event.appointmentId,
          orElse: () =>
              updatedTodayAppointments.first, // Fallback (shouldn't happen)
        );

        // Recategorize if needed
        final now = DateTime.now();
        if (appointmentCard.appointment.appointmentDate.isAfter(now)) {
          // Move to missed if it was upcoming
          if (updatedUpcomingAppointments.any((card) =>
              card.appointment.appointmentId == event.appointmentId)) {
            updatedUpcomingAppointments.removeWhere((card) =>
                card.appointment.appointmentId == event.appointmentId);
            updatedMissedAppointments.add(appointmentCard);
          }
        }
      }

      // Emit updated state
      emit(DoctorAppointmentsLoaded(
        todayAppointments: updatedTodayAppointments,
        upcomingAppointments: updatedUpcomingAppointments,
        pastAppointments: updatedPastAppointments,
        missedAppointments: updatedMissedAppointments,
        fromDate: currentState.fromDate,
        toDate: currentState.toDate,
        viewedAppointmentIds: currentState.viewedAppointmentIds,
        filterCriteria: currentState.filterCriteria,
      ));
    } catch (e) {
      logger.e('Error updating appointment status: $e');
      // Emit error state with message, but keep the data from current state
      if (state is DoctorAppointmentsLoaded) {
        emit(DoctorAppointmentsError(
          'Failed to update appointment status: ${e.toString()}',
        ));
      } else {
        emit(DoctorAppointmentsError(
            'Failed to update appointment: ${e.toString()}'));
      }
    }
  }

  List<AppointmentPatientCard> _updateAppointmentStatus(
    List<AppointmentPatientCard> appointments,
    String appointmentId,
    AppointmentStatus newStatus,
  ) {
    return appointments.map((appointment) {
      if (appointment.appointment.appointmentId == appointmentId) {
        return AppointmentPatientCard(
          appointment: appointment.appointment.copyWith(status: newStatus),
          patient: appointment.patient,
        );
      }
      return appointment;
    }).toList();
  }
}
