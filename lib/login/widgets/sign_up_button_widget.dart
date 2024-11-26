import 'package:flutter/material.dart';
import 'package:formz/formz.dart';
import 'package:medtalk/common/widgets/button/success_button.dart';

import '../../../common/widgets/button/loading_button.dart';
import '../../../styles/styles/button.dart';
import '../../../styles/styles/text.dart';

class SignUpButton extends StatelessWidget {
  const SignUpButton({
    super.key,
    required this.onPressed,
    required this.status,
    required this.isValid,
  });

  final VoidCallback onPressed;
  final FormzSubmissionStatus status;
  final bool isValid;

  @override
  Widget build(BuildContext context) {
    if (status.isInProgress) return const LoadingButton();

    if (status.isSuccess) {
      return const SuccessButton();
    }

    return ElevatedButton(
      key: const Key('signUpForm_continue_raisedButton'),
      style: kElevatedButtonStyle,
      onPressed: isValid ? onPressed : null,
      child: const Text('Sign Up', style: kButtonText),
    );
  }
}
