import 'package:backend/backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medtalk/styles/sizes.dart';

import '../../common/widgets/logo_widget.dart';
import '../../common/widgets/random_hexagons.dart';
import '../../styles/colors.dart';
import '../../styles/font.dart';
import '../../styles/styles/text.dart';
import '../bloc/auth/route_bloc.dart';

class Auth extends StatelessWidget {
  const Auth({super.key});

  static Route<void> route() => MaterialPageRoute(builder: (_) => const Auth());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<RouteBloc, RouteState>(builder: (context, state) {
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
                    context.read<RouteBloc>().add(AuthSubscriptionRequested());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            const HexagonPatternBox(
              height: 180,
              width: double.infinity,
            ),
            kGap20,
            Padding(
              padding: kPaddH20,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome to BioHack!',
                    style: kAppIntro,
                  ),
                  kGap4,
                  const Text(
                    'Choose your role to get started',
                    style: kAppIntroSubtitle,
                    textAlign: TextAlign.left,
                  ),
                  kGap28,
                  _RoleCard(
                    icon: FontAwesomeIcons.userDoctor,
                    title: 'Doctor',
                    description: 'Provide care and manage patients',
                    onTap: () {
                      context.read<RouteBloc>().add(ChooseRole(Role.doctor));
                    },
                  ),
                  kGap12,
                  _RoleCard(
                    icon: FontAwesomeIcons.userInjured,
                    title: 'Patient',
                    description: 'Get medical support and guidance',
                    onTap: () {
                      context.read<RouteBloc>().add(ChooseRole(Role.patient));
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: kPadd0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Card(
        margin: kPadd0,
        color: MyColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: MyColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: MyColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: Font.family,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontFamily: Font.family,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
