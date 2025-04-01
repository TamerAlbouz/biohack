import 'dart:convert';
import 'dart:typed_data';

import 'package:backend/backend.dart';
import 'package:backend/src/encryption/models/crypto_result.dart';
import 'package:crypton/crypton.dart';
import 'package:injectable/injectable.dart';
import 'package:p_logger/p_logger.dart';

@LazySingleton(as: ISecureEncryptionStorage)
class SecureEncryptionStorageRepository implements ISecureEncryptionStorage {
  final ICryptoRepository _cryptoRepository;
  final ISecureStorageRepository _secureStorageRepository;

  SecureEncryptionStorageRepository(
      this._cryptoRepository, this._secureStorageRepository);

  /// Decrypts the private key using the user's password and saves it in the secure storage.
  Future<PrivateKeyDecryptionResult?> getKeys() async {
    try {
      final result = await _secureStorageRepository.read('rsaKeys');
      return result == null
          ? null
          : PrivateKeyDecryptionResult.fromJson(jsonDecode(result));
    } catch (e) {
      logger.e('Error reading private key from secure storage: $e');
      throw Exception('Error reading private key from secure storage');
    }
  }

// @override
// Future<PrivateKeyEncryptionResult> resetPassword(
//     PrivateKeyEncryptionResult dataInDB,
//     String currentPass,
//     String newPass) async {
//   try {
// logger.i('Resetting password for the private key');
//
// // Step 1: Generate PBKDF key using the current password and the stored randomSaltOne
// final Uint8List currentPBKDFKey = _cryptoRepository.generatePBKDFKey(
//   currentPass,
//   dataInDB.randomSaltOne,
// );
//
// // Step 2: Decrypt the private key using the current PBKDF key
// final Uint8List decryptedPrivateKey = _cryptoRepository.symmetricDecrypt(
//   currentPBKDFKey,
//   Uint8List.fromList(dataInDB.randomSaltTwo.codeUnits),
//   Uint8List.fromList(dataInDB.encryptedPrivateKey.codeUnits),
// );
//
// // Step 3: Generate new PBKDF key using the new password and a new random salt
// final String newRandomSaltOne =
//     _cryptoRepository.generateRandomSalt().toString();
// final Uint8List newPBKDFKey =
//     _cryptoRepository.generatePBKDFKey(newPass, newRandomSaltOne);
//
// // Step 4: Encrypt the private key again using the new PBKDF key and a new random salt
// final String newRandomSaltTwo =
//     _cryptoRepository.generateRandomSalt().toString();
// final Uint8List newEncryptedPrivateKey =
//     _cryptoRepository.symmetricEncrypt(
//   newPBKDFKey,
//   Uint8List.fromList(newRandomSaltTwo.codeUnits),
//   decryptedPrivateKey,
// );
//
// // Step 5: Construct the updated PrivateKeyEncryptionResult
// final PrivateKeyEncryptionResult updatedEncryptionResult =
//     PrivateKeyEncryptionResult(
//   publicKey: dataInDB.publicKey,
//   encryptedPrivateKey: String.fromCharCodes(newEncryptedPrivateKey),
//   randomSaltOne: newRandomSaltOne,
//   randomSaltTwo: newRandomSaltTwo,
// );
//
// // Step 6: Construct the updated PrivateKeyDecryptionResult
// final PrivateKeyDecryptionResult updatedDecryptionResult =
//     PrivateKeyDecryptionResult(
//   publicKey: dataInDB.publicKey,
//   privateKey: String.fromCharCodes(decryptedPrivateKey),
//   randomSaltOne: newRandomSaltOne,
//   randomSaltTwo: newRandomSaltTwo,
// );
//
// // Step 7: Store the updated decryption result in secure storage
// await _secureStorageRepository.write(
//   'rsaKeys',
//   jsonEncode(updatedDecryptionResult.toJson()),
// );
//
// logger.i('Password reset and private key securely updated');
// return updatedEncryptionResult;
//   } catch (e) {
//     logger.e('Error resetting password: $e');
//     throw Exception('Error resetting password');
//   }
// }

  @override
  Future<CryptoResult> encrypt(String data) async {
    try {
      final PrivateKeyDecryptionResult? keys = await getKeys();

      logger.i('Encrypting data: $data, with public key: ${keys!.publicKey}');
      final CryptoResult encryptedData = _cryptoRepository.asymmetricEncrypt(
        data,
        RSAPublicKey.fromPEM(keys.publicKey),
      );

      return encryptedData;
    } catch (e) {
      logger.e('Error encrypting data: $e');
      throw Exception('Error encrypting data');
    }
  }

  @override
  Future<CryptoResult> decrypt(Uint8List data) async {
    try {
      final PrivateKeyDecryptionResult? keys = await getKeys();

      final CryptoResult decryptedData = _cryptoRepository.asymmetricDecrypt(
        data,
        RSAPrivateKey.fromString(keys!.privateKey),
      );

      return decryptedData;
    } catch (e) {
      logger.e('Error decrypting data: $e');
      throw Exception('Error decrypting data');
    }
  }
}
