import 'dart:typed_data';

import 'package:crypton/crypton.dart';

import '../models/crypto_result.dart';
import '../repositories/crypto_repository.dart';

abstract class ICryptoRepository {
  /// Decrypt a piece of text using symmetric algorithm
  Uint8List symmetricDecrypt(Uint8List key, Uint8List iv, Uint8List ciphertext);

  /// Encrypt a piece of text using symmetric algorithm
  Uint8List symmetricEncrypt(Uint8List key, Uint8List iv, Uint8List plaintext);

  /// method to generate encryption key using user's password.
  Future<Uint8List> generateKey(
    String password,
    String salt, {
    Argon2Profile profile = Argon2Profile.balanced,
  });

  Uint8List generateRandomSalt();

  /// method to generate RSA key-pairs
  RSAKeypair getKeyPair();

  /// method to encrypt a piece of text using the public key, returns a CryptoResult
  CryptoResult asymmetricEncrypt(String plainText, RSAPublicKey pubKey);

  /// method to decrypt a piece of text using the private key, returns a CryptoResult
  CryptoResult asymmetricDecrypt(Uint8List cipherText, RSAPrivateKey privKey);
}
