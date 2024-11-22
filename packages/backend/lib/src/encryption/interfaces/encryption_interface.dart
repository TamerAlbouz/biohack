import 'package:backend/backend.dart';

abstract class IEncryptionRepository {
  Future<PrivateKeyEncryptionResult?> getEncryptedData(String id);

  Future<void> addEncryptionData(String uid, PrivateKeyEncryptionResult data);

  Future<void> updateEncryptionData(
      String uid, PrivateKeyEncryptionResult data);
}
