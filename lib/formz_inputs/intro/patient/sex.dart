import 'package:formz/formz.dart';

enum SexValidationError { invalid }

class Sex extends FormzInput<String, SexValidationError> {
  const Sex.pure() : super.pure('');

  const Sex.dirty([super.value = '']) : super.dirty();

  static final RegExp _sexRegExp = RegExp(
    r'^(Male|Female)$',
  );

  @override
  SexValidationError? validator(String? value) {
    return _sexRegExp.hasMatch(value ?? '') ? null : SexValidationError.invalid;
  }
}
