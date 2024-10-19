import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/src/extensions/object.dart';
import 'package:injectable/injectable.dart';
import 'package:models/models.dart';
import 'package:p_logger/p_logger.dart';

import '../interfaces/appointment_interface.dart';

@LazySingleton(as: IAppointmentRepository)
class AppointmentRepository implements IAppointmentRepository {
  final FirebaseFirestore _firestore;
  late final CollectionReference _appointmentCollection;

  AppointmentRepository(this._firestore) {
    _appointmentCollection = _firestore.collection('appointments');
  }

  @override
  Stream<List<Appointment>> getAppointments() {
    try {
      return _appointmentCollection.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return Appointment.fromMap(doc.data().toMap());
        }).toList();
      });
    } on FirebaseException catch (e) {
      logger.e(e.message);
      rethrow;
    } catch (e) {
      logger.e(e);
      rethrow;
    }
  }

  @override
  Stream<Appointment> getAppointment(String appointmentId) {
    try {
      return _appointmentCollection.doc(appointmentId).snapshots().map((doc) {
        return Appointment.fromMap(doc.data().toMap());
      });
    } on FirebaseException catch (e) {
      logger.e(e.message);
      rethrow;
    } catch (e) {
      logger.e(e);
      rethrow;
    }
  }

  @override
  Future<void> addAppointment(Appointment appointment) {
    try {
      return _appointmentCollection.add(appointment.toMap());
    } on FirebaseException catch (e) {
      logger.e(e.message);
      // return empty future
      rethrow;
    } catch (e) {
      logger.e(e);
      rethrow;
    }
  }

  @override
  Future<void> updateAppointment(Appointment appointment) {
    try {
      return _appointmentCollection
          .doc(appointment.appointmentId)
          .update(appointment.toMap());
    } on FirebaseException catch (e) {
      logger.e(e.message);
      // return empty future
      rethrow;
    } catch (e) {
      logger.e(e);
      rethrow;
    }
  }

  @override
  Future<void> deleteAppointment(String appointmentId) {
    try {
      return _appointmentCollection.doc(appointmentId).delete();
    } on FirebaseException catch (e) {
      logger.e(e.message);
      // return empty future
      rethrow;
    } catch (e) {
      logger.e(e);
      rethrow;
    }
  }
}
