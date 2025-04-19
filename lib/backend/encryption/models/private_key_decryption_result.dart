import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'private_key_decryption_result.g.dart';

@JsonSerializable()
class PrivateKeyDecryptionResult extends Equatable {
  final String publicKey;
  final String privateKey;
  final String randomSaltOne;
  final String randomSaltTwo;

  const PrivateKeyDecryptionResult({
    required this.publicKey,
    required this.privateKey,
    required this.randomSaltOne,
    required this.randomSaltTwo,
  });

  @override
  List<Object?> get props =>
      [publicKey, privateKey, randomSaltOne, randomSaltTwo];

  factory PrivateKeyDecryptionResult.fromJson(Map<String, dynamic> json) =>
      _$PrivateKeyDecryptionResultFromJson(json);

  Map<String, dynamic> toJson() => _$PrivateKeyDecryptionResultToJson(this);
}
