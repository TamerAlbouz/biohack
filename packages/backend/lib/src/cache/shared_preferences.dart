import 'package:injectable/injectable.dart';
import 'package:p_logger/p_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../authentication/enums/role.dart';

@LazySingleton()
class UserPreferences {
  static const String _keyRole = 'role';

  final SharedPreferences _sharedPreferences;

  UserPreferences(this._sharedPreferences);

  Future<void> setRole(Role role) async {
    try {
      await _sharedPreferences.setString(_keyRole, role.name);
    } on Exception catch (e) {
      logger.e('Error saving user data: $e');
      rethrow;
    }
  }

  Role? getRole() {
    try {
      String? role = _sharedPreferences.getString(_keyRole);

      if (role == null) {
        return null;
      }

      return Role.values.byName(role);
    } on Exception catch (e) {
      logger.e('Error getting user data: $e');
      rethrow;
    }
  }

  Future<void> setBool(String key, bool value) async {
    try {
      await _sharedPreferences.setBool(key, value);
    } on Exception catch (e) {
      logger.e('Error saving user data: $e');
      rethrow;
    }
  }

  bool? getBool(String key) {
    try {
      return _sharedPreferences.getBool(key);
    } on Exception catch (e) {
      logger.e('Error getting user data: $e');
      rethrow;
    }
  }

  // clear all
  Future<void> clearAll() async {
    try {
      await _sharedPreferences.clear();
    } on Exception catch (e) {
      logger.e('Error clearing user data: $e');
      rethrow;
    }
  }

  // Clear user data
  Future<void> clearRole() async {
    try {
      await _sharedPreferences.remove(_keyRole);
    } on Exception catch (e) {
      logger.e('Error clearing user data: $e');
      rethrow;
    }
  }
}
