import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
                backgroundColor: MyColors.green,
                content: Text('Successfully Signed Up!')),
          );
      });
    }

    return ElevatedButton(
      key: const Key('signUpForm_continue_raisedButton'),
      style: kMainButtonStyle,
      onPressed: isValid ? onPressed : null,
      child: const Text('Sign Up', style: kButtonText),
    );
  }
}
