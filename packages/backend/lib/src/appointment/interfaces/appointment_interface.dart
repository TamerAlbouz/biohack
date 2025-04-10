import 'package:backend/backend.dart';

abstract class IAppointmentRepository {
  /// Get a specific appointment by Patient ID
  Future<Appointment?> getPatientAppointmentLatest(String id);

  /// Get all appointments for a specific doctor
  Future<List<Appointment>> getDoctorAppointments(String doctorId);

  /// Get all appointments for a specific patient
  Future<List<Appointment>> getPatientAppointments(String patientId);

  /// Create a new appointment
  Future<void> createAppointment(Appointment appointment);

  /// Update an existing appointment
  Future<void> updateAppointment(Appointment appointment);

  /// Update only the status of an appointment
  Future<void> updateAppointmentStatus(
      String appointmentId, AppointmentStatus status);

  /// Cancel an appointment
  Future<void> cancelAppointment(String appointmentId);
}
