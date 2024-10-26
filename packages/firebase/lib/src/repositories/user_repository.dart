import 'package:injectable/injectable.dart';

import '../../firebase.dart';

@LazySingleton(as: IUserRepository)
class UserRepository implements IUserRepository {}
