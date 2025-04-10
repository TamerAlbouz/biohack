// doctor_dashboard_state.dart
part of 'doctor_dashboard_bloc.dart';

abstract class DoctorDashboardState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DoctorDashboardInitial extends DoctorDashboardState {}

class DoctorDashboardLoading extends DoctorDashboardState {}

class DoctorDashboardLoaded extends DoctorDashboardState {
  final String doctorName;
  final int totalPatients;
  final int totalAppointments;
  final double completionRate;
  final List<Patient> recentPatients;

  DoctorDashboardLoaded({
    required this.doctorName,
    required this.totalPatients,
    required this.totalAppointments,
    required this.completionRate,
    required this.recentPatients,
  });

  @override
  List<Object?> get props => [
        doctorName,
        totalPatients,
        totalAppointments,
        completionRate,
        recentPatients,
      ];
}

class DoctorDashboardError extends DoctorDashboardState {
  final String message;

  DoctorDashboardError(this.message);

  @override
  List<Object> get props => [message];
}
