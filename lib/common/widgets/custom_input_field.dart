import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../styles/colors.dart';
import '../../styles/sizes.dart';
import '../../styles/styles/text.dart';

class InputField extends StatelessWidget {
  final String hintText;
  final Function(String) onChanged;
  final TextInputType keyboardType;
  final String? errorText;
  final int height;

  const InputField({
    super.key,
    required this.hintText,
    required this.onChanged,
    required this.keyboardType,
    required this.errorText,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: kRadius10,
              color: MyColors.textFieldBlack,
            ),
            padding: kPaddH24,
            height: height.toDouble(),
            child: TextField(
              key: key,
              onChanged: onChanged,
              keyboardType: keyboardType,
              cursorColor: MyColors.lightPurple,
              style: const TextStyle(
                color: MyColors.textWhite,
                fontSize: 16,
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
      ),
    );
  }
}
