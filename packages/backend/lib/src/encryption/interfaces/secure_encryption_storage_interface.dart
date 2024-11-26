import '../../../backend.dart';
import '../models/crypto_result.dart';

abstract class ISecureEncryptionStorage {
  Future<PrivateKeyEncryptionResult> generateNewKeys(String password);

  Future<PrivateKeyDecryptionResult> decryptAndSaveKey(
      PrivateKeyEncryptionResult encryptedResult, String password);

  Future<PrivateKeyDecryptionResult?> getKeys();

  PrivateKeyEncryptionResult resetPassword(
      PrivateKeyEncryptionResult dataInDB, String currentPass, String newPass);

  Future<CryptoResult> encrypt(String data);

  Future<CryptoResult> decrypt(String data);

  Future<void> deleteKeys();
}
