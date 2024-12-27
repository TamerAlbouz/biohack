import 'dart:convert';
import 'dart:math';

import 'package:crypton/crypton.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:p_logger/p_logger.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/block/aes.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/key_derivators/argon2.dart';
import 'package:pointycastle/padded_block_cipher/padded_block_cipher_impl.dart';
import 'package:pointycastle/paddings/pkcs7.dart';

import '../interfaces/crypto_interface.dart';
import '../models/crypto_result.dart';

/// OWASP recommended Argon2id configurations
/// All provide equivalent security with different memory/CPU tradeoffs
enum Argon2Profile {
  /// m=47104 (46 MiB), t=1, p=1 - Highest memory, lowest CPU
  highMemory,

  /// m=19456 (19 MiB), t=2, p=1 - Balanced memory/CPU
  balanced,

  /// m=12288 (12 MiB), t=3, p=1 - Medium memory/CPU
  medium,

  /// m=9216 (9 MiB), t=4, p=1 - Lower memory, higher CPU
  lowMemory,

  /// m=7168 (7 MiB), t=5, p=1 - Lowest memory, highest CPU
  minimumMemory,
}

class Argon2Config {
  static const Map<Argon2Profile, Map<String, int>> profiles = {
    Argon2Profile.highMemory: {
      'memory': 47104, // 46 MiB
      'iterations': 1,
      'lanes': 1,
    },
    Argon2Profile.balanced: {
      'memory': 19456, // 19 MiB
      'iterations': 2,
      'lanes': 1,
    },
    Argon2Profile.medium: {
      'memory': 12288, // 12 MiB
      'iterations': 3,
      'lanes': 1,
    },
    Argon2Profile.lowMemory: {
      'memory': 9216, // 9 MiB
      'iterations': 4,
      'lanes': 1,
    },
    Argon2Profile.minimumMemory: {
      'memory': 7168, // 7 MiB
      'iterations': 5,
      'lanes': 1,
    },
  };

  static const int saltLength = 16; // 16 bytes = 128 bits
  static const int hashLength = 32; // 32 bytes = 256 bits
}

Future<Uint8List> computeArgon2idKey(Map<String, dynamic> params) async {
  final Uint8List passwordBytes = params['passwordBytes'];
  final Uint8List saltBytes = params['saltBytes'];
  final int iterations = params['iterations'];
  final int memory = params['memory'];
  final int lanes = params['lanes'];
  final int derivedKeyLength = params['derivedKeyLength'];

  final argon2 = Argon2BytesGenerator()
    ..init(Argon2Parameters(
      Argon2Parameters.ARGON2_id,
      saltBytes,
      desiredKeyLength: derivedKeyLength,
      iterations: iterations,
      memory: memory,
      lanes: lanes,
    ));

  return argon2.process(passwordBytes);
}

@LazySingleton(as: ICryptoRepository)
class CryptoRepository extends ICryptoRepository {
  // Existing symmetric encryption/decryption methods remain the same
  @override
  Uint8List symmetricDecrypt(
      Uint8List key, Uint8List iv, Uint8List ciphertext) {
    logger.i('Decrypting text using symmetric algorithm');
    final cipher = PaddedBlockCipherImpl(PKCS7Padding(), AESEngine());
    final params = PaddedBlockCipherParameters(
      KeyParameter(key),
      ParametersWithIV<KeyParameter>(KeyParameter(key), iv),
    );
    cipher.init(false, params);
    return cipher.process(ciphertext);
  }

  @override
  Uint8List symmetricEncrypt(Uint8List key, Uint8List iv, Uint8List plaintext) {
    logger.i('Encrypting text using symmetric algorithm');
    final cipher = PaddedBlockCipherImpl(PKCS7Padding(), AESEngine());
    final params = PaddedBlockCipherParameters(
      KeyParameter(key),
      ParametersWithIV<KeyParameter>(KeyParameter(key), iv),
    );
    cipher.init(true, params);
    return cipher.process(plaintext);
  }

  /// Generate encryption key using Argon2id with OWASP recommended parameters
  @override
  Future<Uint8List> generateKey(
    String password,
    String salt, {
    Argon2Profile profile = Argon2Profile.highMemory,
  }) async {
    final params = Argon2Config.profiles[profile]!;
    final passwordBytes = utf8.encode(password);
    final saltBytes = utf8.encode(salt);

    logger.i('Starting Argon2id key generation with ${profile.name} profile');

    final Uint8List result = await compute(computeArgon2idKey, {
      'passwordBytes': Uint8List.fromList(passwordBytes),
      'saltBytes': Uint8List.fromList(saltBytes),
      'iterations': params['iterations'],
      'memory': params['memory'],
      'lanes': params['lanes'],
      'derivedKeyLength': Argon2Config.hashLength,
    });

    logger.i('Argon2id key generation completed');
    return result;
  }

  @override
  Uint8List generateRandomSalt() {
    logger.i('Generating random salt');
    final random = Random.secure();
    final saltCodeUnits =
        List<int>.generate(Argon2Config.saltLength, (_) => random.nextInt(256));
    logger.i('Random salt generated');
    return Uint8List.fromList(saltCodeUnits);
  }

  // Existing RSA methods remain the same
  @override
  RSAKeypair getKeyPair() {
    logger.i('Generating RSA key pair');
    RSAKeypair rsaKeypair = RSAKeypair.fromRandom();
    logger.i('RSA key pair generated');
    return rsaKeypair;
  }

  @override
  CryptoResult asymmetricEncrypt(String plainText, RSAPublicKey pubKey) {
    try {
      logger.i('Encrypting text using asymmetric algorithm');
      String encrypted = pubKey.encrypt(plainText);
      logger.i('Text encrypted');
      return CryptoResult(data: encrypted, status: true);
    } catch (err) {
      return CryptoResult(data: err.toString(), status: false);
    }
  }

  @override
  CryptoResult asymmetricDecrypt(String cipherText, RSAPrivateKey privKey) {
    try {
      logger.i('Decrypting text using asymmetric algorithm');
      String decoded = privKey.decrypt(cipherText);
      logger.i('Text decrypted');
      return CryptoResult(data: decoded, status: true);
    } catch (err) {
      return CryptoResult(data: err.toString(), status: false);
    }
  }
}
