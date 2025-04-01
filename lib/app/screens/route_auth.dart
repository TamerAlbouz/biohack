import 'package:backend/backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medtalk/app/screens/auth_screen.dart';
import 'package:medtalk/common/globals/globals.dart';
import 'package:medtalk/doctor/navigation/screens/navigation_doctor_screen.dart';
import 'package:medtalk/patient/dashboard/bloc/patient/patient_bloc.dart';
import 'package:medtalk/patient/navigation/screens/navigation_patient_screen.dart';
import 'package:medtalk/styles/themes.dart';

import '../../login/screens/login_screen.dart';
import '../bloc/auth/route_bloc.dart';

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
            )
              ..add(InitialRun())
              ..add(AuthSubscriptionRequested()),
          ),
          BlocProvider(
            create: (_) => PatientBloc(
              patientRepo: getIt<IPatientRepository>(),
              authRepo: getIt<IAuthenticationRepository>(),
            ),
          ),
        ],
        child: _AppView(
          authenticationRepository: _authenticationRepository,
        ),
      ),
    );
  }
}

class _AppView extends StatefulWidget {
  final IAuthenticationRepository authenticationRepository;

  const _AppView({super.key, required this.authenticationRepository});

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

            if (state is AuthSuccess) {
              if (state.role == Role.patient) {
                navigatePatient(state.status);
              } else {
                navigateDoctor(state.status);
              }
            }
          },
          child: child,
        );
      },
      onGenerateRoute: (settings) {
        return MaterialPageRoute<void>(
          builder: (context) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
        );
      },
      theme: lightTheme,
    );
  }

  void navigatePatient(AuthStatus status) {
    switch (status) {
      case AuthStatus.authenticated:
        // check if user is has their email verified
        AppGlobal.navigatorKey.currentState?.pushAndRemoveUntil<void>(
          NavigationPatientScreen.route(
              widget.authenticationRepository.currentUser.uid),
          (route) => false,
        );
        break;
      case AuthStatus.anonymous:
        AppGlobal.navigatorKey.currentState?.pushAndRemoveUntil<void>(
          NavigationPatientScreen.route(
              widget.authenticationRepository.currentUser.uid),
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
