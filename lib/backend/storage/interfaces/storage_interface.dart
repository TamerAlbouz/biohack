import 'dart:typed_data';

// Interface definition for storage operations
abstract class IStorageRepository {
  /// Uploads a file from a local path to Firebase Storage
  Future<String> uploadFile(String localPath, String remotePath,
      {String? contentType});

  /// Uploads bytes directly to Firebase Storage
  Future<String> uploadBytes(Uint8List bytes, String remotePath,
      {String? contentType});

  /// Deletes a file from Firebase Storage
  Future<void> deleteFile(String remotePath);

  /// Gets a download URL for a file in Firebase Storage
  Future<String> getDownloadURL(String remotePath);
}
