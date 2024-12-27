import 'package:flutter/material.dart';
import 'package:medtalk/styles/sizes.dart';
import 'package:medtalk/styles/styles/text.dart';

import '../../../styles/colors.dart';

class CustomSimpleDropdown extends StatefulWidget {
  /// A list of strings representing the dropdown items.
  final List<String> items;

  /// The initial selected value.
  final String? initialValue;

  /// Placeholder text shown when no item is selected.
  final String hint;

  /// Callback function invoked when a new item is selected.
  final void Function(String?) onChanged;

  /// Width of the dropdown container.
  final double? width;

  /// Background color of the dropdown container.
  final Color? backgroundColor;

  /// Text color of the dropdown items and hint text.
  final Color? textColor;

  /// Background color of the dropdown menu.
  final Color? dropdownColor;

  /// Padding inside the dropdown container.
  final EdgeInsetsGeometry? padding;

  /// Rounds the corners of the dropdown container.
  final BorderRadius? borderRadius;

  /// Icon to display alongside the dropdown
  final IconData? prefixIcon;

  /// Color of the prefix icon
  final Color? prefixIconColor;

  /// Spacing between the icon and the dropdown content
  final double? iconSpacing;

  /// Optional custom leading widget to replace the default prefix icon
  final Widget? customLeadingWidget;

  /// Position of the icon relative to the dropdown text
  final bool iconOnLeft;

  const CustomSimpleDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    this.initialValue,
    this.hint = 'Select an item',
    this.width,
    this.backgroundColor,
    this.textColor,
    this.dropdownColor,
    this.padding,
    this.borderRadius,
    this.prefixIcon,
    this.prefixIconColor,
    this.iconSpacing = 8.0,
    this.customLeadingWidget,
    this.iconOnLeft = true,
  });

  @override
  State<CustomSimpleDropdown> createState() => _CustomSimpleDropdownState();
}

class _CustomSimpleDropdownState extends State<CustomSimpleDropdown> {
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null && widget.initialValue != '') {
      selectedValue = widget.initialValue;
    }
  }

  Widget _buildLeadingWidget() {
    // Prefer custom leading widget if provided
    if (widget.customLeadingWidget != null) {
      return widget.customLeadingWidget!;
    }

    // Build icon if prefixIcon is provided
    if (widget.prefixIcon != null) {
      return Icon(
        widget.prefixIcon,
        color: widget.prefixIconColor ??
            widget.textColor ??
            Theme.of(context).iconTheme.color,
        size: 20.0,
      );
    }

    // Return empty container if no icon or custom widget
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final leadingWidget = _buildLeadingWidget();

    return Container(
      width: widget.width,
      padding: widget.padding ?? kPaddH15,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? MyColors.textField,
        borderRadius: widget.borderRadius ?? kRadius10,
      ),
      child: Row(
        children: [
          // Leading icon/widget on the left side
          if (widget.iconOnLeft &&
              (widget.prefixIcon != null || widget.customLeadingWidget != null))
            SizedBox(
              width: 40.0,
              child: leadingWidget,
            ),

          // Expanded dropdown
          Expanded(
            child: DropdownButton<String>(
              value: selectedValue,
              hint: Text(widget.hint, style: kButtonHint),
              items: widget.items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item,
                      style: kButtonHint.copyWith(color: MyColors.textBlack)),
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
              dropdownColor: widget.dropdownColor ?? MyColors.dropdown,
            ),
          ),

          // Leading icon/widget on the right side
          if (!widget.iconOnLeft &&
              (widget.prefixIcon != null || widget.customLeadingWidget != null))
            Padding(
              padding: EdgeInsets.only(left: widget.iconSpacing!),
              child: leadingWidget,
            ),
        ],
      ),
    );
  }
}
