import 'package:flutter/material.dart';

import '../../../common/widgets/custom_password_field.dart';

class SignUpConfirmPasswordInput extends StatelessWidget {
  const SignUpConfirmPasswordInput({
    super.key,
    required this.onChanged,
    this.emptyInput = false,
    this.isValid = true,
  });

  final void Function(String) onChanged;
  final bool emptyInput;
  final bool isValid;

  @override
  Widget build(BuildContext context) {
    return PasswordInputField(
      key: const Key('loginForm_confirmPasswordInput_textField'),
      hintText: "Confirm Password",
      onChanged: onChanged,
      keyboardType: TextInputType.visiblePassword,
      errorText: !isValid && !emptyInput ? "Passwords do not match" : null,
    );
  }
}
