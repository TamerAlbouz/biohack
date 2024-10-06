import 'package:authentication/authentication.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medtalk/auth/bloc/auth_bloc.dart';
import 'package:medtalk/login/screens/login_screen.dart';
import 'package:medtalk/splash/screens/splash_screen.dart';
import 'package:medtalk/styles/themes.dart';

import '../../home/screens/home_screen.dart';

class App extends StatelessWidget {
  const App({
    required AuthenticationRepository authenticationRepository,
    super.key,
  }) : _authenticationRepository = authenticationRepository;

  final AuthenticationRepository _authenticationRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: _authenticationRepository,
      child: BlocProvider(
        lazy: false,
        create: (_) => AuthBloc(
          authRepo: _authenticationRepository,
        )..add(AuthSubscriptionRequested()),
        child: const AppView(),
      ),
    );
  }
}

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState get _navigator => _navigatorKey.currentState!;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      builder: (context, child) {
        return BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            switch (state.status) {
              case AuthStatus.authenticated:
                _navigator.pushAndRemoveUntil<void>(
                  HomeScreen.route(),
                  (route) => false,
                );
              case AuthStatus.unauthenticated:
                _navigator.pushAndRemoveUntil<void>(
                  LoginScreen.route(),
                  (route) => false,
                );
            }
          },
          child: child,
        );
      },
      onGenerateRoute: (_) => SplashScreen.route(),
      theme: darkTheme,
    );
  }
}
