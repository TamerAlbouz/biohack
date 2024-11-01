import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medtalk/navigation/cubit/navigation_patient_cubit.dart';

import '../../dashboard/patient/screens/dashboard_screen.dart';
import '../models/enums/navbar_screen_items_patients.dart';
import '../widgets/svg_bottom_navbar.dart';

class NavigationPatientScreen extends StatelessWidget {
  const NavigationPatientScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
        builder: (_) => const NavigationPatientScreen());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NavigationPatientCubit>(
      create: (context) => NavigationPatientCubit(),
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
          SvgBottomNavBar<NavigationPatientCubit, NavigationPatientState>(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.heartPulse, size: 36),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.magnifyingGlass, size: 34),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.solidComments, size: 34),
            label: 'Appointment',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.folderOpen, size: 34),
            label: 'Documents',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.gear, size: 34),
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
        BlocProvider.of<NavigationPatientCubit>(context)
            .getCurrentNavbarItem(NavbarScreenItemsPatient.dashboard);
        break;
      case 1:
        BlocProvider.of<NavigationPatientCubit>(context)
            .getCurrentNavbarItem(NavbarScreenItemsPatient.search);
        break;
      case 2:
        BlocProvider.of<NavigationPatientCubit>(context)
            .getCurrentNavbarItem(NavbarScreenItemsPatient.appointments);
        break;
      case 3:
        BlocProvider.of<NavigationPatientCubit>(context)
            .getCurrentNavbarItem(NavbarScreenItemsPatient.documents);
        break;
      case 4:
        BlocProvider.of<NavigationPatientCubit>(context)
            .getCurrentNavbarItem(NavbarScreenItemsPatient.settings);
        break;
      default:
        BlocProvider.of<NavigationPatientCubit>(context)
            .getCurrentNavbarItem(NavbarScreenItemsPatient.dashboard);
        break;
    }
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationPatientCubit, NavigationPatientState>(
        builder: (context, state) {
      switch (state.navbarItem) {
        case NavbarScreenItemsPatient.dashboard:
          return const DashboardScreen();
        case NavbarScreenItemsPatient.search:
          return const Text('Search Screen');
        case NavbarScreenItemsPatient.appointments:
          return const Text('Appointments Screen');
        case NavbarScreenItemsPatient.documents:
          return const Text('Documents Screen');
        case NavbarScreenItemsPatient.settings:
          return const Text('Settings Screen');
        default:
          return const DashboardScreen();
      }
    });
  }
}
