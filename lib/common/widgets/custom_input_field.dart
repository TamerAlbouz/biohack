import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../styles/colors.dart';
import '../../styles/font.dart';
import '../../styles/sizes.dart';
import '../../styles/styles/text.dart';

class CustomInputField extends StatefulWidget {
  final String hintText;
  final Function(String) onChanged;
  final TextInputType keyboardType;
  final String? errorText;
  final int height;
  final Widget? trailingWidget;
  final Widget? leadingWidget;
  final BorderRadius? borderRadius;
  final TextEditingController? controller;
  final EdgeInsets innerPadding;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final int? maxLength;
  final int maxLines; // Added maxLines property
  final bool showPasswordToggle;
  final TextCapitalization textCapitalization;

  const CustomInputField({
    super.key,
    required this.hintText,
    required this.onChanged,
    required this.keyboardType,
    this.errorText,
    this.height = 50,
    this.trailingWidget,
    this.leadingWidget,
    this.borderRadius,
    this.controller,
    this.innerPadding = kPaddH15,
    this.inputFormatters,
    this.obscureText = false,
    this.maxLength,
    this.maxLines = 1, // Default value set to 1
    this.showPasswordToggle = false,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    // Determine the trailing widget based on password toggle
    Widget? effectiveTrailingWidget = widget.trailingWidget;
    if (widget.showPasswordToggle && widget.obscureText) {
      effectiveTrailingWidget = IconButton(
        icon: Icon(
          _isObscured ? Icons.visibility : Icons.visibility_off,
          color: MyColors.grey,
        ),
        onPressed: () {
          setState(() {
            _isObscured = !_isObscured;
          });
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? kRadius10,
            color: MyColors.textField,
          ),
          // make padding dependent on the max lines. make a formula for this
          padding: widget.maxLines == 1
              ? widget.innerPadding
              : const EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
          alignment: Alignment.topLeft,
          height: widget.height.toDouble() * widget.maxLines,
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  textCapitalization: widget.textCapitalization,
                  controller: widget.controller,
                  onChanged: widget.onChanged,
                  keyboardType: widget.keyboardType,
                  obscureText: _isObscured,
                  maxLength: widget.maxLength,
                  maxLines: widget.maxLines,
                  // Pass maxLines to TextFormField
                  inputFormatters: widget.inputFormatters,
                  cursorColor: MyColors.primaryLight,
                  style: const TextStyle(
                    color: MyColors.textBlack,
                    fontSize: Font.small,
                  ),
                  decoration: InputDecoration(
                    // remove underline
                    border: InputBorder.none,
                    counterText: '',
                    // Hide max length counter
                    hintText: widget.hintText,
                    icon: widget.leadingWidget,
                    hintStyle: kButtonHint,
                  ),
                ),
              ),
              if (effectiveTrailingWidget != null) effectiveTrailingWidget,
            ],
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

// Utility class for input validation
class InputValidator {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain an uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain a lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain a number';
    }
    return null;
  }

  // Full name validation
  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    // Ensure at least two words (first and last name)
    final parts = value.trim().split(' ');
    if (parts.length < 2) {
      return 'Please enter your full name';
    }
    return null;
  }

  // Height validation (in cm)
  static String? validateHeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Height is required';
    }
    final height = double.tryParse(value);
    if (height == null || height < 50 || height > 250) {
      return 'Enter a valid height (50-250 cm)';
    }
    return null;
  }

  // Weight validation (in kg)
  static String? validateWeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Weight is required';
    }
    final weight = double.tryParse(value);
    if (weight == null || weight < 20 || weight > 300) {
      return 'Enter a valid weight (20-300 kg)';
    }
    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(
      String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != originalPassword) {
      return 'Passwords do not match';
    }
    return null;
  }
}

// Example of how to use input formatters for specific input types
class InputFormatters {
  // Only allow numbers
  static final numbersOnly = [FilteringTextInputFormatter.digitsOnly];

  // Allow numbers and one decimal point
  static final decimalNumbers = [
    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
  ];

  // Capitalize first letter of each word
  static TextInputFormatter capitalize() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      return TextEditingValue(
        text: newValue.text
            .split(' ')
            .map((word) => word.isNotEmpty
                ? word[0].toUpperCase() + word.substring(1)
                : '')
            .join(' '),
        selection: newValue.selection,
      );
    });
  }
}
