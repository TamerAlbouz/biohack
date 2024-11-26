import 'dart:convert';
import 'dart:typed_data';

import 'package:backend/backend.dart';
import 'package:backend/src/encryption/models/crypto_result.dart';
import 'package:crypton/crypton.dart';
import 'package:injectable/injectable.dart';
import 'package:p_logger/p_logger.dart';

import '../../secure_storage/interfaces/secure_storage_interface.dart';
import '../interfaces/crypto_interface.dart';

@LazySingleton(as: ISecureEncryptionStorage)
class SecureEncryptionStorage implements ISecureEncryptionStorage {
  final ISecureStorageRepository _secureStorageRepository =
      getIt<ISecureStorageRepository>();
  final ICryptoRepository _cryptoRepository = getIt<ICryptoRepository>();

  /// Generate a new key pair and encrypt the private key using the user's password,
  /// while also storing the private key in the secure storage.
  @override
  Future<PrivateKeyEncryptionResult> generateNewKeys(String password) async {
    try {
      logger.i('Generating keys');
      // Generate keys
      // Generate PBKDF key
      final String randomSaltOne =
          _cryptoRepository.generateRandomSalt().toString();
      final Uint8List pbkdfKey =
          _cryptoRepository.generatePBKDFKey(password, randomSaltOne);
      logger.i('PBKDF key generated');

      // Generate RSA Key Pair
      final RSAKeypair keyPair = _cryptoRepository.getKeyPair();
      logger.i('RSA key pair generated');

      // Encrypt Private key
      final privateKeySalt = _cryptoRepository.generateRandomSalt().toString();

      final encryptedPrivateKey = _cryptoRepository.symmetricEncrypt(
        pbkdfKey,
        Uint8List.fromList(privateKeySalt.codeUnits),
        Uint8List.fromList(keyPair.privateKey.toFormattedPEM().codeUnits),
      );

      var result = PrivateKeyEncryptionResult(
        publicKey: keyPair.publicKey.toFormattedPEM(),
        encryptedPrivateKey: String.fromCharCodes(encryptedPrivateKey),
        randomSaltOne: randomSaltOne,
        randomSaltTwo: privateKeySalt,
      );

      logger.i('Keys generated');

      return result;
    } catch (e) {
      logger.e('Error generating and saving keys: $e');
      throw Exception('Error generating and saving keys');
    }
  }

  /// Decrypts the private key using the user's password and saves it in the secure storage.
  @override
  Future<PrivateKeyDecryptionResult> decryptAndSaveKey(
      PrivateKeyEncryptionResult encryptedResult, String password) async {
    try {
      logger.i('Decrypting private key');
      // Generate pbkdfKey using the random salt stored in DB and user's password
      final Uint8List pbkdfKey = _cryptoRepository.generatePBKDFKey(
        password,
        encryptedResult.randomSaltOne,
      );

      // decrypt private key using the pbkdfKey generated above
      // and the second random slat stored in DB
      Uint8List decryptedPrivateKey = _cryptoRepository.symmetricDecrypt(
        pbkdfKey,
        Uint8List.fromList(encryptedResult.randomSaltTwo.codeUnits),
        Uint8List.fromList(encryptedResult.encryptedPrivateKey.codeUnits),
      );

      final PrivateKeyDecryptionResult result = PrivateKeyDecryptionResult(
        publicKey: encryptedResult.publicKey,
        privateKey: String.fromCharCodes(decryptedPrivateKey),
        randomSaltOne: encryptedResult.randomSaltOne,
        randomSaltTwo: encryptedResult.randomSaltTwo,
      );

      // Store the private key in secure storage
      await _secureStorageRepository.write(
          'rsaKeys', jsonEncode(result.toJson()));

      logger.i('Private key decrypted and saved');

      return result;
    } catch (e) {
      logger.e('Error decrypting private key: $e');
      throw Exception('Error decrypting private key');
    }
  }

  /// Gets the private key from the secure storage.
  @override
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

  @override
  PrivateKeyEncryptionResult resetPassword(
      PrivateKeyEncryptionResult dataInDB, String currentPass, String newPass) {
    // Generate pbkdfKey using the random salt stored in DB and user's password
    final Uint8List pbkdfKey = _cryptoRepository.generatePBKDFKey(
      currentPass,
      dataInDB.randomSaltOne,
    );

    // decrypt private key
    Uint8List decryptedPrivateKey = _cryptoRepository.symmetricDecrypt(
      pbkdfKey,
      Uint8List.fromList(dataInDB.randomSaltTwo.codeUnits),
      Uint8List.fromList(dataInDB.encryptedPrivateKey.codeUnits),
    );

    // generate pbkdf key using new password
    final Uint8List newPbkdfKey = _cryptoRepository.generatePBKDFKey(
      newPass,
      dataInDB.randomSaltOne,
    );

    // encrypt private key with new pbkdf key
    final encryptedPrivateKey = _cryptoRepository.symmetricEncrypt(
      newPbkdfKey,
      Uint8List.fromList(dataInDB.randomSaltTwo.codeUnits),
      decryptedPrivateKey,
    );

    return PrivateKeyEncryptionResult(
      publicKey: dataInDB.publicKey,
      encryptedPrivateKey: String.fromCharCodes(encryptedPrivateKey),
      randomSaltOne: dataInDB.randomSaltOne,
      randomSaltTwo: dataInDB.randomSaltTwo,
    );
  }

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
  Future<CryptoResult> decrypt(String data) async {
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

  @override
  Future<void> deleteKeys() async {
    try {
      logger.i('Deleting keys');
      await _secureStorageRepository.deleteAll();
    } catch (e) {
      logger.e('Error deleting keys: $e');
      throw Exception('Error deleting keys');
    }
  }
}
