import 'package:bloc/bloc.dart';

import '../../../common/state/navbar_state_base.dart';
import '../enums/navbar_screen_items_doctor.dart';

part 'navigation_state.dart';

class NavigationDoctorCubit extends Cubit<NavigationDoctorState> {
  NavigationDoctorCubit()
      : super(NavigationDoctorState(NavbarScreenItemsDoctor.dashboard, 0));

  void getCurrentNavbarItem(NavbarScreenItemsDoctor navbarItem) {
    switch (navbarItem) {
      case NavbarScreenItemsDoctor.dashboard:
        emit(NavigationDoctorState(NavbarScreenItemsDoctor.dashboard, 0));
        break;
      case NavbarScreenItemsDoctor.appointments:
        emit(NavigationDoctorState(NavbarScreenItemsDoctor.appointments, 1));
        break;
      case NavbarScreenItemsDoctor.stats:
        emit(NavigationDoctorState(NavbarScreenItemsDoctor.stats, 2));
        break;
      case NavbarScreenItemsDoctor.design:
        emit(NavigationDoctorState(NavbarScreenItemsDoctor.design, 3));
        break;
      case NavbarScreenItemsDoctor.patients:
        emit(NavigationDoctorState(NavbarScreenItemsDoctor.patients, 4));
        break;
    }
  }
}
