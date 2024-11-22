import 'package:backend/src/exceptions/base_exception.dart';

class EncryptionException implements BaseException {
  final String code;

  const EncryptionException(this.code);

  factory EncryptionException.fromCode(String code) {
    return EncryptionException(BaseException.fromCode(code));
  }

  @override
  String get message => "An error occurred while processing appointment";
}
