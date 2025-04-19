import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:injectable/injectable.dart';
import 'package:medtalk/backend/hashing/interfaces/hash_interface.dart';
import 'package:pointycastle/export.dart';

// Simple data class for isolate messaging
class HashParams {
  final String input;
  final String salt;
  final int iterations;
  final int keyLength;

  const HashParams(this.input, this.salt, this.iterations, this.keyLength);
}

@LazySingleton(as: IHashRepository)
class HashRepository implements IHashRepository {
  static const int saltLength = 16;
  static const int iterations = 600000;
  static const int keyLength = 32;
  static const String separator = ':';

  final Random _random = Random.secure();

  // Static method for isolate to process
  static String _deriveKeyInIsolate(HashParams params) {
    final pbkdf2 = KeyDerivator('SHA-256/HMAC/PBKDF2');
    final pbkdf2Params = Pbkdf2Parameters(
      base64.decode(params.salt),
      params.iterations,
      params.keyLength,
    );
    pbkdf2.init(pbkdf2Params);
    final key = pbkdf2.process(Uint8List.fromList(utf8.encode(params.input)));
    return base64.encode(key);
  }

  Future<String> _deriveKeyAsync(String input, String salt) async {
    return await Isolate.run(() =>
        _deriveKeyInIsolate(HashParams(input, salt, iterations, keyLength)));
  }

  String _generateSalt() {
    final saltBytes = Uint8List(saltLength);
    for (var i = 0; i < saltLength; i++) {
      saltBytes[i] = _random.nextInt(256);
    }
    return base64.encode(saltBytes);
  }

  String _encodeHashWithSalt(String key, String salt) =>
      base64.encode(utf8.encode('$key$separator$salt'));

  ({String key, String salt}) _decodeHashWithSalt(String encodedHash) {
    final decoded = utf8.decode(base64.decode(encodedHash));
    final separatorIndex = decoded.indexOf(separator);

    if (separatorIndex == -1) {
      throw const FormatException('Invalid hash format');
    }

    return (
      key: decoded.substring(0, separatorIndex),
      salt: decoded.substring(separatorIndex + 1)
    );
  }

  @override
  Future<String> hash(String value) async {
    final salt = _generateSalt();
    final derivedKey = await _deriveKeyAsync(value, salt);
    return _encodeHashWithSalt(derivedKey, salt);
  }

  @override
  Future<bool> verify(String password, String storedHash) async {
    try {
      final decoded = _decodeHashWithSalt(storedHash);
      final derivedKey = await _deriveKeyAsync(password, decoded.salt);
      return derivedKey == decoded.key;
    } on FormatException {
      return false;
    }
  }
}
