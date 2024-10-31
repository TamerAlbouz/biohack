import 'package:flutter/material.dart';
import 'package:formz/formz.dart';

import '../../styles/colors.dart';
import '../../styles/styles/button.dart';
import '../../styles/styles/text.dart';

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
    if (status.isInProgress) return const CircularProgressIndicator();

    if (status.isSuccess) {
      // return the button with a green background and a tick icon
      return ElevatedButton.icon(
        key: const Key('loginForm_continue_raisedButton'),
        style: kMainButtonStyle.copyWith(
          backgroundColor: const WidgetStatePropertyAll(MyColors.buttonGreen),
        ),
        onPressed: null,
        icon: const Icon(Icons.check, color: Colors.white),
        label: const Text(''),
      );
    }

    return ElevatedButton(
      key: const Key('loginForm_continue_raisedButton'),
      style: kMainButtonStyle,
      onPressed: isValid ? onPressed : null,
      child: const Text('Sign In', style: kButtonText),
    );
  }
}
