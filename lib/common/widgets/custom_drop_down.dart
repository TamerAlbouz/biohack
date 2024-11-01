import 'package:flutter/material.dart';
import 'package:medtalk/styles/sizes.dart';
import 'package:medtalk/styles/styles/text.dart';

import '../../styles/colors.dart';

class CustomDropdown extends StatefulWidget {
  /// A list of strings representing the dropdown items.
  ///
  /// Example:
  /// ```dart
  /// items: ['Item 1', 'Item 2', 'Item 3']
  /// ```
  final List<String> items;

  /// The initial selected value.
  /// If null, the dropdown shows the [hint].
  ///
  /// Example:
  /// ```dart
  /// initialValue: 'Item 1'
  /// ```
  final String? initialValue;

  /// Placeholder text shown when no item is selected.
  /// Defaults to "Select an item".
  ///
  /// Example:
  /// ```dart
  /// hint: 'Select an item'
  /// ```
  final String hint;

  /// Callback function invoked when a new item is selected.
  ///
  /// Example:
  /// ```dart
  /// onChanged: (value) {
  ///  print(value);
  /// }
  /// ```
  final void Function(String?) onChanged;

  /// Width of the dropdown container.
  /// Defaults to the intrinsic width of the content.
  ///
  /// Example:
  /// ```dart
  /// width: 200
  /// ```
  final double? width;

  /// Background color of the dropdown container.
  /// Defaults to the theme's card color.
  ///
  /// Example:
  /// ```dart
  /// backgroundColor: Colors.grey[200]
  /// ```
  final Color? backgroundColor;

  /// Text color of the dropdown items and hint text.
  /// Defaults to the theme's text color.
  ///
  /// Example:
  /// ```dart
  /// textColor: Colors.black
  /// ```
  final Color? textColor;

  /// Background color of the dropdown menu.
  /// Defaults to the theme's dropdown color.
  ///
  /// Example:
  /// ```dart
  /// dropdownColor: Colors.white
  /// ```
  final Color? dropdownColor;

  /// Padding inside the dropdown container.
  /// Defaults to 12 pixels horizontally.
  ///
  /// Example:
  /// ```dart
  /// padding: EdgeInsets.all(8)
  /// ```
  final EdgeInsetsGeometry? padding;

  /// Rounds the corners of the dropdown container.
  /// Defaults to a radius of 8 pixels.
  ///
  /// Example:
  /// ```dart
  /// borderRadius: BorderRadius.circular(10)
  /// ```
  final BorderRadius? borderRadius;

  /// A customizable dropdown widget with support for styling options and an initial value.
  ///
  /// [CustomDropdown] provides a dropdown menu where users can select an item from a list.
  /// The dropdown can be customized with various styling properties, such as colors, padding,
  /// border radius, and more. It also includes a hint text for when no selection is made.
  ///
  /// Example usage:
  /// ```dart
  /// CustomDropdown(
  ///   items: ['Item 1', 'Item 2', 'Item 3'],
  ///   initialValue: 'Item 1',
  ///   onChanged: (value) {
  ///     print(value);
  ///   },
  ///   hint: 'Select an item',
  ///   width: 200,
  ///   backgroundColor: Colors.grey[200],
  ///   textColor: Colors.black,
  ///   dropdownColor: Colors.white,
  ///   padding: EdgeInsets.all(8),
  ///   borderRadius: BorderRadius.circular(10),
  /// )
  /// ```
  ///
  /// ### Properties:
  ///
  /// * [items] (required): A list of strings representing the dropdown items.
  /// * [initialValue]: The initial selected value. If null, the dropdown shows the [hint].
  /// * [hint]: Placeholder text shown when no item is selected. Defaults to "Select an item".
  /// * [onChanged] (required): Callback function invoked when a new item is selected.
  /// * [width]: Width of the dropdown container. Defaults to the intrinsic width of the content.
  /// * [backgroundColor]: Background color of the dropdown container. Defaults to the theme's card color.
  /// * [textColor]: Text color of the dropdown items and hint text. Defaults to the theme's text color.
  /// * [dropdownColor]: Background color of the dropdown menu. Defaults to the theme's dropdown color.
  /// * [padding]: Padding inside the dropdown container. Defaults to 12 pixels horizontally.
  /// * [borderRadius]: Rounds the corners of the dropdown container. Defaults to a radius of 8 pixels.
  ///
  /// ### State Management:
  ///
  /// The widget maintains the currently selected value in [selectedValue] and updates it when
  /// a new selection is made. The initial value can be set through [initialValue], which is stored
  /// in the [selectedValue] state on initialization.
  ///
  /// ### Build Method:
  ///
  /// The widget is built inside a [Container] with customizable width, padding, background color,
  /// and border radius. Inside, a [DropdownButton] is used to display the items, with a custom
  /// icon and no underline by default.
  const CustomDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    this.initialValue,
    this.hint = 'Select an item',
    this.width,
    this.backgroundColor = MyColors.textField,
    this.textColor,
    this.dropdownColor = MyColors.dropdown,
    this.padding,
    this.borderRadius,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      padding: widget.padding ?? kPaddH20,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: widget.borderRadius ?? kRadius10,
      ),
      child: DropdownButton<String>(
        value: selectedValue,
        hint: Text(widget.hint, style: kButtonHint),
        items: widget.items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child:
                Text(item, style: kButtonHint.copyWith(color: MyColors.text)),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            selectedValue = newValue;
          });
          widget.onChanged(newValue);
        },
        isExpanded: true,
        icon: Icon(
          Icons.arrow_drop_down,
          color: widget.textColor ?? Theme.of(context).iconTheme.color,
        ),
        underline: Container(),
        dropdownColor: widget.dropdownColor,
      ),
    );
  }
}
