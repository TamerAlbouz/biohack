import 'package:backend/backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medtalk/common/globals/globals.dart';
import 'package:medtalk/doctor/navigation/screens/navigation_doctor_screen.dart';
import 'package:medtalk/loading/screens/loading_screen.dart';
import 'package:medtalk/login/bloc/login_bloc.dart';
import 'package:medtalk/patient/dashboard/bloc/patient/patient_bloc.dart';
import 'package:medtalk/patient/intro/screens/intro_screen_patient.dart';
import 'package:medtalk/patient/navigation/screens/navigation_patient_screen.dart';
import 'package:medtalk/styles/themes.dart';

import '../../login/screens/login_screen.dart';
import '../bloc/auth/route_bloc.dart';
import 'auth_screen.dart';

class App extends StatelessWidget {
  const App({
    required IAuthenticationRepository authenticationRepository,
    super.key,
  }) : _authenticationRepository = authenticationRepository;

  final IAuthenticationRepository _authenticationRepository;

  // add route
  static Route<void> route(IAuthenticationRepository repo) {
    return MaterialPageRoute<void>(
        builder: (_) => App(authenticationRepository: repo));
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<IAuthenticationRepository>.value(
          value: _authenticationRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            lazy: false,
            create: (_) => RouteBloc(
              authRepo: _authenticationRepository,
              userPreferences: getIt<UserPreferences>(),
              patientRepository: getIt<IPatientRepository>(),
              doctorRepository: getIt<IDoctorRepository>(),
            )
              ..add(InitialRun())
              ..add(AuthSubscriptionRequested()),
          ),
          BlocProvider(
            create: (_) => PatientBloc(
              patientRepo: getIt<IPatientRepository>(),
              authRepo: getIt<IAuthenticationRepository>(),
            )..add(LoadPatient()),
          ),
          BlocProvider(
            lazy: false,
            create: (_) => LoginBloc(
              getIt<IAuthenticationRepository>(),
              getIt<IEncryptionRepository>(),
              getIt<ISecureEncryptionStorage>(),
            ),
          ),
        ],
        child: const _AppView(),
      ),
    );
  }
}

class _AppView extends StatefulWidget {
  const _AppView();

  @override
  State<_AppView> createState() => _AppViewState();
}

class _AppViewState extends State<_AppView> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      navigatorKey: AppGlobal.navigatorKey,
      builder: (context, child) {
        return BlocListener<RouteBloc, RouteState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                  ),
                );
            }

            if (state is AuthChooseRole) {
              AppGlobal.navigatorKey.currentState?.pushAndRemoveUntil<void>(
                Auth.route(),
                (route) => false,
              );
            }

            if (state is AuthLogin) {
              AppGlobal.navigatorKey.currentState?.pushAndRemoveUntil<void>(
                LoginScreen.route(),
                (route) => false,
              );
            }

            if (state is AuthSuccess && state.role == Role.patient) {
              navigatePatient(state.status);
            }

            if (state is AuthSuccess && state.role == Role.doctor) {
              navigateDoctor(state.status);
            }
          },
          child: child,
        );
      },
      onGenerateRoute: (_) => LoadingScreen.route(),
      theme: lightTheme,
    );
  }

  void navigatePatient(AuthStatus status) {
    switch (status) {
      case AuthStatus.authenticated:
        // check if user is has their email verified
        AppGlobal.navigatorKey.currentState?.pushAndRemoveUntil<void>(
          NavigationPatientScreen.route(),
          (route) => false,
        );
        break;
      case AuthStatus.firstTimeAuthentication:
        AppGlobal.navigatorKey.currentState?.pushAndRemoveUntil<void>(
          IntroScreenPatient.route(),
          (route) => false,
        );
        break;
      case AuthStatus.anonymous:
        AppGlobal.navigatorKey.currentState?.pushAndRemoveUntil<void>(
          NavigationPatientScreen.route(),
          (route) => false,
        );
        break;
      case AuthStatus.unauthenticated:
        break;
    }
  }

  void navigateDoctor(AuthStatus status) {
    switch (status) {
      case AuthStatus.authenticated:
        // check if user is has their email verified
        AppGlobal.navigatorKey.currentState?.pushAndRemoveUntil<void>(
          NavigationDoctorScreen.route(),
          (route) => false,
        );
        break;
      case AuthStatus.firstTimeAuthentication:
        AppGlobal.navigatorKey.currentState?.pushAndRemoveUntil<void>(
          NavigationDoctorScreen.route(),
          (route) => false,
        );
        break;
      case AuthStatus.anonymous:
        AppGlobal.navigatorKey.currentState?.pushAndRemoveUntil<void>(
          NavigationDoctorScreen.route(),
          (route) => false,
        );
        break;
      case AuthStatus.unauthenticated:
        break;
    }
  }
}
