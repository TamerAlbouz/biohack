import 'package:backend/backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medtalk/patient/dashboard/bloc/appointment/appointment_bloc.dart';
import 'package:medtalk/patient/profile/screens/profile_screen.dart';
import 'package:medtalk/patient/search_doctors/screens/search_doctors_screen.dart';

import '../../../app/bloc/auth/route_bloc.dart';
import '../../../common/widgets/custom_bottom_navbar.dart';
import '../../../styles/sizes.dart';
import '../../chat/bloc/chat_list/chat_list_bloc.dart';
import '../../chat/bloc/chat_list/chat_list_event.dart';
import '../../chat/screens/chat_list.dart';
import '../../dashboard/screens/patient_dashboard_screen.dart';
import '../../profile/bloc/patient_profile_bloc.dart';
import '../cubit/navigation_patient_cubit.dart';
import '../enums/navbar_screen_items_patients.dart';

class NavigationPatientScreen extends StatelessWidget {
  const NavigationPatientScreen({super.key, required this.patientId});

  final String patientId;

  static Route<void> route(String patientId) {
    return MaterialPageRoute<void>(
        builder: (_) => NavigationPatientScreen(
              patientId: patientId,
            ));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => PatientAppointmentBloc(
            appointmentRepo: getIt<IAppointmentRepository>(),
          ),
        ),
        BlocProvider<NavigationPatientCubit>(
            create: (context) => NavigationPatientCubit()),
        BlocProvider(
          create: (context) => ChatsListBloc(getIt<IChatRepository>())
            ..add(LoadChatsList(
                (context.read<RouteBloc>().state as AuthSuccess).user.uid)),
        ),
        BlocProvider(
          create: (_) => PatientProfileBloc(
            getIt<IPatientRepository>(),
          )..add(
              LoadPatientProfile(patientId),
            ),
        ),
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
      appBar: AppBar(
        toolbarHeight: 10,
      ),
      body: const Padding(
        padding: kPaddH20,
        child: _Body(),
      ),
      bottomNavigationBar:
          CustomBottomNavBar<NavigationPatientCubit, NavigationPatientState>(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_search_outlined),
            activeIcon: Icon(Icons.person_search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_outlined),
            activeIcon: Icon(Icons.folder),
            label: 'Documents',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            activeIcon: Icon(Icons.account_circle),
            label: 'Profile',
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
            .getCurrentNavbarItem(NavbarScreenItemsPatient.chats);
        break;
      case 3:
        BlocProvider.of<NavigationPatientCubit>(context)
            .getCurrentNavbarItem(NavbarScreenItemsPatient.documents);
        break;
      case 4:
        BlocProvider.of<NavigationPatientCubit>(context)
            .getCurrentNavbarItem(NavbarScreenItemsPatient.profile);
        break;
      default:
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
        case NavbarScreenItemsPatient.chats:
          return const ChatsListScreen();
        case NavbarScreenItemsPatient.documents:
          return const Text('Documents Screen');
        case NavbarScreenItemsPatient.profile:
          return const PatientProfileScreen();
        default:
          return const Text('Error. Please try again');
      }
    });
  }
}
