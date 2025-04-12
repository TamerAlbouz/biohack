// First, let's create a file model class to properly manage documents
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

// Document model
class DocumentFile {
  final String id;
  String name;
  String folderPath;
  final DateTime dateCreated;
  DateTime dateModified;
  final int size; // in bytes
  bool isFavorite;

  DocumentFile({
    required this.id,
    required this.name,
    required this.folderPath,
    required this.dateCreated,
    required this.dateModified,
    required this.size,
    this.isFavorite = false,
  });

  // Get file extension
  String get extension =>
      path.extension(name).toLowerCase().replaceAll('.', '');

  // Get folder name
  String get folder => path.basename(folderPath);

  // Get formatted size
  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1048576) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / 1048576).toStringAsFixed(1)} MB';
  }

  // Get formatted date
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(dateModified);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d, yyyy').format(dateModified);
    }
  }

  // Get icon data based on file type
  IconData get icon {
    switch (extension) {
      case 'pdf':
        return FontAwesomeIcons.filePdf;
      case 'doc':
      case 'docx':
        return FontAwesomeIcons.fileWord;
      case 'xls':
      case 'xlsx':
        return FontAwesomeIcons.fileExcel;
      case 'ppt':
      case 'pptx':
        return FontAwesomeIcons.filePowerpoint;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return FontAwesomeIcons.fileImage;
      case 'txt':
        return FontAwesomeIcons.fileLines;
      default:
        return FontAwesomeIcons.file;
    }
  }

  // Get color based on file type
  Color get color {
    switch (extension) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'xls':
      case 'xlsx':
        return Colors.green;
      case 'ppt':
      case 'pptx':
        return Colors.orange;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Colors.purple;
      case 'txt':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  // Create a copy of document
  DocumentFile copyWith({
    String? name,
    String? folderPath,
    DateTime? dateModified,
    bool? isFavorite,
  }) {
    return DocumentFile(
      id: id,
      name: name ?? this.name,
      folderPath: folderPath ?? this.folderPath,
      dateCreated: dateCreated,
      dateModified: dateModified ?? this.dateModified,
      size: size,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  // Validate filename for security
  static bool isValidFileName(String fileName) {
    // Check for invalid characters or patterns
    if (fileName.isEmpty) return false;

    // Check for dangerous characters or patterns
    final invalidChars = RegExp(r'[\\/:*?"<>|]');
    if (invalidChars.hasMatch(fileName)) return false;

    // Prevent path traversal attacks
    if (fileName.contains('..')) return false;

    // Prevent hidden files
    if (fileName.startsWith('.')) return false;

    return true;
  }

  // To Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'folderPath': folderPath,
      'dateCreated': dateCreated.millisecondsSinceEpoch,
      'dateModified': dateModified.millisecondsSinceEpoch,
      'size': size,
      'isFavorite': isFavorite,
    };
  }

  // From Map for storage
  factory DocumentFile.fromMap(Map<String, dynamic> map) {
    return DocumentFile(
      id: map['id'],
      name: map['name'],
      folderPath: map['folderPath'],
      dateCreated: DateTime.fromMillisecondsSinceEpoch(map['dateCreated']),
      dateModified: DateTime.fromMillisecondsSinceEpoch(map['dateModified']),
      size: map['size'],
      isFavorite: map['isFavorite'] ?? false,
    );
  }
}

// Folder model
class DocumentFolder {
  final String id;
  String name;
  final String path;
  final IconData icon;
  final Color color;

  DocumentFolder({
    required this.id,
    required this.name,
    required this.path,
    required this.icon,
    required this.color,
  });
}

// Now, let's create a file service to handle all file operations
class DocumentService {
  static final DocumentService _instance = DocumentService._internal();

  factory DocumentService() => _instance;

  DocumentService._internal();

  List<DocumentFile> _documents = [];
  List<DocumentFolder> _folders = [];

  // Get all documents
  List<DocumentFile> get documents => _documents;

  // Get all folders
  List<DocumentFolder> get folders => _folders;

  // Initialize the service
  Future<void> initialize() async {
    await _loadFolders();
    await _loadDocuments();
  }

