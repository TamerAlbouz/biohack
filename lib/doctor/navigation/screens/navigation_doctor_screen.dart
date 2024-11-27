import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../app/bloc/auth/route_bloc.dart';
import '../../../common/widgets/svg_bottom_navbar.dart';
import '../cubit/navigation_doctor_cubit.dart';
import '../enums/navbar_screen_items_doctor.dart';

class NavigationDoctorScreen extends StatelessWidget {
  const NavigationDoctorScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
        builder: (_) => const NavigationDoctorScreen());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NavigationDoctorCubit>(
            create: (context) => NavigationDoctorCubit()),
      ],
      child: const NavigationPatientView(),
    );
  }
}

class NavigationPatientView extends StatefulWidget {
  const NavigationPatientView({super.key});

  @override
  State<NavigationPatientView> createState() => _NavigationPatientViewState();
}

class _NavigationPatientViewState extends State<NavigationPatientView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const _Body(),
      bottomNavigationBar:
          SvgBottomNavBar<NavigationDoctorCubit, NavigationDoctorState>(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.heartPulse),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.magnifyingGlass),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.solidMessage),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.folderOpen),
            label: 'Documents',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.gear),
            label: 'Settings',
          ),
        ],
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        BlocProvider.of<NavigationDoctorCubit>(context)
            .getCurrentNavbarItem(NavbarScreenItemsDoctor.dashboard);
        break;
      case 1:
        BlocProvider.of<NavigationDoctorCubit>(context)
            .getCurrentNavbarItem(NavbarScreenItemsDoctor.appointments);
        break;
      case 2:
        BlocProvider.of<NavigationDoctorCubit>(context)
            .getCurrentNavbarItem(NavbarScreenItemsDoctor.stats);
        break;
      case 3:
        BlocProvider.of<NavigationDoctorCubit>(context)
            .getCurrentNavbarItem(NavbarScreenItemsDoctor.design);
        break;
      case 4:
        BlocProvider.of<NavigationDoctorCubit>(context)
            .getCurrentNavbarItem(NavbarScreenItemsDoctor.settings);
        break;
      default:
        BlocProvider.of<NavigationDoctorCubit>(context)
            .getCurrentNavbarItem(NavbarScreenItemsDoctor.dashboard);
        break;
    }
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationDoctorCubit, NavigationDoctorState>(
        builder: (context, state) {
      switch (state.navbarItem) {
        case NavbarScreenItemsDoctor.dashboard:
          return const Column(
            children: [
              Text('Dashboard Screen'),
              // logout button
              _LogoutButton(),
            ],
          );
        case NavbarScreenItemsDoctor.appointments:
          return const Text('Appointments Screen');
        case NavbarScreenItemsDoctor.stats:
          return const Text('Stats Screen');
        case NavbarScreenItemsDoctor.design:
          return const Text('Design Screen');
        case NavbarScreenItemsDoctor.settings:
          return const Text('Settings Screen');
        default:
          return const Text('Dashboard Screen');
      }
    });
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: const Text('Logout'),
      onPressed: () {
        context.read<RouteBloc>().add(AuthLogoutPressed());
        // navigate to the auth screen
      },
    );
  }
}
