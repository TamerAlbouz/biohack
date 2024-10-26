import 'package:flutter/material.dart';
import 'package:formz_inputs/formz_inputs.dart';

import '../../common/widgets/custom_password_field.dart';

class SignInPasswordInput extends StatelessWidget {
  const SignInPasswordInput({
    super.key,
    required this.onChanged,
    this.displayError,
    this.emptyInput = false,
  });

  final void Function(String) onChanged;
  final PasswordValidationError? displayError;
  final bool emptyInput;

  @override
  Widget build(BuildContext context) {
    return PasswordInputField(
      key: const Key('loginForm_signInPasswordInput_textField'),
      hintText: "Password",
      onChanged: onChanged,
      keyboardType: TextInputType.visiblePassword,
      errorText:
          displayError != null && !emptyInput ? "Invalid Password" : null,
    );
  }
}
