import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/src/repositories/user_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:models/models.dart';
import 'package:p_logger/p_logger.dart';

import '../../firebase.dart';

@LazySingleton(as: IPatientInterface)
class PatientRepository extends UserRepository implements IPatientInterface {
  final FirebaseFirestore _firestore;
  late final CollectionReference _userCollection;

  PatientRepository(this._firestore) : super(_firestore) {
    _userCollection = _firestore.collection('patients');
  }

  @override
  Future<void> addPatient(Patient patient) {
    try {
      return _userCollection.doc(patient.uid).set(patient.toMap);
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
      return _userCollection.doc(patient.uid).update(patient.toMap);
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
