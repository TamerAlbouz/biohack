import 'package:backend/backend.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:p_logger/p_logger.dart';

part 'doctor_dashboard_event.dart';
part 'doctor_dashboard_state.dart';

class DoctorDashboardBloc
    extends Bloc<DoctorDashboardEvent, DoctorDashboardState> {
  final IAuthenticationRepository _authRepository;
  final IAppointmentRepository _appointmentRepository;
  final IPatientRepository _patientRepository;

  DoctorDashboardBloc(
    this._authRepository,
    this._appointmentRepository,
    this._patientRepository,
  ) : super(DoctorDashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DoctorDashboardState> emit,
  ) async {
    try {
      emit(DoctorDashboardLoading());

      // Get current doctor ID and info
      final currentUser = _authRepository.currentUser;

      // Get doctor's appointment statistics
      final appointments =
          await _appointmentRepository.getDoctorAppointments(currentUser.uid);

      // Calculate completion rate (completed appointments / total appointments)
      final completedAppointments = appointments
          .where((appointment) =>
              appointment.status == AppointmentStatus.completed)
          .length;

      final completionRate = appointments.isEmpty
          ? 0.0
          : (completedAppointments / appointments.length) * 100;

      // Get recent patients (patients with recent appointments)
      final patientIds =
          appointments.map((appointment) => appointment.patientId).toSet();

      final recentPatients = <Patient>[];

      // Get details for up to 10 recent patients
      for (final patientId in patientIds.take(10)) {
        final patient = await _patientRepository.getPatient(patientId);
        if (patient != null) {
          // Find the most recent appointment date for this patient
          appointments.where((a) => a.patientId == patientId).reduce(
              (a, b) => a.appointmentDate.isAfter(b.appointmentDate) ? a : b);

          // Add last visit date to patient
          recentPatients.add(patient.copyWith());
        }
      }

      // Get total patient count
      final totalPatients = patientIds.length;

      emit(DoctorDashboardLoaded(
        doctorName: currentUser.name!,
        totalPatients: totalPatients,
        totalAppointments: appointments.length,
        completionRate: completionRate,
        recentPatients: recentPatients,
      ));
    } catch (e) {
      logger.e('Error loading dashboard data: $e');
      emit(DoctorDashboardError(e.toString()));
    }
  }
}
