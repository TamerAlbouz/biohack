import 'package:backend/backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medtalk/common/globals/globals.dart';
import 'package:medtalk/loading/screens/loading_screen.dart';
import 'package:medtalk/patient/dashboard/bloc/appointment/appointment_bloc.dart';
import 'package:medtalk/patient/dashboard/bloc/patient/patient_bloc.dart';
import 'package:medtalk/patient/intro/screens/intro_screen_patient.dart';
import 'package:medtalk/patient/login/screens/login_patient_screen.dart';
import 'package:medtalk/patient/navigation/screens/navigation_patient_screen.dart';
import 'package:medtalk/styles/themes.dart';

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
        RepositoryProvider.value(
          value: _authenticationRepository,
        ),
        RepositoryProvider.value(value: getIt<IUserRepository>()),
        RepositoryProvider.value(value: getIt<IAppointmentRepository>()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            lazy: false,
            create: (_) => RouteBloc(
              authRepo: _authenticationRepository,
              userPreferences: getIt<UserPreferences>(),
              patientRepository: getIt<IPatientRepository>(),
            )..add(AuthSubscriptionRequested()),
          ),
          BlocProvider(
            create: (_) => PatientBloc(
              patientRepo: getIt<IPatientRepository>(),
              authRepo: getIt<IAuthenticationRepository>(),
            )..add(LoadPatient()),
          ),
          BlocProvider(
            create: (_) => AppointmentBloc(
              appointmentRepo: getIt<IAppointmentRepository>(),
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
              _navigateByRoleUnauthenticated(state);
            }

            if (state is AuthSuccess) {
              switch (state.status) {
                case AuthStatus.authenticated:
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
          },
          child: child,
        );
      },
      onGenerateRoute: (_) => LoadingScreen.route(),
      theme: lightTheme,
    );
  }

  void _navigateByRoleUnauthenticated(AuthLogin successState) {
    switch (successState.role) {
      case Role.patient:
        AppGlobal.navigatorKey.currentState?.pushAndRemoveUntil<void>(
          LoginPatientScreen.route(),
          (route) => false,
        );
      case Role.admin:
      case Role.doctor:
      case Role.unknown:
        break;
    }
  }
}
