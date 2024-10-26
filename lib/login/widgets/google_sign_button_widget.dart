import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../styles/colors.dart';
import '../../styles/sizes.dart';

class GoogleLoginButton extends StatelessWidget {
  const GoogleLoginButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      key: const Key('loginForm_googleLogin_raisedButton'),
      style: ElevatedButton.styleFrom(
        padding: kPadd10,
        shape: const CircleBorder(),
        backgroundColor: MyColors.black,
      ),
      onPressed: onPressed,
      child:
          const Icon(FontAwesomeIcons.google, color: MyColors.grey, size: 28),
    );
  }
}
