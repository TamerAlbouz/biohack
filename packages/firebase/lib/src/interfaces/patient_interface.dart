import 'package:models/models.dart';

import '../../firebase.dart';

abstract class IPatientInterface extends IUserInterface {
  Future<void> addPatient(Patient patient);

  Future<void> updatePatient(Patient patient);
}
