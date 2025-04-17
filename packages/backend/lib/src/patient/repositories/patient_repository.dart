import 'package:backend/src/extensions/object.dart';
import 'package:backend/src/patient/exceptions/patient_exception.dart';
import 'package:backend/src/user/repositories/user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:p_logger/p_logger.dart';

import '../../../backend.dart';

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
      throw PatientException.fromCode(e.code);
    } catch (e) {
      logger.e(e);
      rethrow;
    }
  }

  @override
  Future<void> addPatient(Patient patient) {
    try {
      return _userCollection.doc(patient.uid).set(patient.toMap);
    } on FirebaseException catch (e) {
      logger.e(e.message);
      throw PatientException.fromCode(e.code);
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
      throw PatientException.fromCode(e.code);
    } catch (e) {
      logger.e(e);
      rethrow;
    }
  }

  @override
  Future<List<SavedCreditCard>?> getCreditCards(String id) {
    try {
      return _userCollection.doc(id).get().then((snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data()!.toMap();
          final creditCards = data['savedCreditCards'] as List<dynamic>?;

          if (creditCards != null) {
            return creditCards.map((e) => SavedCreditCard.fromJson(e)).toList();
          }
        }

        return [];
      });
    } on FirebaseException catch (e) {
      logger.e(e.message);
      throw PatientException.fromCode(e.code);
    } catch (e) {
      logger.e(e);
      rethrow;
    }
  }

  // check email exists
  @override
  Future<bool> checkEmailExists(String email) async {
    try {
      final snapshot =
          await _userCollection.where('email', isEqualTo: email).limit(1).get();

      return snapshot.docs.isNotEmpty;
    } on FirebaseException catch (e) {
      logger.e(e.message);
      throw PatientException.fromCode(e.code);
    } catch (e) {
      logger.e(e);
      rethrow;
    }
  }
}
