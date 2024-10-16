import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medtalk/navigation/cubit/navigation_patient_cubit.dart';

import '../../dashboard/screens/dashboard_screen.dart';
import '../models/enums/navbar_screen_items_patients.dart';
import '../widgets/svg_bottom_navbar.dart';

class NavigationPatient extends StatelessWidget {
  const NavigationPatient({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const NavigationPatient());
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
            icon: Icon(
              Icons.health_and_safety,
            ),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_search_rounded,
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.calendar_month,
            ),
            label: 'Appointment',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.document_scanner,
            ),
            label: 'Documents',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings,
            ),
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
