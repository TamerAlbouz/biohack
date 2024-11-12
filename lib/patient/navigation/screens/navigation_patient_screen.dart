import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medtalk/patient/search_doctors/screens/search_doctors_screen.dart';

import '../../../common/widgets/svg_bottom_navbar.dart';
import '../../dashboard/screens/patient_dashboard_screen.dart';
import '../cubit/navigation_patient_cubit.dart';
import '../enums/navbar_screen_items_patients.dart';

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
          return const PatientDashboardScreen();
        case NavbarScreenItemsPatient.search:
          return const SearchDoctorsScreen();
        case NavbarScreenItemsPatient.appointments:
          return const Text('Appointments Screen');
        case NavbarScreenItemsPatient.documents:
          return const Text('Documents Screen');
        case NavbarScreenItemsPatient.settings:
          return const Text('Settings Screen');
        default:
          return const PatientDashboardScreen();
      }
    });
  }
}
