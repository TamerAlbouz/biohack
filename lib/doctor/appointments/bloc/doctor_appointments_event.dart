part of 'doctor_appointments_bloc.dart';

abstract class DoctorAppointmentsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event to load all doctor appointments
class LoadDoctorAppointments extends DoctorAppointmentsEvent {}

/// Event to filter doctor appointments by date range
class FilterDoctorAppointments extends DoctorAppointmentsEvent {
  final DateTime? fromDate;
  final DateTime? toDate;

  FilterDoctorAppointments({
    this.fromDate,
    this.toDate,
  });

  @override
  List<Object?> get props => [fromDate, toDate];
}

/// Event to update appointment status
class UpdateAppointmentStatus extends DoctorAppointmentsEvent {
  final String appointmentId;
  final AppointmentStatus newStatus;

  UpdateAppointmentStatus({
    required this.appointmentId,
    required this.newStatus,
  });

  @override
  List<Object?> get props => [appointmentId, newStatus];
}

/// Event to mark an appointment as viewed (for badge system)
class MarkAppointmentViewed extends DoctorAppointmentsEvent {
  final String appointmentId;

  MarkAppointmentViewed({
    required this.appointmentId,
  });

  @override
  List<Object?> get props => [appointmentId];
}

/// Event to clear all viewed badges
class ClearAllViewedBadges extends DoctorAppointmentsEvent {}
