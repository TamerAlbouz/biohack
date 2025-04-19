import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medtalk/backend/injectable.dart';
import 'package:medtalk/patient/dashboard/bloc/appointment/appointment_bloc.dart';
import 'package:medtalk/patient/dashboard/bloc/doctor/doctor_bloc.dart';
import 'package:medtalk/patient/profile/screens/profile_screen.dart';
import 'package:medtalk/patient/search_doctors/screens/search_doctors_screen.dart';

import '../../../app/bloc/auth/route_bloc.dart';
import '../../../common/widgets/custom_bottom_navbar.dart';
import '../../chat/bloc/chat_list/chat_list_bloc.dart';
import '../../chat/bloc/chat_list/chat_list_event.dart';
import '../../chat/screens/chat_list.dart';
import '../../dashboard/bloc/document/document_bloc.dart';
import '../../dashboard/screens/patient_dashboard_screen.dart';
import '../../documents/screens/document_management_screen.dart';
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
        BlocProvider(create: (_) => getIt<PatientAppointmentBloc>()),
        BlocProvider<NavigationPatientCubit>(
            create: (context) => getIt<NavigationPatientCubit>()),
        BlocProvider(
          create: (context) => getIt<ChatsListBloc>()
            ..add(LoadChatsList(
                (context.read<RouteBloc>().state as AuthSuccess).user.uid)),
        ),
        BlocProvider(
          create: (_) => getIt<PatientProfileBloc>()
            ..add(
              LoadPatientProfile(patientId),
            ),
        ),
        // document
        BlocProvider<PatientDocumentBloc>(
            create: (BuildContext context) => getIt<PatientDocumentBloc>()
              ..add(LoadPatientDocuments(patientId))),
        BlocProvider<PatientDoctorBloc>(
            create: (BuildContext context) =>
                getIt<PatientDoctorBloc>()..add(LoadPatientDoctors(patientId))),
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
  // Pre-initialize all screens once
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Initialize all screens once to maintain their state
    _screens = [
      const PatientDashboardScreen(),
      const SearchDoctorsScreen(),
      const ChatsListScreen(),
      const DocumentManagementScreen(),
      const PatientProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 10,
      ),
      body: BlocBuilder<NavigationPatientCubit, NavigationPatientState>(
        builder: (context, state) {
          // Get the current index from the state
          final int currentIndex = _getIndexFromNavItem(state.navbarItem);

          // Use IndexedStack to maintain state of all screens
          return IndexedStack(
            index: currentIndex,
            children: _screens,
          );
        },
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

  int _getIndexFromNavItem(NavbarScreenItemsPatient navItem) {
    switch (navItem) {
      case NavbarScreenItemsPatient.dashboard:
        return 0;
      case NavbarScreenItemsPatient.search:
        return 1;
      case NavbarScreenItemsPatient.chats:
        return 2;
      case NavbarScreenItemsPatient.documents:
        return 3;
      case NavbarScreenItemsPatient.profile:
        return 4;
    }
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
