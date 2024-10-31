import 'package:formz/formz.dart';

enum FullNameValidationError { invalid }

class FullName extends FormzInput<String, FullNameValidationError> {
  const FullName.pure() : super.pure('');

  const FullName.dirty([super.value = '']) : super.dirty();

  static final RegExp _fullNameRegExp = RegExp(
    r'^[a-zA-Z\s]{3,}$',
  );

  @override
  FullNameValidationError? validator(String? value) {
    return _fullNameRegExp.hasMatch(value ?? '')
        ? null
        : FullNameValidationError.invalid;
  }
}
