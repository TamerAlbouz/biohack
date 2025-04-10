// Example model classes (in a real app, these would be defined elsewhere)
enum DocumentType { medicalRecord, labReport, prescription, other }

class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final String? attachmentUrl;
  final String? attachmentType;
  final String? attachmentName;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.attachmentUrl,
    this.attachmentType,
    this.attachmentName,
  });

  bool get hasAttachment => attachmentUrl != null && attachmentUrl!.isNotEmpty;
}

// This class would need to be in the models file
class MessageAttachment {
  final String id;
  final String url;
  final String name;
  final String type;
  final DateTime uploadedAt;

  MessageAttachment({
    required this.id,
    required this.url,
    required this.name,
    required this.type,
    required this.uploadedAt,
  });
}

// Extension to Message model
extension MessageExtension on Message {
  bool get hasAttachment => attachmentUrl != null && attachmentUrl!.isNotEmpty;

  String? get attachmentName => attachmentName;
}

class PatientDocument {
  final String id;
  final String title;
  final DocumentType type;
  final String? patientId;
  final String? description;
  final DateTime uploadDate;
  final String fileUrl;

  PatientDocument({
    required this.id,
    required this.title,
    required this.type,
    this.patientId,
    this.description,
    required this.uploadDate,
    required this.fileUrl,
  });
}

// Define FileAttachment in this file as well for reference
class FileAttachment {
  final String filePath;
  final String fileName;
  final String fileType; // 'image' or 'document'

  FileAttachment({
    required this.filePath,
    required this.fileName,
    required this.fileType,
  });
}
