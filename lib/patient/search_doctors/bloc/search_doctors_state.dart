part of 'search_doctors_bloc.dart';

abstract class SearchDoctorsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SearchDoctorsInitial extends SearchDoctorsState {}

class SearchDoctorsLoading extends SearchDoctorsState {}

// In your state file, add a new field to track loading more state
class SearchDoctorsLoaded extends SearchDoctorsState {
  final List<Doctor> doctors;
  final bool hasMoreData;
  final DocumentSnapshot? lastDocument;
  final bool isLoadingMore; // Add this field

  SearchDoctorsLoaded({
    required this.doctors,
    required this.hasMoreData,
    this.lastDocument,
    this.isLoadingMore = false, // Default to false
  });

  @override
  List<Object?> get props =>
      [doctors, hasMoreData, lastDocument, isLoadingMore];

  // Add a copyWith method for easier state updates
  SearchDoctorsLoaded copyWith({
    List<Doctor>? doctors,
    bool? hasMoreData,
    DocumentSnapshot? lastDocument,
    bool? isLoadingMore,
  }) {
    return SearchDoctorsLoaded(
      doctors: doctors ?? this.doctors,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      lastDocument: lastDocument ?? this.lastDocument,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class SearchDoctorsError extends SearchDoctorsState {
  final String message;

  SearchDoctorsError(this.message);

  @override
  List<Object> get props => [message];
}
