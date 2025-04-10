import 'package:backend/backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medtalk/doctor/appointments/bloc/doctor_appointments_bloc.dart';
import 'package:medtalk/doctor/dashboard/screens/doctor_dashboard_screen.dart';
import 'package:medtalk/doctor/design/screens/design_screen.dart';
import 'package:medtalk/doctor/patients/screens/patients_screen.dart';

import '../../../common/widgets/custom_bottom_navbar.dart';
import '../../appointments/screens/appointments_screen.dart';
import '../../dashboard/bloc/doctor_dashboard_bloc.dart';
import '../../patients/bloc/patients_list_bloc.dart';
import '../../stats/bloc/statistics_bloc.dart';
import '../../stats/screens/statistics_screen.dart';
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
        BlocProvider<DoctorAppointmentsBloc>(
            create: (context) => DoctorAppointmentsBloc(
                  getIt<IAppointmentRepository>(),
                  context.read<IAuthenticationRepository>(),
                  getIt<IPatientRepository>(),
                )..add(LoadDoctorAppointments())),
        BlocProvider<DoctorDashboardBloc>(
            create: (context) => DoctorDashboardBloc(
                  getIt<IAuthenticationRepository>(),
                  getIt<IAppointmentRepository>(),
                  getIt<IPatientRepository>(),
                )),
        BlocProvider<DoctorStatsBloc>(
            create: (context) => DoctorStatsBloc(
                  getIt<IAuthenticationRepository>(),
                  getIt<IAppointmentRepository>(),
                  getIt<IPatientRepository>(),
                )),
        BlocProvider<PatientsBloc>(
            create: (context) => PatientsBloc(
                  getIt<IAuthenticationRepository>(),
                  getIt<IPatientRepository>(),
                  getIt<IAppointmentRepository>(),
                )),
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
          CustomBottomNavBar<NavigationDoctorCubit, NavigationDoctorState>(
        items: const [
          BottomNavigationBarItem(
            activeIcon: Icon(FontAwesomeIcons.heartPulse),
            icon: Icon(FontAwesomeIcons.heart),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(FontAwesomeIcons.solidCalendar),
            icon: Icon(FontAwesomeIcons.calendar),
            label: 'Appoint.',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(FontAwesomeIcons.solidChartBar),
            icon: Icon(FontAwesomeIcons.chartBar),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.design_services, size: 27),
            icon: Icon(Icons.design_services_outlined, size: 27),
            label: 'Design',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.people_alt, size: 27),
            icon: Icon(Icons.people_alt_outlined, size: 27),
            label: 'Patients',
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
            .getCurrentNavbarItem(NavbarScreenItemsDoctor.patients);
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
          return const DoctorDashboardScreen();
        case NavbarScreenItemsDoctor.appointments:
          return const DoctorAppointmentsScreen();
        case NavbarScreenItemsDoctor.stats:
          return const DoctorStatsScreen();
        case NavbarScreenItemsDoctor.design:
          return const DesignScreen();
        case NavbarScreenItemsDoctor.patients:
          return const PatientsScreen();
      }
    });
  }
}