  // Load folders
  Future<void> _loadFolders() async {
    _folders = [
      DocumentFolder(
        id: 'medical_records',
        name: 'Medical Records',
        path: 'Medical Records',
        icon: FontAwesomeIcons.fileMedical,
        color: Colors.blue,
      ),
      DocumentFolder(
        id: 'lab_reports',
        name: 'Lab Reports',
        path: 'Lab Reports',
        icon: FontAwesomeIcons.vial,
        color: Colors.purple,
      ),
      DocumentFolder(
        id: 'prescriptions',
        name: 'Prescriptions',
        path: 'Prescriptions',
        icon: FontAwesomeIcons.prescription,
        color: Colors.green,
      ),
      DocumentFolder(
        id: 'insurance',
        name: 'Insurance',
        path: 'Insurance',
        icon: FontAwesomeIcons.shieldHalved,
        color: Colors.orange,
      ),
      DocumentFolder(
        id: 'appointment_notes',
        name: 'Appointment Notes',
        path: 'Appointment Notes',
        icon: FontAwesomeIcons.notesMedical,
        color: Colors.red,
      ),
      DocumentFolder(
        id: 'imaging',
        name: 'Imaging',
        path: 'Imaging',
        icon: FontAwesomeIcons.xRay,
        color: Colors.teal,
      ),
      DocumentFolder(
        id: 'others',
        name: 'Others',
        path: 'Others',
        icon: FontAwesomeIcons.folderOpen,
        color: Colors.grey,
      ),
    ];
  }

  // Load documents from storage
  Future<void> _loadDocuments() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final docsPath = path.join(directory.path, 'medtalk_documents');
      final docsDir = Directory(docsPath);

      if (!await docsDir.exists()) {
        await docsDir.create(recursive: true);
        await _createSampleDocuments(docsPath);
      }

