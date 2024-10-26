import 'package:flutter/material.dart';
import 'package:formz_inputs/formz_inputs.dart';

import '../../common/widgets/custom_input_field.dart';

class SignInEmailInput extends StatelessWidget {
  const SignInEmailInput({
    super.key,
    required this.onChanged,
    this.displayError,
    this.emptyInput = false,
  });

  final void Function(String) onChanged;
  final EmailValidationError? displayError;
  final bool emptyInput;

  @override
  Widget build(BuildContext context) {
    return InputField(
      key: const Key('loginForm_signInEmailInput_textField'),
      hintText: "Email",
      onChanged: onChanged,
      keyboardType: TextInputType.emailAddress,
      errorText: displayError != null && !emptyInput ? "Invalid Email" : null,
    );
  }
}
