import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:models/models.dart';
import 'package:p_logger/p_logger.dart';

import '../interfaces/medical_doc_interface.dart';

@LazySingleton(as: IMedicalDocumentRepository)
class MedicalDocumentRepository implements IMedicalDocumentRepository {
  final FirebaseFirestore _firestore;
  late final CollectionReference _medicalDocumentCollection;

  MedicalDocumentRepository(this._firestore) {
    _medicalDocumentCollection = _firestore.collection('medical_documents');
  }

  @override
  Stream<List<MedicalDocument>> getMedicalDocuments() {
    try {
      return _medicalDocumentCollection.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return MedicalDocument.fromMap(doc.data() as Map<String, dynamic>);
        }).toList();
      });
    } on FirebaseException catch (e) {
      logger.e(e.message);
      rethrow;
    } catch (e) {
      logger.e(e);
      rethrow;
    }
  }

  @override
  Stream<MedicalDocument> getMedicalDocument(String documentId) {
    try {
      return _medicalDocumentCollection.doc(documentId).snapshots().map((doc) {
        return MedicalDocument.fromMap(doc.data() as Map<String, dynamic>);
      });
    } on FirebaseException catch (e) {
      logger.e(e.message);
      rethrow;
    } catch (e) {
      logger.e(e);
      rethrow;
    }
  }

  @override
  Future<void> addMedicalDocument(MedicalDocument medicalDocument) {
    try {
      return _medicalDocumentCollection.add(medicalDocument.toMap());
    } on FirebaseException catch (e) {
      logger.e(e.message);
      rethrow;
    } catch (e) {
      logger.e(e);
      rethrow;
    }
  }

  @override
  Future<void> updateMedicalDocument(MedicalDocument medicalDocument) {
    try {
      return _medicalDocumentCollection
          .doc(medicalDocument.documentId)
          .update(medicalDocument.toMap());
    } on FirebaseException catch (e) {
      logger.e(e.message);
      rethrow;
    } catch (e) {
      logger.e(e);
      rethrow;
    }
  }

  @override
  Future<void> deleteMedicalDocument(String documentId) {
    try {
      return _medicalDocumentCollection.doc(documentId).delete();
    } on FirebaseException catch (e) {
      logger.e(e.message);
      rethrow;
    } catch (e) {
      logger.e(e);
      rethrow;
    }
  }
}
