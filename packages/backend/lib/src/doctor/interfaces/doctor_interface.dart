import '../../user/interfaces/user_interface.dart';
import '../models/doctor.dart';

abstract class IDoctorRepository extends IUserRepository {
  Future<Doctor?> getDoctor(String id);

  Future<void> addDoctor(Doctor patient);

  Future<void> updateDoctor(Doctor patient);
}
