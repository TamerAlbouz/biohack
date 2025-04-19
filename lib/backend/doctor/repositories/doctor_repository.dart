import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:medtalk/backend/doctor/interfaces/doctor_interface.dart';
import 'package:medtalk/backend/doctor/models/doctor.dart';
import 'package:medtalk/backend/extensions/object.dart';
import 'package:medtalk/backend/user/repositories/user_repository.dart';

import '../exceptions/doctor_exception.dart';

@LazySingleton(as: IDoctorRepository)
class DoctorRepository extends UserRepository implements IDoctorRepository {
  final FirebaseFirestore _firestore;
  late final CollectionReference _doctorCollection;
  final Logger logger;

  DoctorRepository(this._firestore, this.logger) {
    _doctorCollection = _firestore.collection('doctors');
  }

  @override
  Future<Doctor?> getDoctor(String id) {
    try {
      return _doctorCollection.doc(id).get().then((snapshot) async {
        if (snapshot.exists) {
          // Get doctor data
          final doctorData = snapshot.data()!.toMap();

          // Get services subcollection
          final servicesSnapshot =
              await _doctorCollection.doc(id).collection('services').get();
          final services =
              servicesSnapshot.docs.map((doc) => doc.data().toMap()).toList();

          // Add services to doctor data
          doctorData['services'] = services;

          return Doctor.fromMap(id, doctorData);
        }

        return null;
      });
    } on FirebaseException catch (e) {
      logger.e(e.message);
      throw DoctorException.fromCode(e.code);
    } catch (e) {
      logger.e(e);
      rethrow;
    }
  }

  @override
  Future<void> addDoctor(Doctor doctor) {
    try {
      return _doctorCollection.doc(doctor.uid).set(doctor.toMap);
    } on FirebaseException catch (e) {
      logger.e(e.message);
      throw DoctorException.fromCode(e.code);
    } catch (e) {
      logger.e(e);
      rethrow;
    }
  }

  @override
  Future<void> updateDoctor(Doctor doctor) {
    try {
      return _doctorCollection.doc(doctor.uid).update(doctor.toMap);
    } on FirebaseException catch (e) {
      logger.e(e.message);
      throw DoctorException.fromCode(e.code);
    } catch (e) {
      logger.e(e);
      rethrow;
    }
  }

  @override
  Future<(List<Doctor> doctors, DocumentSnapshot? lastDoc)> getDoctorsPaginated(
      int limit, DocumentSnapshot? lastDocument) {
    try {
      final weekdayName = [
        'monday',
        'tuesday',
        'wednesday',
        'thursday',
        'friday',
        'saturday',
        'sunday'
      ][DateTime.now().weekday - 1];

      var query = _doctorCollection
          .where('availability.$weekdayName', isNull: false)
          .orderBy('availability.$weekdayName')
          .orderBy(FieldPath.documentId)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      return query.get().then((snapshot) => (
            snapshot.docs
                .map((doc) => Doctor.fromMap(doc.id, doc.data().toMap()))
                .toList(),
            snapshot.docs.isNotEmpty ? snapshot.docs.last : null
          ));
    } on FirebaseException catch (e) {
      logger.e(e.message);
      throw DoctorException.fromCode(e.code);
    } catch (e) {
      logger.e(e);
      rethrow;
    }
  }

  @override
  Future<List<Doctor>> getPatientDoctors(String id) {
    try {
      return _doctorCollection
          .where('patientIds', arrayContains: id)
          .get()
          .then((snapshot) => snapshot.docs
              .map((doc) => Doctor.fromMap(doc.id, doc.data().toMap()))
              .toList());
    } on FirebaseException catch (e) {
      logger.e(e.message);
      throw DoctorException.fromCode(e.code);
    } catch (e) {
      logger.e(e);
      rethrow;
    }
  }

  // check email exist
  @override
  Future<bool> checkEmailExists(String email) async {
    try {
      final snapshot = await _doctorCollection
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } on FirebaseException catch (e) {
      logger.e(e.message);
      throw DoctorException.fromCode(e.code);
    } catch (e) {
      logger.e(e);
      rethrow;
    }
  }
}
