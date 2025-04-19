import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../common/state/navbar_state_base.dart';
import '../enums/navbar_screen_items_patients.dart';

part 'navigation_state.dart';

@injectable
class NavigationPatientCubit extends Cubit<NavigationPatientState> {
  NavigationPatientCubit()
      : super(NavigationPatientState(NavbarScreenItemsPatient.dashboard, 0));

  void getCurrentNavbarItem(NavbarScreenItemsPatient navbarItem) {
    switch (navbarItem) {
      case NavbarScreenItemsPatient.dashboard:
        emit(NavigationPatientState(NavbarScreenItemsPatient.dashboard, 0));
        break;
      case NavbarScreenItemsPatient.search:
        emit(NavigationPatientState(NavbarScreenItemsPatient.search, 1));
        break;
      case NavbarScreenItemsPatient.chats:
        emit(NavigationPatientState(NavbarScreenItemsPatient.chats, 2));
        break;
      case NavbarScreenItemsPatient.documents:
        emit(NavigationPatientState(NavbarScreenItemsPatient.documents, 3));
        break;
      case NavbarScreenItemsPatient.profile:
        emit(NavigationPatientState(NavbarScreenItemsPatient.profile, 4));
        break;
    }
  }
}
