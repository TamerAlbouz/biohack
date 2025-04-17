import 'package:backend/backend.dart';
import 'package:bloc/bloc.dart';
import 'package:p_logger/p_logger.dart';

import '../../../common/state/navbar_state_base.dart';
import '../enums/navbar_screen_items_doctor.dart';

part 'navigation_state.dart';

class NavigationDoctorCubit extends Cubit<NavigationDoctorState> {
  NavigationDoctorCubit({
    required IAuthenticationRepository authRepo,
    required IDoctorRepository doctorRepo,
  })  : _authRepo = authRepo,
        _doctorRepo = doctorRepo,
        super(NavigationDoctorState(
            navbarItem: NavbarScreenItemsDoctor.dashboard, index: 0)) {
    // Check doctor's active status upon initialization
    checkDoctorActiveStatus();
  }

  final IAuthenticationRepository _authRepo;
  final IDoctorRepository _doctorRepo;

  Future<void> checkDoctorActiveStatus() async {
    try {
      emit(state.copyWith(
        isActive: false,
        isLoading: true,
        inactiveMessage: '',
      ));

      final userId = _authRepo.currentUser.uid;

      // Fetch the doctor data using the userId
      final doctor = await _doctorRepo.getDoctor(userId);
      logger.i('Doctor data: $doctor');
      if (doctor != null) {
        final isActive = doctor.active;
        String? message;

        if (!isActive) {
          message =
              'Your account is pending approval. Our team is reviewing your credentials.';
        }

        emit(state.copyWith(
          isActive: isActive,
          isLoading: false,
          inactiveMessage: message,
        ));
      }
    } catch (e) {
      // Handle any errors while fetching doctor data
      logger.e('Error checking doctor status: $e');
    }
  }

  void getCurrentNavbarItem(NavbarScreenItemsDoctor navbarItem) {
    emit(state.copyWith(
      navbarItem: navbarItem,
      index: _getIndexForNavbarItem(navbarItem),
    ));
  }

  int _getIndexForNavbarItem(NavbarScreenItemsDoctor navbarItem) {
    switch (navbarItem) {
      case NavbarScreenItemsDoctor.dashboard:
        return 0;
      case NavbarScreenItemsDoctor.appointments:
        return 1;
      case NavbarScreenItemsDoctor.stats:
        return 2;
      case NavbarScreenItemsDoctor.design:
        return 3;
      case NavbarScreenItemsDoctor.patients:
        return 4;
    }
  }
}
