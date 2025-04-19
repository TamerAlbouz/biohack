// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'private_key_decryption_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrivateKeyDecryptionResult _$PrivateKeyDecryptionResultFromJson(
        Map<String, dynamic> json) =>
    PrivateKeyDecryptionResult(
      publicKey: json['publicKey'] as String,
      privateKey: json['privateKey'] as String,
      randomSaltOne: json['randomSaltOne'] as String,
      randomSaltTwo: json['randomSaltTwo'] as String,
    );

Map<String, dynamic> _$PrivateKeyDecryptionResultToJson(
        PrivateKeyDecryptionResult instance) =>
    <String, dynamic>{
      'publicKey': instance.publicKey,
      'privateKey': instance.privateKey,
      'randomSaltOne': instance.randomSaltOne,
      'randomSaltTwo': instance.randomSaltTwo,
    };
