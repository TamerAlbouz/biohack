import 'package:backend/backend.dart';

abstract class IEncryptionRepository {
  Future<List<PrivateKeyEncryptionResult>?> getEncryptedData(String id);

  Future<void> addEncryptionData(
      String uid, List<PrivateKeyEncryptionResult> data);

  Future<void> updateEncryptionData(
      String uid, List<PrivateKeyEncryptionResult> data);
}
