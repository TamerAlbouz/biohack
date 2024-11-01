import 'package:flutter/material.dart';

import '../../../styles/colors.dart';
import '../../../styles/styles/button.dart';

class SuccessButton extends StatelessWidget {
  const SuccessButton({super.key});

  @override
  Widget build(BuildContext context) {
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
