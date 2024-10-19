import 'package:models/models.dart';

abstract class IMedicalDocumentRepository {
  /// Stream of [MedicalDocument] which will emit a list of medical documents.
  ///
  /// Emits an empty list if there are no medical documents.
  Stream<List<MedicalDocument>> getMedicalDocuments();

  /// Stream of [MedicalDocument] which will emit the medical document with the given [documentId].
  ///
  /// Emits an empty stream if the medical document is not found.
  Stream<MedicalDocument> getMedicalDocument(String documentId);

  /// Adds a new medical document to the collection.
  ///
  /// Throws a [FirebaseException] if an exception occurs.
  Future<void> addMedicalDocument(MedicalDocument medicalDocument);

  /// Updates the medical document with the given [documentId].
  ///
  /// Throws a [FirebaseException] if an exception occurs.
  Future<void> updateMedicalDocument(MedicalDocument medicalDocument);

  /// Deletes the medical document with the given [documentId].
  ///
  /// Throws a [FirebaseException] if an exception occurs.
  Future<void> deleteMedicalDocument(String documentId);
}
