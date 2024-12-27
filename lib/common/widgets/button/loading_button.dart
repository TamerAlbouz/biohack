// create a loading button
import 'package:flutter/material.dart';

import '../../../styles/colors.dart';
import '../../../styles/styles/button.dart';

class LoadingButton extends StatelessWidget {
  const LoadingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: null,
      style: kElevatedButtonCommonStyle,
      child: const SizedBox(
        width: 25,
        height: 25,
        child: CircularProgressIndicator(
          color: MyColors.primary,
          semanticsValue: 'Loading',
          semanticsLabel: 'Loading',
          strokeWidth: 3.5,
          strokeCap: StrokeCap.round,
        ),
      ),
    );
  }
}
