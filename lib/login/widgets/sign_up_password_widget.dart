import 'package:flutter/material.dart';
import 'package:formz_inputs/formz_inputs.dart';
import 'package:medtalk/common/widgets/custom_password_field.dart';

class SignUpPasswordInput extends StatelessWidget {
  const SignUpPasswordInput({
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
      key: const Key('loginForm_signUpPasswordInput_textField'),
      hintText: "Password",
      onChanged: onChanged,
      keyboardType: TextInputType.visiblePassword,
      errorText:
          displayError != null && !emptyInput ? "Invalid Password" : null,
    );
  }
}
