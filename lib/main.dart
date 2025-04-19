import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:medtalk/app/screens/route_auth.dart';
import 'package:medtalk/backend/authentication/interfaces/auth_interface.dart';
import 'package:medtalk/backend/injectable.dart';
import 'package:medtalk/bloc_observer.dart';
import 'package:medtalk/styles/styles/system.dart';

void main() async {
  final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
  );
  // log time as well
  final stopwatch = Stopwatch();
  stopwatch.start();
  logger.i('Starting application');

  logger.i('Initializing Firebase');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  logger.i('Firebase initialized');

  logger.i('Enabling Firestore persistence (cache)');
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  logger.i('Firestore persistence (cache) enabled');

  logger.i('Configuring dependencies');
  await configureDependencies();
  logger.i('Dependencies configured');

  logger.i('Assigning Bloc observer');
  Bloc.observer = getIt<CustomBlocObserver>();
  logger.i('Bloc observer assigned');

  logger.i('Setting system chrome');
  SystemChrome.setSystemUIOverlayStyle(kStatusBarDark);
  logger.i('System chrome set');

  // only portrait mode
  logger.i('Setting preferred orientations');
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  logger.i('Preferred orientations set');

  logger.i('Initializing authentication repository');
  final IAuthenticationRepository authenticationRepository =
      getIt<IAuthenticationRepository>();
  await authenticationRepository.user.first;
  // check if role is already chosen
  logger.i('Authentication repository initialized');

  stopwatch.stop();
  logger.i('Running application took ${stopwatch.elapsedMilliseconds}ms');

  runApp(App(authenticationRepository: authenticationRepository));
}
