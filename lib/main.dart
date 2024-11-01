import 'package:bloc/bloc.dart';
import 'package:firebase/firebase.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medtalk/app/screens/route_auth.dart';
import 'package:medtalk/bloc_observer.dart';
import 'package:medtalk/styles/styles/system.dart';
import 'package:p_logger/p_logger.dart';

void main() async {
  logger.i('Starting application');
  logger.i('Initializing Firebase');

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  logger.i('Firebase initialized');

  logger.i('Assigning Bloc observer');
  Bloc.observer = CustomBlocObserver();
  logger.i('Bloc observer assigned');

  logger.i('Setting system chrome');
  SystemChrome.setSystemUIOverlayStyle(kStatusBarLight);
  logger.i('System chrome set');

  logger.i('Configuring dependencies');
  await configureDependencies();
  logger.i('Dependencies configured');

  // only portrait mode
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  logger.i('Initializing authentication repository');
  final IAuthenticationRepository authenticationRepository =
      getIt<IAuthenticationRepository>();
  await authenticationRepository.user.first;
  // check if role is already chosen
  logger.i('Authentication repository initialized');

  logger.i('Running application');
  runApp(App(authenticationRepository: authenticationRepository));
}
