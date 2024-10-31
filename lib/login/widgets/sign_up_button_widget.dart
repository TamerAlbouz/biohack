import 'package:flutter/material.dart';
import 'package:formz/formz.dart';

import '../../styles/colors.dart';
import '../../styles/styles/button.dart';
import '../../styles/styles/text.dart';

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
    if (status.isInProgress) return const CircularProgressIndicator();

    if (status.isSuccess) {
      if (status.isSuccess) {
        // return the button with a green background and a tick icon
        return ElevatedButton.icon(
          style: kMainButtonStyle.copyWith(
            backgroundColor: const WidgetStatePropertyAll(MyColors.buttonGreen),
          ),
          onPressed: null,
          icon: const Icon(Icons.check, color: Colors.white),
          label: const Text(''),
        );
      }
    }

    return ElevatedButton(
      key: const Key('signUpForm_continue_raisedButton'),
      style: kMainButtonStyle,
      onPressed: isValid ? onPressed : null,
      child: const Text('Sign Up', style: kButtonText),
    );
  }
}
