import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medtalk/styles/styles/button.dart';
import 'package:models/models.dart';

import '../../common/widgets/logo_widget.dart';
import '../../styles/font.dart';
import '../../styles/sizes.dart';
import '../bloc/auth/auth_bloc.dart';

class Auth extends StatelessWidget {
  const Auth({
    super.key,
  });

  // add route
  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const Auth());
  }

  @override
  Widget build(BuildContext context) {
    return const _AppView();
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
    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthInitial ||
              state is AuthLoading ||
              state is AuthLogin) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AuthFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const LogoWidget(),
                  const Text(
                    'An error occurred while loading the application',
                    style: TextStyle(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthSubscriptionRequested());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is AuthChooseRole) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Padding(
                  padding: kPaddH42,
                  child: Column(children: [
                    kGap128,
                    LogoWidget(),
                    kGap14,
                    Text(
                      'Welcome! \nAre you a doctor or a patient?',
                      style: TextStyle(fontSize: Font.mediumLarge),
                      textAlign: TextAlign.center,
                    ),
                  ]),
                ),
                kGap68,
                Padding(
                  padding: kPaddH42,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(ChooseRole(Role.doctor));
                        },
                        style: kMainButtonStyle,
                        child: const Text('I am a Doctor'),
                      ),
                      kGap14,
                      ElevatedButton(
                        onPressed: () async {
                          context
                              .read<AuthBloc>()
                              .add(ChooseRole(Role.patient));
                        },
                        style: kMainButtonStyle,
                        child: const Text('I am a Patient'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SvgPicture.asset(
                    "assets/svgs/Cool-Waves.svg",
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomCenter,
                    width: double.infinity,
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
