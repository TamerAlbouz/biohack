import 'dart:typed_data';

import 'package:backend/src/encryption/models/key_generation_result.dart';
import 'package:crypton/crypton.dart';

import '../models/crypto_result.dart';

abstract class ICryptoRepository {
  /// Decrypt a piece of text using symmetric algorithm
  Uint8List symmetricDecrypt(Uint8List key, Uint8List iv, Uint8List ciphertext);

  /// Encrypt a piece of text using symmetric algorithm
  Uint8List symmetricEncrypt(Uint8List key, Uint8List iv, Uint8List plaintext);

  /// method to generate encryption key using user's password.
  Uint8List generatePBKDFKey(String password, String salt,
      {int iterations = 10000, int derivedKeyLength = 32});

  Uint8List generateRandomSalt({int length = 16});

  /// method to generate RSA key-pairs
  RSAKeypair getKeyPair();

  /// method to encrypt a piece of text using the public key, returns a CryptoResult
  CryptoResult asymmetricEncrypt(String plainText, RSAPublicKey pubKey);

  /// method to decrypt a piece of text using the private key, returns a CryptoResult
  CryptoResult asymmetricDecrypt(String cipherText, RSAPrivateKey privKey);

  KeyGenerationResult getKeys(String password);
}
