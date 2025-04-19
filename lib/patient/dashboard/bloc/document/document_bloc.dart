import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:medtalk/backend/medical_doc/interfaces/medical_doc_interface.dart';
import 'package:medtalk/backend/medical_doc/models/medical_doc.dart';

part 'document_event.dart';
part 'document_state.dart';

@injectable
class PatientDocumentBloc
    extends Bloc<PatientDocumentEvent, PatientDocumentState> {
  PatientDocumentBloc(this._documentRepo) : super(PatientDocumentsInitial()) {
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
