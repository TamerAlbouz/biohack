import 'package:equatable/equatable.dart';

import '../enums/medical_doc_type.dart';

class MedicalDocument extends Equatable {
  const MedicalDocument({
    required this.documentId,
    required this.patientId,
    required this.doctorId,
    required this.fileUrl,
    this.appointmentId,
    this.type,
    this.title,
    this.notes,
    this.tags,
    this.createdAt,
    this.updatedAt,
    this.isSharedWithPatient = false,
  });

  /// Unique ID for the document.
  final String documentId;

  /// The ID of the patient to whom the document belongs.
  final String patientId;

  /// The ID of the doctor who created/uploaded the document.
  final String doctorId;

  /// The ID of the related appointment, if applicable.
  final String? appointmentId;

  /// The type of document (e.g., "prescription", "lab_report").
  final MedicalDocumentType? type;

  /// Title or short description of the document.
  final String? title;

  /// Notes or additional information about the document.
  final String? notes;

  /// List of tags for easier search and categorization.
  final List<String>? tags;

  /// URL to the file stored in Firebase Storage.
  final String fileUrl;

  /// Timestamp when the document was created.
  final DateTime? createdAt;

  /// Timestamp when the document was last updated.
  final DateTime? updatedAt;

  /// Indicates if the document is shared with the patient.
  final bool isSharedWithPatient;

  /// Creates a copy of this instance with optional updated fields.
  MedicalDocument copyWith({
    String? documentId,
    String? patientId,
    String? doctorId,
    String? appointmentId,
    MedicalDocumentType? type,
    String? title,
    String? notes,
    List<String>? tags,
    String? fileUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSharedWithPatient,
  }) {
    return MedicalDocument(
      documentId: documentId ?? this.documentId,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      appointmentId: appointmentId ?? this.appointmentId,
      type: type ?? this.type,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      fileUrl: fileUrl ?? this.fileUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSharedWithPatient: isSharedWithPatient ?? this.isSharedWithPatient,
    );
  }

  /// Converts a [Map<String, dynamic>] to a [MedicalDocument].
  factory MedicalDocument.fromMap(Map<String, dynamic> data) {
    return MedicalDocument(
      documentId: data['documentId'],
      patientId: data['patientId'],
      doctorId: data['doctorId'],
      appointmentId: data['appointmentId'],
      type: data['type'],
      title: data['title'],
      notes: data['notes'],
      tags: data['tags'] != null ? List<String>.from(data['tags']) : null,
      fileUrl: data['fileUrl'],
      createdAt:
          data['createdAt'] != null ? DateTime.parse(data['createdAt']) : null,
      updatedAt:
          data['updatedAt'] != null ? DateTime.parse(data['updatedAt']) : null,
      isSharedWithPatient: data['isSharedWithPatient'] ?? false,
    );
  }

  /// Converts a [MedicalDocument] to a [Map<String, dynamic>].
  Map<String, dynamic> toMap() {
    return {
      'documentId': documentId,
      'patientId': patientId,
      'doctorId': doctorId,
      'appointmentId': appointmentId,
      'type': type,
      'title': title,
      'notes': notes,
      'tags': tags,
      'fileUrl': fileUrl,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isSharedWithPatient': isSharedWithPatient,
    };
  }

  @override
  List<Object?> get props => [
        documentId,
        patientId,
        doctorId,
        appointmentId,
        type,
        title,
        notes,
        tags,
        fileUrl,
        createdAt,
        updatedAt,
        isSharedWithPatient,
      ];
}
