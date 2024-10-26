import 'package:models/models.dart';

import '../../firebase.dart';

abstract class IPatientRepository extends IUserRepository {
  Future<Patient?> getPatient(String id);

  Future<void> addPatient(Patient patient);

  Future<void> updatePatient(Patient patient);
}
