import 'dart:typed_data';

import 'package:crypton/crypton.dart';

class KeyGenerationResult {
  final RSAKeypair keyPair;
  final String randomSaltOne;
  final Uint8List pbkdfKey;

  KeyGenerationResult({
    required this.keyPair,
    required this.randomSaltOne,
    required this.pbkdfKey,
  });
}
