import 'package:formz/formz.dart';

enum WeightValidationError { invalid }

class Weight extends FormzInput<String, WeightValidationError> {
  const Weight.pure() : super.pure('');

  const Weight.dirty([super.value = '']) : super.dirty();

  static final RegExp _weightRegExp = RegExp(
    r'^(?:[1-9]\d?|[12]\d{2}|300)$',
  );

  @override
  WeightValidationError? validator(String? value) {
    return _weightRegExp.hasMatch(value ?? '')
        ? null
        : WeightValidationError.invalid;
  }
}
