import '../../user/interfaces/user_interface.dart';
import '../models/patient.dart';

abstract class IPatientRepository extends IUserRepository {
  Future<Patient?> getPatient(String id);

  Future<void> addPatient(Patient patient);

  Future<void> updatePatient(Patient patient);
}
