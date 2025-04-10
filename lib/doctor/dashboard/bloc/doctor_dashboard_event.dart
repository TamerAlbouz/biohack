// doctor_dashboard_event.dart
part of 'doctor_dashboard_bloc.dart';

abstract class DoctorDashboardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadDashboardData extends DoctorDashboardEvent {}
