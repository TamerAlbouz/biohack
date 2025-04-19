import 'package:medtalk/backend/exceptions/base_exception.dart';

class StorageException implements BaseException {
  final String code;

  const StorageException(this.code);

  factory StorageException.fromCode(String code) {
    return StorageException(BaseException.fromCode(code));
  }

  @override
  String get message => "An error occurred while processing service";
}
