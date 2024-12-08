import 'package:backend/src/exceptions/base_exception.dart';

class ServiceException implements BaseException {
  final String code;

  const ServiceException(this.code);

  factory ServiceException.fromCode(String code) {
    return ServiceException(BaseException.fromCode(code));
  }

  @override
  String get message => "An error occurred while processing service";
}
