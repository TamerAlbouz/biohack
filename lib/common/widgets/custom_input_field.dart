import 'package:flutter/material.dart';

import '../../styles/colors.dart';
import '../../styles/sizes.dart';
import '../../styles/styles/text.dart';

class InputField extends StatelessWidget {
  final String hintText;
  final Function(String) onChanged;
  final TextInputType keyboardType;
  final String? errorText;

  const InputField({
    super.key,
    required this.hintText,
    required this.onChanged,
    required this.keyboardType,
    required this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: kRadius10,
            color: MyColors.textFieldBlack,
          ),
          padding: kPaddH24,
          height: 50,
          child: TextField(
            key: key,
            onChanged: onChanged,
            keyboardType: keyboardType,
            cursorColor: MyColors.buttonTextPurple,
            style: const TextStyle(
              color: MyColors.textWhite,
            ),
            decoration: InputDecoration(
              // remove underline
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: kButtonHint,
            ),
          ),
        ),
        kGap5,
        if (errorText != null)
          Text(
            errorText ?? '',
            style: kErrorText,
          ),
      ],
    );
  }
}
