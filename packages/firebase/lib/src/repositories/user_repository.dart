import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:models/models.dart';
import 'package:p_logger/p_logger.dart';

import '../../firebase.dart';

@LazySingleton(as: IUserInterface)
class UserRepository implements IUserInterface {
  final FirebaseFirestore _firestore;
  late final CollectionReference _doctors;
  late final CollectionReference _patients;

  UserRepository(this._firestore) {
    _doctors = _firestore.collection('doctors');
    _patients = _firestore.collection('patients');
  }

  @override
  Stream<IUser?> getUser(String userId) {
    try {
      return _doctors.doc(userId).snapshots().map((doc) {
        if (doc.exists) {
          // return Patient.fromMap(
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
}
