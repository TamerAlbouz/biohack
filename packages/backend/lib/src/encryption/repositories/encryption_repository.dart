import 'package:backend/src/encryption/exceptions/encryption_exception.dart';
import 'package:backend/src/extensions/object.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:p_logger/p_logger.dart';

import '../../../backend.dart';

@LazySingleton(as: IEncryptionRepository)
class EncryptionRepository implements IEncryptionRepository {
  final FirebaseFirestore _firestore;
  late final CollectionReference _encryptionRepository;

  EncryptionRepository(this._firestore) {
    _encryptionRepository = _firestore.collection('encryption');
  }

  @override
  Future<void> addEncryptionData(String uid, PrivateKeyEncryptionResult data) {
    try {
      return _encryptionRepository.doc(uid).set(data.toMap);
    } on FirebaseException catch (e) {
      logger.e(e.message);
      throw EncryptionException.fromCode(e.code);
    } catch (e) {
      logger.e(e);
      rethrow;
    }
  }

  @override
  Future<PrivateKeyEncryptionResult?> getEncryptedData(String id) {
    try {
      return _encryptionRepository.doc(id).get().then((snapshot) {
        if (snapshot.exists) {
          return PrivateKeyEncryptionResult.fromMap(snapshot.data()!.toMap());
        }

        return null;
      });
    } on FirebaseException catch (e) {
      logger.e(e.message);
      throw EncryptionException.fromCode(e.code);
    } catch (e) {
      logger.e(e);
      rethrow;
    }
  }

  @override
  Future<void> updateEncryptionData(
      String uid, PrivateKeyEncryptionResult data) {
    try {
      return _encryptionRepository.doc(uid).update(data.toMap);
    } on FirebaseException catch (e) {
      logger.e(e.message);
      throw EncryptionException.fromCode(e.code);
    } catch (e) {
      logger.e(e);
      rethrow;
    }
  }
}
