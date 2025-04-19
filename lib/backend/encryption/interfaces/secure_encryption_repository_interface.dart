import 'dart:typed_data';

import '../models/crypto_result.dart';

abstract class ISecureEncryptionStorage {
  // Future<PrivateKeyEncryptionResult> resetPassword(
  //     PrivateKeyEncryptionResult dataInDB, String currentPass, String newPass);
  Future<CryptoResult> encrypt(String data);

  Future<CryptoResult> decrypt(Uint8List data);
}
