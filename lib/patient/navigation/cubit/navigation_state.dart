part of 'navigation_patient_cubit.dart';

final class NavigationDoctorState extends NavbarStateBase {
  NavigationDoctorState(
    this.navbarItem,
    this.index,
  );

  final NavigationDoctorState navbarItem;
  @override
  final int index;

  @override
  List<Object> get props => [navbarItem, index];
}

final class NavigationPatientState extends NavbarStateBase {
  NavigationPatientState(
    this.navbarItem,
    this.index,
  );

  final NavbarScreenItemsPatient navbarItem;
  @override
  final int index;

  @override
  List<Object> get props => [navbarItem, index];
}
