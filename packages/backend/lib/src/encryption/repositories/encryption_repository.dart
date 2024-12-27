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
  Future<void> addEncryptionData(
      String uid, List<PrivateKeyEncryptionResult> data) {
    try {
      return _encryptionRepository.doc(uid).set({
        'data': data.map((e) => e.toJson()).toList(),
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
  Future<List<PrivateKeyEncryptionResult>?> getEncryptedData(String id) {
    try {
      return _encryptionRepository.doc(id).get().then((snapshot) {
        if (snapshot.exists) {
          return List<PrivateKeyEncryptionResult>.from(
            (snapshot.data() as Map<String, dynamic>)['data']
                .map((e) => PrivateKeyEncryptionResult.fromJson(e)),
          );
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
      String uid, List<PrivateKeyEncryptionResult> data) {
    try {
      // merge: true will only update the fields that are different
      return _encryptionRepository.doc(uid).set(
          {'data': data.map((e) => e.toJson()).toList()},
          SetOptions(merge: true));
    } on FirebaseException catch (e) {
      logger.e(e.message);
      throw EncryptionException.fromCode(e.code);
    } catch (e) {
      logger.e(e);
      rethrow;
    }
  }
}
