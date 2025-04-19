// Implementation of the storage repository using Firebase Storage
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

import '../exceptions/storage_exception.dart';
import '../interfaces/storage_interface.dart';

@LazySingleton(as: IStorageRepository)
class StorageRepository implements IStorageRepository {
  final FirebaseStorage _storage;
  final Logger logger;

  StorageRepository({
    FirebaseStorage? storage,
    required this.logger,
  }) : _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<String> uploadFile(String localPath, String remotePath,
      {String? contentType}) async {
    try {
      logger.i('Uploading file from $localPath to $remotePath');

      final ref = _storage.ref().child(remotePath);

      UploadTask uploadTask;

      if (contentType != null) {
        final metadata = SettableMetadata(contentType: contentType);
        uploadTask = ref.putFile(File(localPath), metadata);
      } else {
        uploadTask = ref.putFile(File(localPath));
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      logger.i('File uploaded successfully. Download URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      logger.e('Error uploading file: $e');
      throw StorageException('Error uploading file: $e');
    }
  }

  @override
  Future<String> uploadBytes(Uint8List bytes, String remotePath,
      {String? contentType}) async {
    try {
      logger.i('Uploading bytes to $remotePath');

      final ref = _storage.ref().child(remotePath);

      UploadTask uploadTask;

      if (contentType != null) {
        final metadata = SettableMetadata(contentType: contentType);
        uploadTask = ref.putData(bytes, metadata);
      } else {
        uploadTask = ref.putData(bytes);
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      logger.i('Bytes uploaded successfully. Download URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      logger.e('Error uploading bytes: $e');
      throw StorageException('Error uploading bytes: $e');
    }
  }

  @override
  Future<void> deleteFile(String remotePath) async {
    try {
      logger.i('Deleting file at $remotePath');
      await _storage.ref().child(remotePath).delete();
      logger.i('File deleted successfully');
    } catch (e) {
      logger.e('Error deleting file: $e');
      throw StorageException('Error deleting file: $e');
    }
  }

  @override
  Future<String> getDownloadURL(String remotePath) async {
    try {
      logger.i('Getting download URL for $remotePath');
      final downloadUrl =
          await _storage.ref().child(remotePath).getDownloadURL();
      return downloadUrl;
    } catch (e) {
      logger.e('Error getting download URL: $e');
      throw StorageException('Error getting download URL: $e');
    }
  }
}
