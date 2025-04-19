// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'private_key_encryption_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrivateKeyEncryptionResult _$PrivateKeyEncryptionResultFromJson(
        Map<String, dynamic> json) =>
    PrivateKeyEncryptionResult(
      publicKey: json['publicKey'] as String,
      encryptedPrivateKey: json['encryptedPrivateKey'] as String,
      randomSaltOne: json['randomSaltOne'] as String,
      randomSaltTwo: json['randomSaltTwo'] as String,
    );

Map<String, dynamic> _$PrivateKeyEncryptionResultToJson(
        PrivateKeyEncryptionResult instance) =>
    <String, dynamic>{
      'publicKey': instance.publicKey,
      'encryptedPrivateKey': instance.encryptedPrivateKey,
      'randomSaltOne': instance.randomSaltOne,
      'randomSaltTwo': instance.randomSaltTwo,
    };
