import 'package:flutter/material.dart';
import 'package:formz/formz.dart';
import 'package:medtalk/common/widgets/button/loading_button.dart';
import 'package:medtalk/common/widgets/button/success_button.dart';

import '../../../styles/styles/button.dart';
import '../../../styles/styles/text.dart';

class SignInButton extends StatelessWidget {
  const SignInButton({
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
      // return the button with a green background and a tick icon
      return const SuccessButton();
    }

    return ElevatedButton(
      key: const Key('loginForm_continue_raisedButton'),
      style: kElevatedButtonStyle,
      onPressed: isValid ? onPressed : null,
      child: const Text('Sign In', style: kButtonText),
    );
  }
}
