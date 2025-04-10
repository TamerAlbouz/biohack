part of 'patients_list_bloc.dart';

abstract class PatientsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PatientsInitial extends PatientsState {}

class PatientsLoading extends PatientsState {}

class PatientsLoaded extends PatientsState {
  final List<Patient> patients;
  final Map<String, Appointment> upcomingAppointments;
  final PatientFilter currentFilter;
  final SortOrder currentSortOrder;

  PatientsLoaded({
    required this.patients,
    required this.upcomingAppointments,
    this.currentFilter = PatientFilter.all,
    this.currentSortOrder = SortOrder.nameAsc,
  });

  @override
  List<Object?> get props =>
      [patients, upcomingAppointments, currentFilter, currentSortOrder];
}

class PatientsError extends PatientsState {
  final String message;

  PatientsError(this.message);

  @override
  List<Object?> get props => [message];
}
