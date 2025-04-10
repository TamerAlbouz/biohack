part of 'doctor_appointments_bloc.dart';

abstract class DoctorAppointmentsState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Initial state
class DoctorAppointmentsInitial extends DoctorAppointmentsState {}

/// Loading state
class DoctorAppointmentsLoading extends DoctorAppointmentsState {}

class DoctorAppointmentsLoaded extends DoctorAppointmentsState {
  final List<AppointmentPatientCard> todayAppointments;
  final List<AppointmentPatientCard> upcomingAppointments;
  final List<AppointmentPatientCard> pastAppointments;
  final List<AppointmentPatientCard> missedAppointments;
  final DateTime? fromDate;
  final DateTime? toDate;
  final Set<String> viewedAppointmentIds;
  final AppointmentFilterCriteria filterCriteria;

  DoctorAppointmentsLoaded({
    required this.todayAppointments,
    required this.upcomingAppointments,
    required this.pastAppointments,
    required this.missedAppointments,
    this.fromDate,
    this.toDate,
    Set<String>? viewedAppointmentIds,
    this.filterCriteria = const AppointmentFilterCriteria(),
  }) : viewedAppointmentIds = viewedAppointmentIds ?? {};

  @override
  List<Object?> get props => [
        todayAppointments,
        upcomingAppointments,
        pastAppointments,
        missedAppointments,
        fromDate,
        toDate,
        viewedAppointmentIds,
        filterCriteria,
      ];

  DoctorAppointmentsLoaded copyWith({
    List<AppointmentPatientCard>? todayAppointments,
    List<AppointmentPatientCard>? upcomingAppointments,
    List<AppointmentPatientCard>? pastAppointments,
    List<AppointmentPatientCard>? missedAppointments,
    DateTime? fromDate,
    DateTime? toDate,
    Set<String>? viewedAppointmentIds,
    AppointmentFilterCriteria? filterCriteria,
  }) {
    return DoctorAppointmentsLoaded(
      todayAppointments: todayAppointments ?? this.todayAppointments,
      upcomingAppointments: upcomingAppointments ?? this.upcomingAppointments,
      pastAppointments: pastAppointments ?? this.pastAppointments,
      missedAppointments: missedAppointments ?? this.missedAppointments,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      viewedAppointmentIds: viewedAppointmentIds ?? this.viewedAppointmentIds,
      filterCriteria: filterCriteria ?? this.filterCriteria,
    );
  }

  int get unviewedAppointmentsCount {
    return upcomingAppointments
        .where((appointment) => !viewedAppointmentIds
            .contains(appointment.appointment.appointmentId))
        .length;
  }

  int get unviewedMissedCount {
    return missedAppointments
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

/// Filter criteria class
class AppointmentFilterCriteria extends Equatable {
  final DateTime? fromDate;
  final DateTime? toDate;
  final List<AppointmentStatus>? statusFilter;
  final String? patientNameFilter;
  final String? serviceNameFilter;
  final String? locationFilter;

  const AppointmentFilterCriteria({
    this.fromDate,
    this.toDate,
    this.statusFilter,
    this.patientNameFilter,
    this.serviceNameFilter,
    this.locationFilter,
  });

  AppointmentFilterCriteria copyWith({
    DateTime? fromDate,
    DateTime? toDate,
    List<AppointmentStatus>? statusFilter,
    String? patientNameFilter,
    String? serviceNameFilter,
    String? locationFilter,
    bool clearFromDate = false,
    bool clearToDate = false,
    bool clearStatusFilter = false,
    bool clearPatientNameFilter = false,
    bool clearServiceNameFilter = false,
    bool clearLocationFilter = false,
  }) {
    return AppointmentFilterCriteria(
      fromDate: clearFromDate ? null : fromDate ?? this.fromDate,
      toDate: clearToDate ? null : toDate ?? this.toDate,
      statusFilter:
          clearStatusFilter ? null : statusFilter ?? this.statusFilter,
      patientNameFilter: clearPatientNameFilter
          ? null
          : patientNameFilter ?? this.patientNameFilter,
      serviceNameFilter: clearServiceNameFilter
          ? null
          : serviceNameFilter ?? this.serviceNameFilter,
      locationFilter:
          clearLocationFilter ? null : locationFilter ?? this.locationFilter,
    );
  }

  bool get hasActiveFilters =>
      fromDate != null ||
      toDate != null ||
      statusFilter != null ||
      patientNameFilter != null ||
      serviceNameFilter != null ||
      locationFilter != null;

  @override
  List<Object?> get props => [
        fromDate,
        toDate,
        statusFilter,
        patientNameFilter,
        serviceNameFilter,
        locationFilter,
      ];
}
