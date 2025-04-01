part of 'search_doctors_bloc.dart';

abstract class SearchDoctorsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SearchDoctorsLoad extends SearchDoctorsEvent {}

class SearchDoctorsLoadMore extends SearchDoctorsEvent {}
