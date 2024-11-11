import 'package:equatable/equatable.dart';

abstract class NavbarStateBase extends Equatable {
  int get index;

  @override
  List<Object> get props => [index];
}
