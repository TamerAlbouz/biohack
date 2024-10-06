import 'package:authentication/authentication.dart';
import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medtalk/auth/screens/auth_screen.dart';
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

  logger.i('Initializing authentication repository');
  final authenticationRepository = AuthenticationRepository();
  await authenticationRepository.user.first;
  logger.i('Authentication repository initialized');

  // only portrait mode
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  logger.i('Running application');
  runApp(App(authenticationRepository: authenticationRepository));
}
