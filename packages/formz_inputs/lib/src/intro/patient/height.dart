import 'package:formz/formz.dart';

enum HeightValidationError { invalid }

class Height extends FormzInput<double, HeightValidationError> {
  const Height.pure() : super.pure(0);

  const Height.dirty([super.value = 0]) : super.dirty();

  static final RegExp _heightRegExp = RegExp(
    r'^(?:1[0-9][0-9]|[1-9]?[0-9]|200)$',
  );

  @override
  HeightValidationError? validator(double? value) {
    return _heightRegExp.hasMatch(value.toString())
        ? null
        : HeightValidationError.invalid;
  }
}
