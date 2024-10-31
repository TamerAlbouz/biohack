import 'package:formz/formz.dart';

enum BloodGroupValidationError { invalid }

class BloodGroup extends FormzInput<String, BloodGroupValidationError> {
  const BloodGroup.pure() : super.pure('');

  const BloodGroup.dirty([super.value = '']) : super.dirty();

  static final RegExp _bloodGroupRegExp = RegExp(
    r'^(A|B|AB|O)[+-]$',
  );

  @override
  BloodGroupValidationError? validator(String? value) {
    return _bloodGroupRegExp.hasMatch(value ?? '')
        ? null
        : BloodGroupValidationError.invalid;
  }
}
