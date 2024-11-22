import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'private_key_encryption_result.g.dart';

@JsonSerializable()
class PrivateKeyEncryptionResult extends Equatable {
  final String publicKey;
  final String encryptedPrivateKey;
  final String randomSaltOne;
  final String randomSaltTwo;

  const PrivateKeyEncryptionResult({
    required this.publicKey,
    required this.encryptedPrivateKey,
    required this.randomSaltOne,
    required this.randomSaltTwo,
  });

  PrivateKeyEncryptionResult copyWith({
    String? publicKey,
    String? encryptedPrivateKey,
    String? randomSaltOne,
    String? randomSaltTwo,
  }) {
    return PrivateKeyEncryptionResult(
      publicKey: publicKey ?? this.publicKey,
      encryptedPrivateKey: encryptedPrivateKey ?? this.encryptedPrivateKey,
      randomSaltOne: randomSaltOne ?? this.randomSaltOne,
      randomSaltTwo: randomSaltTwo ?? this.randomSaltTwo,
    );
  }

  factory PrivateKeyEncryptionResult.fromMap(Map<String, dynamic> map) {
    return PrivateKeyEncryptionResult(
      publicKey: map['publicKey'] as String,
      encryptedPrivateKey: map['encryptedPrivateKey'] as String,
      randomSaltOne: map['randomSaltOne'] as String,
      randomSaltTwo: map['randomSaltTwo'] as String,
    );
  }

  Map<String, dynamic> get toMap {
    return {
      'publicKey': publicKey,
      'encryptedPrivateKey': encryptedPrivateKey,
      'randomSaltOne': randomSaltOne,
      'randomSaltTwo': randomSaltTwo,
    };
  }

  @override
  List<Object?> get props => [
        publicKey,
        encryptedPrivateKey,
        randomSaltOne,
        randomSaltTwo,
      ];

  factory PrivateKeyEncryptionResult.fromJson(Map<String, dynamic> json) =>
      _$PrivateKeyEncryptionResultFromJson(json);

  Map<String, dynamic> toJson() => _$PrivateKeyEncryptionResultToJson(this);
}
