part of 'doctor_appointments_bloc.dart';

abstract class DoctorAppointmentsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event to load all doctor appointments
class LoadDoctorAppointments extends DoctorAppointmentsEvent {}

/// Event to apply comprehensive filtering to appointments
class FilterAppointments extends DoctorAppointmentsEvent {
  final AppointmentFilterCriteria filterCriteria;

  FilterAppointments({
    required this.filterCriteria,
  });

  @override
  List<Object?> get props => [filterCriteria];
}

/// Event to filter doctor appointments by date range (legacy support)
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

/// Event to reset all filters
class ResetFilters extends DoctorAppointmentsEvent {}

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

/// Event to clear viewed badges for a specific tab
class ClearTabViewedBadges extends DoctorAppointmentsEvent {
  final AppointmentTab tab;

  ClearTabViewedBadges({
    required this.tab,
  });

  @override
  List<Object?> get props => [tab];
}

/// Appointment tab enum
enum AppointmentTab { today, upcoming, past, missed }
