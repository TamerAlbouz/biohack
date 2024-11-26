import 'package:flutter/material.dart';

import '../../../styles/colors.dart';
import '../../../styles/font.dart';

class SignInAsGuest extends StatelessWidget {
  const SignInAsGuest({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: const Text(
        'Sign in as a Guest',
        style: TextStyle(
          // underline
          fontFamily: Font.family,
          color: MyColors.blue,
          fontSize: Font.small,
          decoration: TextDecoration.underline,
          decorationColor: MyColors.blue,
          decorationThickness: 1.5,
        ),
      ),
    );
  }
}
