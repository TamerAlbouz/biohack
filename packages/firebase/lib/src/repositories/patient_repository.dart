import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/src/extensions/object.dart';
import 'package:firebase/src/repositories/user_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:models/models.dart';
import 'package:p_logger/p_logger.dart';

import '../../firebase.dart';

@LazySingleton(as: IPatientRepository)
class PatientRepository extends UserRepository implements IPatientRepository {
  final FirebaseFirestore _firestore;
  late final CollectionReference _userCollection;

  PatientRepository(this._firestore) {
    _userCollection = _firestore.collection('patients');
  }

  @override
  Future<Patient?> getPatient(String id) {
    try {
      return _userCollection.doc(id).get().then((snapshot) {
        if (snapshot.exists) {
          return Patient.fromMap(id, snapshot.data()!.toMap());
        }

        return null;
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
  Future<void> addPatient(Patient patient) {
    try {
      return _userCollection.doc(patient.uid).set(patient.toJson());
    } on FirebaseException catch (e) {
      logger.e(e.message);
      rethrow;
    } catch (e) {
      logger.e(e);
      rethrow;
    }
  }

  @override
  Future<void> updatePatient(Patient patient) {
    try {
      return _userCollection.doc(patient.uid).update(patient.toJson());
    } on FirebaseException catch (e) {
      logger.e(e.message);
      // return empty future
      rethrow;
    } catch (e) {
      logger.e(e);
      rethrow;
    }

    return Future.value();
  }
}
