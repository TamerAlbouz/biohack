import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:medtalk/backend/appointment/enums/appointment_status.dart';
import 'package:medtalk/backend/appointment/interfaces/appointment_interface.dart';
import 'package:medtalk/backend/appointment/models/appointment.dart';
import 'package:medtalk/backend/extensions/object.dart';

@LazySingleton(as: IAppointmentRepository)
class AppointmentRepository implements IAppointmentRepository {
  final FirebaseFirestore _firestore;
  late final CollectionReference _appointmentCollection;
  final Logger logger;

  AppointmentRepository(this._firestore, this.logger) {
    _appointmentCollection = _firestore.collection('appointments');
  }

  @override
  Future<Appointment?> getPatientAppointmentLatest(String patientId) async {
    try {
      // get the appointment by patientId. only the one with the latest date
      final doc = await _appointmentCollection
          .where('patientId', isEqualTo: patientId)
          .orderBy('appointmentDate', descending: false)
          .limit(1)
          .get()
          .then((query) => query.docs.isNotEmpty ? query.docs.first : null);

      if (doc != null) {
        return Appointment.fromMap(doc.id, doc.data()!.toMap());
      }
      return null;
    } catch (e) {
      logger.e('Error getting appointment: $e');
      rethrow;
    }
  }

  @override
  Future<List<Appointment>> getDoctorAppointments(String doctorId) async {
    try {
      final query = await _appointmentCollection
          .where('doctorId', isEqualTo: doctorId)
          .get();

      return query.docs
          .map((doc) => Appointment.fromMap(doc.id, doc.data().toMap()))
          .toList();
    } catch (e) {
      logger.e('Error getting doctor appointments: $e');
      rethrow;
    }
  }

  @override
  Future<List<Appointment>> getPatientAppointments(String patientId) async {
    try {
      final query = await _appointmentCollection
          .where('patientId', isEqualTo: patientId)
          .get();

      return query.docs
          .map((doc) => Appointment.fromMap(doc.id, doc.data().toMap()))
          .toList();
    } catch (e) {
      logger.e('Error getting patient appointments: $e');
      rethrow;
    }
  }

  @override
  Future<void> createAppointment(Appointment appointment) async {
    try {
      await _appointmentCollection.add(appointment.toMap());
    } catch (e) {
      logger.e('Error creating appointment: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateAppointment(Appointment appointment) async {
    try {
      await _appointmentCollection
          .doc(appointment.appointmentId)
          .update(appointment.toMap());
    } catch (e) {
      logger.e('Error updating appointment: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateAppointmentStatus(
      String appointmentId, AppointmentStatus status) async {
    try {
      await _appointmentCollection.doc(appointmentId).update({
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      logger.e('Error updating appointment status: $e');
      rethrow;
    }
  }

  @override
  Future<void> cancelAppointment(String appointmentId) async {
    try {
      await _appointmentCollection.doc(appointmentId).update({
        'status': AppointmentStatus.cancelled.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      logger.e('Error cancelling appointment: $e');
      rethrow;
    }
  }
}
