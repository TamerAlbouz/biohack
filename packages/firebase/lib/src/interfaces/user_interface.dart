import 'package:models/models.dart';

abstract class IUserInterface {
  Stream<IUser?> get user;

  Stream<IUser?> getUser(String userId);
}
