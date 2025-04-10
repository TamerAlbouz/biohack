part of 'patients_list_bloc.dart';

enum PatientFilter { all, recent, upcoming, newPatients, highValue }

enum SortOrder { nameAsc, nameDesc, recentVisit, revenue }

// Events
abstract class PatientsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadPatients extends PatientsEvent {
  final PatientFilter filter;

  LoadPatients(this.filter);

  @override
  List<Object?> get props => [filter];
}

class SearchPatients extends PatientsEvent {
  final String query;

  SearchPatients(this.query);

  @override
  List<Object?> get props => [query];
}

class SortPatients extends PatientsEvent {
  final SortOrder sortOrder;

  SortPatients(this.sortOrder);

  @override
  List<Object?> get props => [sortOrder];
}
