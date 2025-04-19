import 'package:medtalk/backend/exceptions/base_exception.dart';

class PatientException implements BaseException {
  final String code;

  const PatientException(this.code);

  factory PatientException.fromCode(String code) {
    return PatientException(BaseException.fromCode(code));
  }

  @override
  String get message => "An error occurred while processing appointment";
}
