import 'package:injectable/injectable.dart';

import '../interfaces/user_interface.dart';

@LazySingleton(as: IUserRepository)
class UserRepository implements IUserRepository {}
