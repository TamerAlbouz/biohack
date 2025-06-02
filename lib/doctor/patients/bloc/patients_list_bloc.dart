import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:medtalk/backend/appointment/interfaces/appointment_interface.dart';
import 'package:medtalk/backend/appointment/models/appointment.dart';
import 'package:medtalk/backend/authentication/interfaces/auth_interface.dart';
import 'package:medtalk/backend/patient/interfaces/patient_interface.dart';
import 'package:medtalk/backend/patient/models/patient.dart';

part 'patients_list_event.dart';
part 'patients_list_state.dart';

@injectable
class PatientsBloc extends Bloc<PatientsEvent, PatientsState> {
  final IAuthenticationRepository _authRepository;
  final IPatientRepository _patientRepository;
  final IAppointmentRepository _appointmentRepository;
  final Logger logger;

  PatientsBloc(
    this._authRepository,
    this._patientRepository,
    this._appointmentRepository,
    this.logger,
  ) : super(PatientsInitial()) {
    on<LoadPatients>(_onLoadPatients);
    on<SearchPatients>(_onSearchPatients);
    on<SortPatients>(_onSortPatients);
  }

  Future<void> _onLoadPatients(
    LoadPatients event,
    Emitter<PatientsState> emit,
  ) async {
    try {
      emit(PatientsLoading());

      // Get current doctor ID
      final currentUser = _authRepository.currentUser;

      // Get all appointments for this doctor
      final appointments =
          await _appointmentRepository.getDoctorAppointments(currentUser.uid);

      // Extract unique patient IDs
      final patientIds = appointments.map((e) => e.patientId).toSet().toList();

      // Fetch patients
      final List<Patient> patients = [];
      final Map<String, Appointment> upcomingAppointments = {};
      final now = DateTime.now();

      for (final id in patientIds) {
        try {
          final patient = await _patientRepository.getPatient(id);
          if (patient != null) {
            patients.add(patient);

            // Find next appointment for this patient
            final patientAppointments = appointments
                .where(
                    (a) => a.patientId == id && a.appointmentDate.isAfter(now))
                .toList();

            if (patientAppointments.isNotEmpty) {
              patientAppointments.sort(
                  (a, b) => a.appointmentDate.compareTo(b.appointmentDate));
              upcomingAppointments[id] = patientAppointments.first;
            }
          }
        } catch (e) {
          addError(e);
        }
      }

      // Apply filter
      final filteredPatients =
          _applyFilter(patients, appointments, event.filter);

      // Apply default sort
      final sortedPatients = _sortPatients(filteredPatients, SortOrder.nameAsc);

      emit(PatientsLoaded(
        patients: sortedPatients,
        upcomingAppointments: upcomingAppointments,
        currentFilter: event.filter,
      ));
    } catch (e) {
      addError(e);
      emit(PatientsError(e.toString()));
    }
  }

  Future<void> _onSearchPatients(
    SearchPatients event,
    Emitter<PatientsState> emit,
  ) async {
    if (state is PatientsLoaded) {
      final currentState = state as PatientsLoaded;
      final query = event.query.toLowerCase();

      if (query.isEmpty) {
        emit(PatientsLoaded(
          patients: currentState.patients,
          upcomingAppointments: currentState.upcomingAppointments,
          currentFilter: currentState.currentFilter,
          currentSortOrder: currentState.currentSortOrder,
        ));
        return;
      }

      final filteredPatients = currentState.patients.where((patient) {
        final name = patient.name?.toLowerCase() ?? '';
        final email = patient.email.toLowerCase() ?? '';

        return name.contains(query) || email.contains(query);
      }).toList();

      emit(PatientsLoaded(
        patients: filteredPatients,
        upcomingAppointments: currentState.upcomingAppointments,
        currentFilter: currentState.currentFilter,
        currentSortOrder: currentState.currentSortOrder,
      ));
    }
  }

  Future<void> _onSortPatients(
    SortPatients event,
    Emitter<PatientsState> emit,
  ) async {
    if (state is PatientsLoaded) {
      final currentState = state as PatientsLoaded;
      final patients = List<Patient>.from(currentState.patients);

      final sortedPatients = _sortPatients(patients, event.sortOrder);

      emit(PatientsLoaded(
        patients: sortedPatients,
        upcomingAppointments: currentState.upcomingAppointments,
        currentFilter: currentState.currentFilter,
        currentSortOrder: event.sortOrder,
      ));
    }
  }

  List<Patient> _applyFilter(
    List<Patient> patients,
    List<Appointment> appointments,
    PatientFilter filter,
  ) {
    final now = DateTime.now();

    switch (filter) {
      case PatientFilter.all:
        return patients;

      case PatientFilter.recent:
        // Find patients with appointments in the last 30 days
        final recentPatientIds = appointments
            .where((a) => a.appointmentDate
                .isAfter(now.subtract(const Duration(days: 30))))
            .map((a) => a.patientId)
            .toSet();

        return patients
            .where((patient) => recentPatientIds.contains(patient.uid))
            .toList();

      case PatientFilter.upcoming:
        // Find patients with upcoming appointments
        final upcomingPatientIds = appointments
            .where((a) => a.appointmentDate.isAfter(now))
            .map((a) => a.patientId)
            .toSet();

        return patients
            .where((patient) => upcomingPatientIds.contains(patient.uid))
            .toList();

      case PatientFilter.newPatients:
        // Find patients who've had their first appointment in the last 60 days
        final patientFirstAppointments = <String, DateTime>{};

        for (final appointment in appointments) {
          final patientId = appointment.patientId;
          final appointmentDate = appointment.appointmentDate;

          if (!patientFirstAppointments.containsKey(patientId) ||
              appointmentDate.isBefore(patientFirstAppointments[patientId]!)) {
            patientFirstAppointments[patientId] = appointmentDate;
          }
        }

        final newPatientIds = patientFirstAppointments.entries
            .where((entry) =>
                entry.value.isAfter(now.subtract(const Duration(days: 60))))
            .map((entry) => entry.key)
            .toSet();

        return patients
            .where((patient) => newPatientIds.contains(patient.uid))
            .toList();

      case PatientFilter.highValue:
        // Calculate total revenue per patient
        final patientRevenue = <String, double>{};

        for (final appointment in appointments) {
          final patientId = appointment.patientId;
          patientRevenue[patientId] =
              (patientRevenue[patientId] ?? 0) + appointment.fee;
        }

        // Get the top 20% of patients by revenue
        final sortedByRevenue = patients.toList()
          ..sort((a, b) => (patientRevenue[b.uid] ?? 0)
              .compareTo(patientRevenue[a.uid] ?? 0));

        final topCount = (patients.length * 0.2).ceil();
        return sortedByRevenue.take(topCount).toList();
    }
  }

  List<Patient> _sortPatients(List<Patient> patients, SortOrder sortOrder) {
    switch (sortOrder) {
      case SortOrder.nameAsc:
        return patients..sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));

      case SortOrder.nameDesc:
        return patients..sort((a, b) => (b.name ?? '').compareTo(a.name ?? ''));

      case SortOrder.recentVisit:
        // This would require appointment data, so in practice you'd pass in a patientLastVisit map
        // For now, we'll just return the patients in the original order
        return patients;

      case SortOrder.revenue:
        // This would require revenue data, so in practice you'd pass in a patientRevenue map
        // For now, we'll just return the patients in the original order
        return patients;
    }
  }
}
