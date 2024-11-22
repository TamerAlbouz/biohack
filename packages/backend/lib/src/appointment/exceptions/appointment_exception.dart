import 'package:backend/src/exceptions/base_exception.dart';

class AppointmentException implements BaseException {
  final String code;

  const AppointmentException(this.code);

  factory AppointmentException.fromCode(String code) {
    return AppointmentException(BaseException.fromCode(code));
  }

  @override
  String get message => "An error occurred while processing appointment";
}
