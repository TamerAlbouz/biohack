import 'package:backend/src/exceptions/base_exception.dart';

class DoctorException implements BaseException {
  final String code;

  const DoctorException(this.code);

  factory DoctorException.fromCode(String code) {
    return DoctorException(BaseException.fromCode(code));
  }

  @override
  String get message => "An error occurred while processing appointment";
}
