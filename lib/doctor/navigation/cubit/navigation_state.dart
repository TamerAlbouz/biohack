part of 'navigation_doctor_cubit.dart';

final class NavigationDoctorState extends NavbarStateBase {
  NavigationDoctorState(
    this.navbarItem,
    this.index,
  );

  final NavbarScreenItemsDoctor navbarItem;
  @override
  final int index;

  @override
  List<Object> get props => [navbarItem, index];
}
