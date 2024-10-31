import 'package:formz/formz.dart';

enum BiographyValidationError { invalid }

class Biography extends FormzInput<String, BiographyValidationError> {
  const Biography.pure() : super.pure('');

  const Biography.dirty([super.value = '']) : super.dirty();

  static final RegExp _biographyRegExp = RegExp(
    r'^[a-zA-Z0-9\s.,\-]{10,}$',
  );

  @override
  BiographyValidationError? validator(String? value) {
    return _biographyRegExp.hasMatch(value ?? '')
        ? null
        : BiographyValidationError.invalid;
  }
}
