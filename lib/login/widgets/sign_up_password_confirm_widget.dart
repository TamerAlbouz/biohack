import 'package:flutter/material.dart';

import '../../../common/widgets/custom_password_field.dart';

class SignUpConfirmPasswordInput extends StatelessWidget {
  const SignUpConfirmPasswordInput({
    super.key,
    required this.onChanged,
    this.emptyInput = false,
    this.passwordMatch = true,
  });

  final void Function(String) onChanged;
  final bool emptyInput;
  final bool passwordMatch;

  @override
  Widget build(BuildContext context) {
    return PasswordInputField(
      key: const Key('loginForm_confirmPasswordInput_textField'),
      hintText: "Confirm Password",
      onChanged: onChanged,
      keyboardType: TextInputType.visiblePassword,
      errorText:
          !passwordMatch && !emptyInput ? "Passwords do not match" : null,
    );
  }
}
