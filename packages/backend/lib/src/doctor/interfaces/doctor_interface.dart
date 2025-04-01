import 'package:cloud_firestore/cloud_firestore.dart';

import '../../user/interfaces/user_interface.dart';
import '../models/doctor.dart';

abstract class IDoctorRepository extends IUserRepository {
  Future<Doctor?> getDoctor(String id);

  Future<void> addDoctor(Doctor patient);

  Future<void> updateDoctor(Doctor patient);

  Future<(List<Doctor> doctors, DocumentSnapshot? lastDoc)> getDoctorsPaginated(
      int limit, DocumentSnapshot? lastDocument);
}
