import 'package:models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const String _keyUserId = 'userId';

  // Save user data
  static Future<void> saveLoggedInPatient(Patient patient) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, patient.toMap.toString());
  }

  // Get user data
  static Future<Patient?> getLoggedInPatient() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic>? user = prefs.getString(_keyUserId).toMap();

    if (user.isEmpty) {
      return null;
    }

    return Patient.fromMap(_keyUserId, user);
  }

  static Future<void> saveLoggedInDoctor(Doctor doctor) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, doctor.toMap.toString());
  }

  static Future<Doctor?> getLoggedInDoctor() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic>? user = prefs.getString(_keyUserId).toMap();

    if (user.isEmpty) {
      return null;
    }

    return Doctor.fromMap(_keyUserId, user);
  }

  // Clear user data
  static Future<void> clearUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
  }
}

// add an extension to getString toMap
extension on String? {
  Map<String, dynamic> toMap() {
    try {
      return this as Map<String, dynamic>;
    } on Exception catch (e) {
      throw Exception('Error converting object to Map: $e');
    }
  }
}
