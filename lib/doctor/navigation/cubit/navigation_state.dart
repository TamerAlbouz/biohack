part of 'navigation_doctor_cubit.dart';

final class NavigationDoctorState extends NavbarStateBase {
  NavigationDoctorState({
    required this.navbarItem,
    required this.index,
    this.isActive = false,
    this.isLoading = false,
    this.inactiveMessage = '',
  });

  final NavbarScreenItemsDoctor navbarItem;
  @override
  final int index;
  final bool isLoading;
  final bool isActive;
  final String inactiveMessage;

  NavigationDoctorState copyWith({
    NavbarScreenItemsDoctor? navbarItem,
    int? index,
    bool? isLoading,
    bool? isActive,
    String? inactiveMessage,
  }) {
    return NavigationDoctorState(
      navbarItem: navbarItem ?? this.navbarItem,
      index: index ?? this.index,
      isLoading: isLoading ?? this.isLoading,
      isActive: isActive ?? this.isActive,
      inactiveMessage: inactiveMessage ?? this.inactiveMessage,
    );
  }

  @override
  List<Object> get props =>
      [navbarItem, index, isActive, inactiveMessage, isLoading];
}
