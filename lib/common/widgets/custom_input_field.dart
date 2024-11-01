import 'package:flutter/material.dart';

import '../../styles/colors.dart';
import '../../styles/font.dart';
import '../../styles/sizes.dart';
import '../../styles/styles/text.dart';

class InputField extends StatelessWidget {
  /// The placeholder text shown when the input is empty.
  ///
  /// Example:
  /// ```dart
  /// hintText: 'Enter your email',
  /// ```
  final String hintText;

  /// Callback function invoked when the input value changes.
  ///
  /// Example:
  /// ```dart
  /// onChanged: (value) {
  ///  print('Input changed: $value');
  /// },
  /// ```
  final Function(String) onChanged;

  /// Specifies the type of keyboard to use for text input.
  ///
  /// Example:
  /// ```dart
  /// keyboardType: TextInputType.emailAddress,
  /// ```
  final TextInputType keyboardType;

  /// Optional error message displayed below the input field.
  ///
  /// Example:
  /// ```dart
  /// errorText: 'Invalid email format',
  /// ```
  final String? errorText;

  /// Height of the input field container, in pixels. Defaults to 50.
  ///
  /// Example:
  /// ```dart
  /// height: 50,
  /// ```
  final int height;

  /// An optional widget displayed at the end of the input field.
  ///
  /// Example:
  /// ```dart
  /// trailingWidget: Icon(Icons.email),
  /// ```
  final Widget? trailingWidget;

  /// A custom input field with styling options, error message display, and an optional trailing widget.
  ///
  /// [InputField] provides a styled text input field with a hint, customizable keyboard type,
  /// error text display, and an optional trailing widget. It is wrapped in a [Column] for layout flexibility,
  /// allowing error messages to be shown beneath the field when provided.
  ///
  /// Example usage:
  /// ```dart
  /// InputField(
  ///   hintText: 'Enter your email',
  ///   onChanged: (value) {
  ///     print('Input changed: $value');
  ///   },
  ///   keyboardType: TextInputType.emailAddress,
  ///   errorText: 'Invalid email format',
  ///   trailingWidget: Icon(Icons.email),
  /// )
  /// ```
  ///
  /// ### Properties:
  ///
  /// * [hintText] (required): The placeholder text shown when the input is empty.
  /// * [onChanged] (required): Callback function invoked when the input value changes.
  /// * [keyboardType] (required): Specifies the type of keyboard to use for text input, e.g., [TextInputType.emailAddress].
  /// * [errorText]: Optional error message displayed below the input field. If null, no error message is shown.
  /// * [height]: Height of the input field container, in pixels. Defaults to 50.
  /// * [trailingWidget]: An optional widget displayed at the end of the input field, typically for additional actions or icons.
  ///
  /// ### Build Method:
  ///
  /// The widget is wrapped in a [Column] for stacked layout with optional error text below the input.
  /// The input field is styled using a [Container] with padding, background color, and a rounded border.
  /// The [TextField] is configured without an underline and uses a custom text style and hint style.
  const InputField({
    super.key,
    required this.hintText,
    required this.onChanged,
    required this.keyboardType,
    required this.errorText,
    this.trailingWidget,
    this.height = 50,
  });

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
          padding: kPaddH20,
          height: height.toDouble(),
          child: TextField(
            key: key,
            onChanged: onChanged,
            keyboardType: keyboardType,
            cursorColor: MyColors.lightPurple,
            style: const TextStyle(
              color: MyColors.text,
              fontSize: Font.small,
            ),
            decoration: InputDecoration(
              // remove underline
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: kButtonHint,
              suffix: trailingWidget,
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
