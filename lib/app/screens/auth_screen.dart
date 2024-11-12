import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medtalk/styles/styles/button.dart';
import 'package:models/models.dart';

import '../../common/widgets/logo_widget.dart';
import '../../styles/font.dart';
import '../../styles/sizes.dart';
import '../bloc/auth/route_bloc.dart';

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
      body: BlocBuilder<RouteBloc, RouteState>(
        builder: (context, state) {
          if (state is RouteInitial ||
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
                      context
                          .read<RouteBloc>()
                          .add(AuthSubscriptionRequested());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is AuthChooseRole) {
            return Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Flexible(
                      flex: 2,
                      child: Padding(
                        padding: kPaddH42,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              LogoWidget(),
                              kGap14,
                              Text(
                                'Welcome!',
                                style: TextStyle(
                                    fontSize: Font.mediumLarge,
                                    fontWeight: FontWeight.normal),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                'Who are you?',
                                style: TextStyle(fontSize: Font.medium),
                                textAlign: TextAlign.center,
                              ),
                            ]),
                      ),
                    ),
                    kGap28,
                    Flexible(
                      flex: 3,
                      child: Padding(
                        padding: kPaddH42,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                context
                                    .read<RouteBloc>()
                                    .add(ChooseRole(Role.doctor));
                              },
                              style: kMainButtonStyle,
                              icon: const Icon(FontAwesomeIcons.userDoctor),
                              label: const Text('I am a Doctor'),
                            ),
                            kGap20,
                            ElevatedButton.icon(
                              onPressed: () async {
                                context
                                    .read<RouteBloc>()
                                    .add(ChooseRole(Role.patient));
                              },
                              style: kMainButtonStyle,
                              icon: const Icon(FontAwesomeIcons.userInjured),
                              label: const Text('I am a Patient'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
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
