import 'package:models/models.dart';

abstract class IAppointmentRepository {
  /// Stream of [Appointment] which will emit a list of appointments.
  ///
  /// Emits an empty list if there are no appointments.
  Stream<List<Appointment>> getAppointments();

  /// Stream of [Appointment] which will emit the appointment with the given [appointmentId].
  ///
  /// Emits an empty stream if the appointment is not found.
  Stream<Appointment> getAppointment(String appointmentId);

  /// Adds a new appointment to the collection.
  ///
  /// Throws a [FirebaseException] if an exception occurs.
  Future<void> addAppointment(Appointment appointment);

  /// Updates the appointment with the given [appointmentId].
  ///
  /// Throws a [FirebaseException] if an exception occurs.
  Future<void> updateAppointment(Appointment appointment);

  /// Deletes the appointment with the given [appointmentId].
  ///
  /// Throws a [FirebaseException] if an exception occurs.
  Future<void> deleteAppointment(String appointmentId);
}
