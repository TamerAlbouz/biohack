import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medtalk/styles/sizes.dart';
import 'package:medtalk/styles/styles/button.dart';

import '../../../styles/colors.dart';
import '../../../styles/font.dart';

class GoogleLoginButton extends StatelessWidget {
  const GoogleLoginButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      key: const Key('loginForm_googleLogin_raisedButton'),
      style: kElevatedButtonStyle.copyWith(
        minimumSize: const WidgetStatePropertyAll(Size(200, 50)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: kRadiusAll,
          ),
        ),
      ),
      onPressed: onPressed,
      icon: const Icon(FontAwesomeIcons.google,
          color: MyColors.buttonText, size: 28),
      label: const Text(
        'Sign in with Google',
        style: TextStyle(
          color: MyColors.buttonText,
          fontSize: Font.medium,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
