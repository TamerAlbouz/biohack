import 'package:flutter/material.dart';
import 'package:formz_inputs/formz_inputs.dart';

import '../../../common/widgets/custom_input_field.dart';

class SignUpEmailInput extends StatelessWidget {
  const SignUpEmailInput({
    super.key,
    required this.onChanged,
    this.displayError,
  });

  final void Function(String) onChanged;
  final EmailValidationError? displayError;

  @override
  Widget build(BuildContext context) {
    return InputField(
      key: const Key('loginForm_signUpEmailInput_textField'),
      hintText: "Email",
      onChanged: onChanged,
      keyboardType: TextInputType.emailAddress,
      errorText: displayError != null ? "Invalid Email" : null,
    );
  }
}
