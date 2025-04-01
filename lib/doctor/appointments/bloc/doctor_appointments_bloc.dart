import 'package:backend/backend.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:medtalk/doctor/appointments/models/appointment_card.dart';
import 'package:p_logger/p_logger.dart';

part 'doctor_appointments_event.dart';
part 'doctor_appointments_state.dart';

class DoctorAppointmentsBloc
    extends Bloc<DoctorAppointmentsEvent, DoctorAppointmentsState> {
  final IAppointmentRepository _appointmentRepository;
  final IAuthenticationRepository _authRepository;
  final IPatientRepository _patientRepository;

  DoctorAppointmentsBloc(
    this._appointmentRepository,
    this._authRepository,
    this._patientRepository,
  ) : super(DoctorAppointmentsInitial()) {
    on<LoadDoctorAppointments>(_onLoadDoctorAppointments);
    on<FilterDoctorAppointments>(_onFilterDoctorAppointments);
    on<UpdateAppointmentStatus>(_onUpdateAppointmentStatus);
    on<MarkAppointmentViewed>(_onMarkAppointmentViewed);
    on<ClearAllViewedBadges>(_onClearAllViewedBadges);
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
      final allAppointmentIds = currentState.upcomingAppointments
          .map((appointment) => appointment.appointment.appointmentId as String)
          .toSet();

      emit(currentState.copyWith(
        viewedAppointmentIds: allAppointmentIds,
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

      // Separate today's appointments and upcoming appointments
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));

      final List<AppointmentPatientCard> todayAppointments = await Future.wait(
        appointments.where((appointment) {
          final appointmentDate = appointment.appointmentDate;
          return appointmentDate
                  .isAfter(now.subtract(const Duration(hours: 2))) &&
              appointmentDate.isBefore(tomorrow);
        }).map((appointment) async {
          final patient =
              await _patientRepository.getPatient(appointment.patientId);

          // error if patient is null
          if (patient == null) {
            logger.e(
                'Patient not found for appointment: ${appointment.appointmentId}');
            emit(DoctorAppointmentsError(
                'Patient not found for appointment: ${appointment.appointmentId}'));
          }

          return AppointmentPatientCard(
            appointment: appointment,
            patient: patient!,
          );
        }).toList(),
      );

// Sort today's appointments by time
      todayAppointments.sort((a, b) => a.appointment.appointmentDate
          .compareTo(b.appointment.appointmentDate));

      final List<AppointmentPatientCard> upcomingAppointments =
          await Future.wait(
        appointments.where((appointment) {
          return appointment.appointmentDate.isAfter(tomorrow);
        }).map((appointment) async {
          final patient =
              await _patientRepository.getPatient(appointment.patientId);

          // error if patient is null
          if (patient == null) {
            logger.e(
                'Patient not found for appointment: ${appointment.appointmentId}');
            emit(DoctorAppointmentsError(
                'Patient not found for appointment: ${appointment.appointmentId}'));
          }

          return AppointmentPatientCard(
            appointment: appointment,
            patient: patient!,
          );
        }).toList(),
      );

// Sort upcoming appointments by date
      upcomingAppointments.sort((a, b) => a.appointment.appointmentDate
          .compareTo(b.appointment.appointmentDate));

      emit(DoctorAppointmentsLoaded(
        todayAppointments: todayAppointments,
        upcomingAppointments: upcomingAppointments,
      ));
    } catch (e) {
      logger.e('Error loading doctor appointments: $e');
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

      // Apply date filters if specified
      final filteredAppointments = appointments.where((appointment) {
        if (event.fromDate != null &&
            appointment.appointmentDate.isBefore(event.fromDate!)) {
          return false;
        }
        if (event.toDate != null &&
            appointment.appointmentDate
                .isAfter(event.toDate!.add(const Duration(days: 1)))) {
          return false;
        }
        return true;
      }).toList();

      // Separate today's appointments and upcoming appointments
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));

      final List<AppointmentPatientCard> todayAppointments = await Future.wait(
        filteredAppointments.where((appointment) {
          final appointmentDate = appointment.appointmentDate;
          return appointmentDate
                  .isAfter(now.subtract(const Duration(hours: 2))) &&
              appointmentDate.isBefore(tomorrow);
        }).map((appointment) async {
          final patient =
              await _patientRepository.getPatient(appointment.patientId);

          // error if patient is null
          if (patient == null) {
            logger.e(
                'Patient not found for appointment: ${appointment.appointmentId}');
            emit(DoctorAppointmentsError(
                'Patient not found for appointment: ${appointment.appointmentId}'));
          }

          return AppointmentPatientCard(
            appointment: appointment,
            patient: patient!,
          );
        }).toList(),
      );

// Sort today's appointments by time
      todayAppointments.sort((a, b) => a.appointment.appointmentDate
          .compareTo(b.appointment.appointmentDate));

      final List<AppointmentPatientCard> upcomingAppointments =
          await Future.wait(
        filteredAppointments.where((appointment) {
          return appointment.appointmentDate.isAfter(tomorrow);
        }).map((appointment) async {
          final patient =
              await _patientRepository.getPatient(appointment.patientId);

          // error if patient is null
          if (patient == null) {
            logger.e(
                'Patient not found for appointment: ${appointment.appointmentId}');
            emit(DoctorAppointmentsError(
                'Patient not found for appointment: ${appointment.appointmentId}'));
          }

          return AppointmentPatientCard(
            appointment: appointment,
            patient: patient!,
          );
        }).toList(),
      );

// Sort upcoming appointments by date
      upcomingAppointments.sort((a, b) => a.appointment.appointmentDate
          .compareTo(b.appointment.appointmentDate));

      emit(DoctorAppointmentsLoaded(
        todayAppointments: todayAppointments,
        upcomingAppointments: upcomingAppointments,
        fromDate: event.fromDate,
        toDate: event.toDate,
      ));
    } catch (e) {
      logger.e('Error filtering doctor appointments: $e');
      emit(DoctorAppointmentsError(e.toString()));
    }
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

      final updatedTodayAppointments =
          currentState.todayAppointments.map((appointment) {
        if (appointment.appointment.appointmentId == event.appointmentId) {
          return AppointmentPatientCard(
            appointment:
                appointment.appointment.copyWith(status: event.newStatus),
            patient: appointment.patient,
          );
        }
        return appointment;
      }).toList();

      final updatedUpcomingAppointments =
          currentState.upcomingAppointments.map((appointment) {
        if (appointment.appointment.appointmentId == event.appointmentId) {
          return AppointmentPatientCard(
            appointment:
                appointment.appointment.copyWith(status: event.newStatus),
            patient: appointment.patient,
          );
        }
        return appointment;
      }).toList();

      // Emit updated state
      emit(DoctorAppointmentsLoaded(
        todayAppointments: updatedTodayAppointments,
        upcomingAppointments: updatedUpcomingAppointments,
        fromDate: currentState.fromDate,
        toDate: currentState.toDate,
      ));
    } catch (e) {
      logger.e('Error updating appointment status: $e');
      // Emit error state with message, but keep the data from current state
      if (state is DoctorAppointmentsLoaded) {
        final currentState = state as DoctorAppointmentsLoaded;
        emit(DoctorAppointmentsError(
          'Failed to update appointment status: ${e.toString()}',
        ));
      } else {
        emit(DoctorAppointmentsError(
            'Failed to update appointment: ${e.toString()}'));
      }
    }
  }
}
