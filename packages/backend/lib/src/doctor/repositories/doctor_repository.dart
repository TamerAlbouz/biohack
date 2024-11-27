import 'package:backend/src/doctor/interfaces/doctor_interface.dart';
import 'package:backend/src/doctor/models/doctor.dart';
import 'package:backend/src/extensions/object.dart';
import 'package:backend/src/user/repositories/user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:p_logger/p_logger.dart';

import '../exceptions/doctor_exception.dart';

@LazySingleton(as: IDoctorRepository)
class DoctorRepository extends UserRepository implements IDoctorRepository {
  final FirebaseFirestore _firestore;
  late final CollectionReference _userCollection;

  DoctorRepository(this._firestore) {
    _userCollection = _firestore.collection('doctors');
  }

  @override
  Future<Doctor?> getDoctor(String id) {
    try {
      return _userCollection.doc(id).get().then((snapshot) {
        if (snapshot.exists) {
          return Doctor.fromMap(id, snapshot.data()!.toMap());
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
      return _userCollection.doc(doctor.uid).set(doctor.toMap);
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
      return _userCollection.doc(doctor.uid).update(doctor.toMap);
    } on FirebaseException catch (e) {
      logger.e(e.message);
      throw DoctorException.fromCode(e.code);
    } catch (e) {
      logger.e(e);
      rethrow;
    }
  }
}
