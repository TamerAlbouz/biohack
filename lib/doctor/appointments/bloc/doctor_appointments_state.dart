part of 'doctor_appointments_bloc.dart';

abstract class DoctorAppointmentsState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Initial state
class DoctorAppointmentsInitial extends DoctorAppointmentsState {}

/// Loading state
class DoctorAppointmentsLoading extends DoctorAppointmentsState {}

// Update the DoctorAppointmentsLoaded state in doctor_appointments_state.dart
class DoctorAppointmentsLoaded extends DoctorAppointmentsState {
  final List<AppointmentPatientCard> todayAppointments;
  final List<AppointmentPatientCard> upcomingAppointments;
  final DateTime? fromDate;
  final DateTime? toDate;
  final Set<String> viewedAppointmentIds; // Track viewed appointments

  DoctorAppointmentsLoaded({
    required this.todayAppointments,
    required this.upcomingAppointments,
    this.fromDate,
    this.toDate,
    Set<String>? viewedAppointmentIds,
  }) : viewedAppointmentIds = viewedAppointmentIds ?? {};

  @override
  List<Object?> get props => [
        todayAppointments,
        upcomingAppointments,
        fromDate,
        toDate,
        viewedAppointmentIds,
      ];

  DoctorAppointmentsLoaded copyWith({
    List<AppointmentPatientCard>? todayAppointments,
    List<AppointmentPatientCard>? upcomingAppointments,
    DateTime? fromDate,
    DateTime? toDate,
    Set<String>? viewedAppointmentIds,
  }) {
    return DoctorAppointmentsLoaded(
      todayAppointments: todayAppointments ?? this.todayAppointments,
      upcomingAppointments: upcomingAppointments ?? this.upcomingAppointments,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      viewedAppointmentIds: viewedAppointmentIds ?? this.viewedAppointmentIds,
    );
  }

  int get unviewedAppointmentsCount {
    return upcomingAppointments
        .where((appointment) => !viewedAppointmentIds
            .contains(appointment.appointment.appointmentId))
        .length;
  }

  bool isAppointmentViewed(String appointmentId) {
    return viewedAppointmentIds.contains(appointmentId);
  }
}

/// Error state
class DoctorAppointmentsError extends DoctorAppointmentsState {
  final String message;

  DoctorAppointmentsError(this.message);

  @override
  List<Object> get props => [message];
}
