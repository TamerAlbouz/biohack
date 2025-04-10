part of 'document_bloc.dart';

abstract class PatientDocumentState extends Equatable {
  const PatientDocumentState();

  @override
  List<Object> get props => [];
}

class PatientDocumentsInitial extends PatientDocumentState {}

class PatientDocumentsLoading extends PatientDocumentState {}

class PatientDocumentsLoaded extends PatientDocumentState {
  final List<MedicalDocument> documents;

  const PatientDocumentsLoaded(this.documents);

  @override
  List<Object> get props => [documents];
}

class PatientDocumentsError extends PatientDocumentState {
  final String message;

  const PatientDocumentsError(this.message);
}
