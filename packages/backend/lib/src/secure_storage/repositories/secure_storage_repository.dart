import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../interfaces/secure_storage_interface.dart';

@LazySingleton(as: ISecureStorageRepository)
class SecureStorageRepository extends ISecureStorageRepository {
  final FlutterSecureStorage _storage;

  SecureStorageRepository()
      : _storage = FlutterSecureStorage(
          aOptions: _getAndroidOptions(),
        );

  static AndroidOptions _getAndroidOptions() => const AndroidOptions(
        encryptedSharedPreferences: true,
      );

  static IOSOptions _getIOSOptions() => const IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      );

  @override
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value, iOptions: _getIOSOptions());
  }

  @override
  Future<String?> read(String key) async {
    return await _storage.read(key: key, iOptions: _getIOSOptions());
  }

  @override
  Future<void> delete(String key) async {
    await _storage.delete(key: key, iOptions: _getIOSOptions());
  }

  @override
  Future<Map<String, String>> readAll() async {
    return await _storage.readAll();
  }

  @override
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}
