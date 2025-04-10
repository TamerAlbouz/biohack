part of 'document_bloc.dart';

abstract class PatientDocumentEvent extends Equatable {
  const PatientDocumentEvent();

  @override
  List<Object?> get props => [];
}

class LoadPatientDocuments extends PatientDocumentEvent {
  final String patientId;

  const LoadPatientDocuments(this.patientId);

  @override
  List<Object?> get props => [patientId];
}
