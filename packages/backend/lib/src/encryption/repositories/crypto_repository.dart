import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypton/crypton.dart';
import 'package:injectable/injectable.dart';
import 'package:p_logger/p_logger.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/block/aes.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'package:pointycastle/macs/hmac.dart';
import 'package:pointycastle/padded_block_cipher/padded_block_cipher_impl.dart';
import 'package:pointycastle/paddings/pkcs7.dart';

import '../interfaces/crypto_interface.dart';
import '../models/crypto_result.dart';

@LazySingleton(as: ICryptoRepository)
class CryptoRepository extends ICryptoRepository {
  /// Decrypt a piece of text using symmetric algorithm
  @override
  Uint8List symmetricDecrypt(
      Uint8List key, Uint8List iv, Uint8List ciphertext) {
    logger.i('Decrypting text using symmetric algorithm');
    final cipher = PaddedBlockCipherImpl(PKCS7Padding(), AESEngine());
    logger.i('Cipher created');
    final params = PaddedBlockCipherParameters(
      KeyParameter(key),
      ParametersWithIV<KeyParameter>(KeyParameter(key), iv),
    );
    logger.i('Parameters created');
    cipher.init(false, params);
    logger.i('Cipher initialized');
    return cipher.process(ciphertext);
  }

  /// Encrypt a piece of text using symmetric algorithm
  @override
  Uint8List symmetricEncrypt(Uint8List key, Uint8List iv, Uint8List plaintext) {
    logger.i('Encrypting text using symmetric algorithm');
    final cipher = PaddedBlockCipherImpl(PKCS7Padding(), AESEngine());
    logger.i('Cipher created');
    final params = PaddedBlockCipherParameters(
      KeyParameter(key),
      ParametersWithIV<KeyParameter>(KeyParameter(key), iv),
    );
    logger.i('Parameters created');
    cipher.init(true, params);
    logger.i('Cipher initialized');
    return cipher.process(plaintext);
  }

  /// method to generate encryption key using user's password.
  @override
  Uint8List generatePBKDFKey(String password, String salt,
      {int iterations = 10000, int derivedKeyLength = 32}) {
    logger.i('Generating PBKDF key');
    final passwordBytes = utf8.encode(password);
    final saltBytes = utf8.encode(salt);
    logger.i('Password and salt converted to bytes');

    logger.i('Creating PBKDF2 parameters');
    final params = Pbkdf2Parameters(
        Uint8List.fromList(saltBytes), iterations, derivedKeyLength);
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    logger.i('PBKDF2 parameters created');

    pbkdf2.init(params);

    logger.i('PBKDF2 initialized');

    return pbkdf2.process(Uint8List.fromList(passwordBytes));
  }

  @override
  Uint8List generateRandomSalt({int length = 16}) {
    logger.i('Generating random salt');
    final random = Random.secure();
    final saltCodeUnits =
        List<int>.generate(length, (_) => random.nextInt(256));
    logger.i('Random salt generated');
    return Uint8List.fromList(saltCodeUnits);
  }

  /// method to generate RSA key-pairs
  @override
  RSAKeypair getKeyPair() {
    logger.i('Generating RSA key pair');
    RSAKeypair rsaKeypair = RSAKeypair.fromRandom();
    logger.i('RSA key pair generated');
    return rsaKeypair;
  }

  /// method to encrypt a piece of text using the public key, returns a CryptoResult
  @override
  CryptoResult asymmetricEncrypt(String plainText, RSAPublicKey pubKey) {
    try {
      logger.i('Encrypting text using asymmetric algorithm');
      // Encrypt the piece of text
      String encrypted = pubKey.encrypt(plainText);
      logger.i('Text encrypted');
      // Return a CryptoResult
      return CryptoResult(data: encrypted, status: true);
    } catch (err) {
      // Error handling
      return CryptoResult(data: err.toString(), status: false);
    }
  }

  /// method to decrypt a piece of text using the private key, returns a CryptoResult
  @override
  CryptoResult asymmetricDecrypt(String encodedTxt, RSAPrivateKey pvKey) {
    try {
      logger.i('Decrypting text using asymmetric algorithm');
      // Decrypt the piece of text
      String decoded = pvKey.decrypt(encodedTxt);
      logger.i('Text decrypted');
      // Return a CryptoResult
      return CryptoResult(data: decoded, status: true);
    } catch (err) {
      // Error handling
      return CryptoResult(data: err.toString(), status: false);
    }
  }
}
