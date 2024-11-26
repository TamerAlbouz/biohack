import 'package:flutter/material.dart';
import 'package:formz_inputs/formz_inputs.dart';
import 'package:medtalk/common/widgets/custom_password_field.dart';

class SignUpPasswordInput extends StatelessWidget {
  const SignUpPasswordInput({
    super.key,
    required this.onChanged,
    this.displayError,
  });

  final void Function(String) onChanged;
  final PasswordValidationError? displayError;

  @override
  Widget build(BuildContext context) {
    return PasswordInputField(
      key: const Key('loginForm_signUpPasswordInput_textField'),
      hintText: "Password",
      onChanged: onChanged,
      keyboardType: TextInputType.visiblePassword,
      errorText: displayError != null
          ? "Invalid Password. Must contain at least:\n"
              "• 8 characters\n"
              "• 1 uppercase letter\n"
              "• 1 lowercase letter\n"
              "• 1 number\n"
              "• 1 special character"
          : null,
    );
  }
}
