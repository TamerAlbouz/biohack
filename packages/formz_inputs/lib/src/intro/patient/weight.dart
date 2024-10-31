import 'package:formz/formz.dart';

enum WeightValidationError { invalid }

class Weight extends FormzInput<double, WeightValidationError> {
  const Weight.pure() : super.pure(0);

  const Weight.dirty([super.value = 0]) : super.dirty();

  static final RegExp _weightRegExp = RegExp(
    r'^[0-9]+(\.[0-9]+)?$',
  );

  @override
  WeightValidationError? validator(double? value) {
    return _weightRegExp.hasMatch(value.toString())
        ? null
        : WeightValidationError.invalid;
  }
}
