import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:medtalk/backend/doctor/interfaces/doctor_interface.dart';
import 'package:medtalk/backend/doctor/models/doctor.dart';

part 'search_doctors_event.dart';
part 'search_doctors_state.dart';

@injectable
class SearchDoctorsBloc extends Bloc<SearchDoctorsEvent, SearchDoctorsState> {
  SearchDoctorsBloc(
    this._doctorRepository,
    this.logger,
  ) : super(SearchDoctorsInitial()) {
    on<SearchDoctorsLoad>(_onSearchDoctorsLoad);
    on<SearchDoctorsLoadMore>(_onSearchDoctorsLoadMore);
  }

  final IDoctorRepository _doctorRepository;
  final Logger logger;
  static const int _pageSize = 20;

  Future<void> _onSearchDoctorsLoad(
      SearchDoctorsLoad event, Emitter<SearchDoctorsState> emit) async {
    try {
      final (doctors, lastDocument) =
          await _doctorRepository.getDoctorsPaginated(_pageSize, null);

      logger.i('Loaded ${doctors.length} doctors');
      emit(SearchDoctorsLoaded(
        doctors: doctors,
        hasMoreData: doctors.length == _pageSize,
        lastDocument: doctors.isNotEmpty ? lastDocument : null,
      ));
    } catch (e) {
      logger.e(e.toString());
      emit(SearchDoctorsError(e.toString()));
    }
  }

  Future<void> _onSearchDoctorsLoadMore(
      SearchDoctorsLoadMore event, Emitter<SearchDoctorsState> emit) async {
    if (state is SearchDoctorsLoaded) {
      final currentState = state as SearchDoctorsLoaded;

      if (!currentState.hasMoreData || currentState.isLoadingMore) return;

      emit(
          currentState.copyWith(isLoadingMore: true)); // Show loading indicator

      try {
        final (newDoctors, newLastDoc) =
            await _doctorRepository.getDoctorsPaginated(
          _pageSize,
          currentState.lastDocument,
        );

        logger.i('Loaded ${newDoctors.length} more doctors');
        emit(SearchDoctorsLoaded(
          doctors: [...currentState.doctors, ...newDoctors],
          hasMoreData: newDoctors.length == _pageSize,
          lastDocument:
              newDoctors.isNotEmpty ? newLastDoc : currentState.lastDocument,
          isLoadingMore: false, // Hide loading indicator
        ));
      } catch (e) {
        logger.e(e.toString());
        emit(SearchDoctorsError(e.toString()));
      }
    }
  }
}
