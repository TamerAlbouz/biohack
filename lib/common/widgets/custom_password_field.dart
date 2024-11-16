import 'package:flutter/material.dart';

import '../../styles/colors.dart';
import '../../styles/sizes.dart';
import '../../styles/styles/text.dart';

class PasswordInputField extends StatefulWidget {
  final String hintText;
  final Function(String) onChanged;
  final TextInputType keyboardType;
  final String? errorText;

  const PasswordInputField({
    super.key,
    required this.hintText,
    required this.onChanged,
    required this.keyboardType,
    required this.errorText,
  });

  @override
  State<PasswordInputField> createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  // show or hide password
  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: kRadius10,
            color: MyColors.textField,
          ),
          padding: kPaddL24R12T2,
          height: 50,
          child: TextField(
            key: widget.key,
            obscureText: _obscureText,
            onChanged: widget.onChanged,
            keyboardType: widget.keyboardType,
            cursorColor: MyColors.lightBlue,
            style: const TextStyle(
              color: MyColors.textBlack,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              // remove underline
              border: InputBorder.none,
              hintText: widget.hintText,
              hintStyle: kButtonHint,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                  size: 22,
                  color: MyColors.grey,
                ),
                onPressed: _togglePasswordVisibility,
              ),
            ),
          ),
        ),
        kGap5,
        if (widget.errorText != null)
          Text(
            widget.errorText ?? '',
            style: kErrorText,
          ),
      ],
    );
  }
}