      // Load document metadata from storage
      final metadataFile = File(path.join(docsPath, 'metadata.json'));
      if (await metadataFile.exists()) {
        final jsonData = await metadataFile.readAsString();
        final List<dynamic> data = jsonDecode(jsonData);
        _documents = data.map((item) => DocumentFile.fromMap(item)).toList();
      } else {
        // Create sample metadata if none exists
        await _createSampleDocuments(docsPath);
      }
    } catch (e) {
      print('Error loading documents: $e');
      // Create sample data if there's an error
      _createSampleData();
    }
  }

  // Create sample documents
  Future<void> _createSampleDocuments(String basePath) async {
    // This would create sample document files and metadata in a real app
    // For now, let's just create sample data in memory
    _createSampleData();

    // Save the metadata
    await _saveMetadata();
  }

  // Create sample data for testing
  void _createSampleData() {
    final now = DateTime.now();

    _documents = [
      DocumentFile(
        id: 'doc_1',
        name: 'Annual Physical Report.pdf',
        folderPath: 'Medical Records',
        dateCreated: now.subtract(const Duration(days: 60)),
        dateModified: now.subtract(const Duration(days: 15)),
        size: 3300000,
      ),
      DocumentFile(
        id: 'doc_2',
        name: 'Blood Test Results.pdf',
        folderPath: 'Lab Reports',
        dateCreated: now.subtract(const Duration(days: 10)),
        dateModified: now,
        size: 2400000,
        isFavorite: true,
      ),
      DocumentFile(
        id: 'doc_3',
        name: 'X-Ray Scan.jpg',
        folderPath: 'Imaging',
        dateCreated: now.subtract(const Duration(days: 5)),
        dateModified: now.subtract(const Duration(days: 1)),
        size: 5800000,
      ),
      DocumentFile(
        id: 'doc_4',
        name: 'Antibiotic Prescription.pdf',
        folderPath: 'Prescriptions',
        dateCreated: now.subtract(const Duration(days: 7)),
        dateModified: now.subtract(const Duration(days: 2)),
        size: 1100000,
      ),
      DocumentFile(
        id: 'doc_5',
        name: 'Health Insurance Policy.pdf',
        folderPath: 'Insurance',
        dateCreated: now.subtract(const Duration(days: 90)),
        dateModified: now.subtract(const Duration(days: 90)),
        size: 4500000,
      ),
      DocumentFile(
        id: 'doc_6',
        name: 'Cardiologist Consultation.docx',
        folderPath: 'Appointment Notes',
        dateCreated: now.subtract(const Duration(days: 3)),
        dateModified: now.subtract(const Duration(days: 1)),
        size: 1700000,
      ),
      DocumentFile(
        id: 'doc_7',
        name: 'Medical History Summary.docx',
        folderPath: 'Medical Records',
        dateCreated: now.subtract(const Duration(days: 60)),
        dateModified: now.subtract(const Duration(days: 59)),
        size: 1800000,
      ),
      DocumentFile(
        id: 'doc_8',
        name: 'Cholesterol Panel.pdf',
        folderPath: 'Lab Reports',
        dateCreated: now.subtract(const Duration(days: 20)),
        dateModified: now.subtract(const Duration(days: 19)),
        size: 1600000,
      ),
    ];
  }

  // Save document metadata
  Future<void> _saveMetadata() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final docsPath = path.join(directory.path, 'medtalk_documents');
      final docsDir = Directory(docsPath);

      if (!await docsDir.exists()) {
        await docsDir.create(recursive: true);
      }

      final metadataFile = File(path.join(docsPath, 'metadata.json'));
      final jsonData =
          jsonEncode(_documents.map((doc) => doc.toMap()).toList());
      await metadataFile.writeAsString(jsonData);
    } catch (e) {
      print('Error saving metadata: $e');
    }
  }

  // Get documents by folder
  List<DocumentFile> getDocumentsByFolder(String folder) {
    if (folder == 'All Documents') {
      return _documents;
    } else {
      return _documents.where((doc) => doc.folder == folder).toList();
    }
  }

  // Get recent documents
  List<DocumentFile> getRecentDocuments({int limit = 10}) {
    final sorted = List<DocumentFile>.from(_documents)
      ..sort((a, b) => b.dateModified.compareTo(a.dateModified));
    return sorted.take(limit).toList();
  }

  // Search documents
  List<DocumentFile> searchDocuments(String query, {String? folder}) {
    if (query.isEmpty) {
      return folder == null || folder == 'All Documents'
          ? _documents
          : getDocumentsByFolder(folder);
    }

    final queryLower = query.toLowerCase();
    return _documents.where((doc) {
      final inFolder =
          folder == null || folder == 'All Documents' || doc.folder == folder;
      final matchesName = doc.name.toLowerCase().contains(queryLower);
      return inFolder && matchesName;
    }).toList();
  }

  // Sort documents
  List<DocumentFile> sortDocuments(List<DocumentFile> docs, String sortBy) {
    final sorted = List<DocumentFile>.from(docs);

    switch (sortBy) {
      case 'Date (Newest)':
        sorted.sort((a, b) => b.dateModified.compareTo(a.dateModified));
        break;
      case 'Date (Oldest)':
        sorted.sort((a, b) => a.dateModified.compareTo(b.dateModified));
        break;
      case 'Name (A-Z)':
        sorted.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case 'Name (Z-A)':
        sorted.sort(
            (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
      case 'Size (Largest)':
        sorted.sort((a, b) => b.size.compareTo(a.size));
        break;
      case 'Size (Smallest)':
        sorted.sort((a, b) => a.size.compareTo(b.size));
        break;
    }

    return sorted;
  }

  // Add document
  Future<DocumentFile> addDocument(File file, String folder) async {
    try {
      final now = DateTime.now();
      final id = 'doc_${now.millisecondsSinceEpoch}';
      final fileName = path.basename(file.path);
      final fileSize = await file.length();

      // Create document metadata
      final document = DocumentFile(
        id: id,
        name: fileName,
        folderPath: folder,
        dateCreated: now,
        dateModified: now,
        size: fileSize,
      );

      // Save file to app storage
      final directory = await getApplicationDocumentsDirectory();
      final docsPath = path.join(directory.path, 'medtalk_documents', folder);
      final docsDir = Directory(docsPath);

      if (!await docsDir.exists()) {
        await docsDir.create(recursive: true);
      }

      final savedFile = File(path.join(docsPath, fileName));
      await file.copy(savedFile.path);

      // Add to documents list
      _documents.add(document);

      // Save metadata
      await _saveMetadata();

      return document;
    } catch (e) {
      print('Error adding document: $e');
      rethrow;
    }
  }

  // Delete document
  Future<void> deleteDocument(String documentId) async {
    try {
      final index = _documents.indexWhere((doc) => doc.id == documentId);

      if (index != -1) {
        final document = _documents[index];

        // Delete file from storage
        final directory = await getApplicationDocumentsDirectory();
        final filePath = path.join(directory.path, 'medtalk_documents',
            document.folderPath, document.name);

        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
        }

        // Remove from documents list
        _documents.removeAt(index);

        // Save metadata
        await _saveMetadata();
      }
    } catch (e) {
      print('Error deleting document: $e');
      rethrow;
    }
  }

  // Rename document with enhanced security
  Future<DocumentFile> renameDocument(String documentId, String newName) async {
    try {
      // Validate new filename
      if (!DocumentFile.isValidFileName(newName)) {
        throw Exception(
            'Invalid filename. Filename contains invalid characters.');
      }

      final index = _documents.indexWhere((doc) => doc.id == documentId);

      if (index != -1) {
        final document = _documents[index];
        final oldName = document.name;

        // Sanitize file extension
        final oldExtension = path.extension(oldName);
        if (!newName.endsWith(oldExtension)) {
          // Ensure the file extension remains the same
          newName = '$newName$oldExtension';
        }

        // Check if a file with this name already exists
        final directory = await getApplicationDocumentsDirectory();
        final newPath = path.join(
            directory.path, 'medtalk_documents', document.folderPath, newName);

        if (File(newPath).existsSync()) {
          throw Exception('A file with this name already exists');
        }

        // Verify that the oldPath is within our app directory (security check)
        final oldPath = path.join(
            directory.path, 'medtalk_documents', document.folderPath, oldName);

        if (!oldPath.startsWith(directory.path)) {
          throw Exception(
              'Security error: Cannot access file outside app directory');
        }

        // Rename the file
        final file = File(oldPath);
        if (await file.exists()) {
          await file.rename(newPath);
        } else {
          throw Exception('File not found');
        }

        // Update document metadata
        final updatedDoc = document.copyWith(
          name: newName,
          dateModified: DateTime.now(),
        );

        _documents[index] = updatedDoc;

        // Save metadata
        await _saveMetadata();

        return updatedDoc;
      } else {
        throw Exception('Document not found');
      }
    } catch (e) {
      print('Error renaming document: $e');
      rethrow;
    }
  }

  // Move document
  Future<DocumentFile> moveDocument(String documentId, String newFolder) async {
    try {
      final index = _documents.indexWhere((doc) => doc.id == documentId);

      if (index != -1) {
        final document = _documents[index];
        final oldFolder = document.folderPath;

        if (oldFolder == newFolder) {
          return document;
        }

        // Move file in storage
        final directory = await getApplicationDocumentsDirectory();
        final oldPath = path.join(
            directory.path, 'medtalk_documents', oldFolder, document.name);

        final newFolderPath =
            path.join(directory.path, 'medtalk_documents', newFolder);

        final newFolderDir = Directory(newFolderPath);
        if (!await newFolderDir.exists()) {
          await newFolderDir.create(recursive: true);
        }

        final newPath = path.join(newFolderPath, document.name);

        final file = File(oldPath);
        if (await file.exists()) {
          await file.copy(newPath);
          await file.delete();
        }

        // Update document metadata
        final updatedDoc = document.copyWith(
          folderPath: newFolder,
          dateModified: DateTime.now(),
        );

        _documents[index] = updatedDoc;

        // Save metadata
        await _saveMetadata();

        return updatedDoc;
      } else {
        throw Exception('Document not found');
      }
    } catch (e) {
      print('Error moving document: $e');
      rethrow;
    }
  }

  // Toggle favorite
  Future<DocumentFile> toggleFavorite(String documentId) async {
    try {
      final index = _documents.indexWhere((doc) => doc.id == documentId);

      if (index != -1) {
        final document = _documents[index];

        // Update document metadata
        final updatedDoc = document.copyWith(
          isFavorite: !document.isFavorite,
        );

        _documents[index] = updatedDoc;

        // Save metadata
        await _saveMetadata();

        return updatedDoc;
      } else {
        throw Exception('Document not found');
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      rethrow;
    }
  }

  // Get file path
  Future<String> getFilePath(String documentId) async {
    try {
      final index = _documents.indexWhere((doc) => doc.id == documentId);

      if (index != -1) {
        final document = _documents[index];

        final directory = await getApplicationDocumentsDirectory();
        return path.join(directory.path, 'medtalk_documents',
            document.folderPath, document.name);
      } else {
        throw Exception('Document not found');
      }
    } catch (e) {
      print('Error getting file path: $e');
      rethrow;
    }
  }

  // Get folder counts
  Map<String, int> getFolderCounts() {
    final counts = <String, int>{};

    for (final folder in _folders) {
      final count = _documents.where((doc) => doc.folder == folder.name).length;
      counts[folder.name] = count;
    }

    return counts;
  }
}
