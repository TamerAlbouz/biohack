import 'package:backend/backend.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'document_event.dart';
part 'document_state.dart';

class PatientDocumentBloc
    extends Bloc<PatientDocumentEvent, PatientDocumentState> {
  PatientDocumentBloc({
    required IMedicalDocumentRepository documentRepo,
  })  : _documentRepo = documentRepo,
        super(PatientDocumentsInitial()) {
    on<LoadPatientDocuments>(_onLoadPatientDocuments);
  }

  final IMedicalDocumentRepository _documentRepo;

  Future<void> _onLoadPatientDocuments(
      LoadPatientDocuments event, Emitter<PatientDocumentState> emit) async {
    emit(PatientDocumentsLoading());
    try {
      final documents =
          await _documentRepo.getPatientDocuments(event.patientId);
      emit(PatientDocumentsLoaded(documents));
    } catch (e) {
      emit(PatientDocumentsError(e.toString()));
    }
  }
}
