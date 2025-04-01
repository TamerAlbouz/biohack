import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:medtalk/styles/colors.dart';
import 'package:medtalk/styles/sizes.dart';

import '../../../styles/font.dart';

class RadioButtonGroup extends StatefulWidget {
  /// A list of strings representing the radio button labels.
  ///
  /// Example:
  /// ```dart
  /// ['Option 1', 'Option 2', 'Option 3']
  /// ```
  final List<String> options;

  /// Callback function that is triggered when an option is selected.
  ///
  /// Example:
  /// ```dart
  /// (selected) {
  ///  print("Selected option: \$selected");
  /// }
  /// ```
  final void Function(bool)? onSelected;

  /// Custom decoration for the radio button group.
  ///
  /// Example:
  /// ```dart
  /// BoxDecoration(
  ///  color: MyColors.white,
  ///  borderRadius: kRadius10,
  ///  border: Border.all(color: MyColors.grey),
  ///  boxShadow: kBoxShadow,
  ///  ),
  ///  ```
  final BoxDecoration? decoration;

  /// Selected color for the radio button.
  ///
  /// Example:
  /// ```dart
  /// MyColors.buttonGreen
  /// ```
  final Color? selectedColor;

  /// Unselected color for the radio button.
  ///
  /// Example:
  /// ```dart
  /// MyColors.textField
  /// ```
  final Color? unselectedColor;

  /// Padding in the radio button.
  ///
  /// Example:
  /// ```dart
  /// EdgeInsets.symmetric(horizontal: 10, vertical: 5)
  /// ```
  final EdgeInsets? contentPadding;

  /// Text color when the button is unselected.
  ///
  /// Example:
  /// ```dart
  /// Colors.grey
  /// ```
  final Color? unselectedTextColor;

  /// Text style for the radio button group.
  ///
  /// Example:
  /// ```dart
  /// TextStyle(
  ///  color: MyColors.black,
  ///  fontSize: Font.small,
  ///  fontWeight: FontWeight.normal,
  ///  )
  /// ```
  final TextStyle? textStyle;

  /// onChanged callback for the radio button group.
  ///
  /// Example:
  /// ```dart
  /// (selected) {
  /// print("Selected option: \$selected");
  /// }
  /// ```
  final void Function(String, int) onChanged;

  final int? selectedIndex;

  final bool? wrap;

  /// A horizontal, scrollable group of radio-style buttons, allowing users to select one option at a time.
  ///
  /// [RadioButtonGroup] displays a list of options horizontally as rounded radio buttons.
  /// It allows selecting a single option at a time and triggers the [onSelected] callback whenever a selection is made.
  ///
  /// Example usage:
  /// ```dart
  /// RadioButtonGroup(
  ///   options: ['Option 1', 'Option 2', 'Option 3'],
  ///   onSelected: (selected) {
  ///     print("Selected option: \$selected");
  ///   },
  ///   decoration: BoxDecoration(
  ///   color: MyColors.white,
  ///   borderRadius: kRadius10,
  ///   border: Border.all(color: MyColors.grey),
  ///   boxShadow: kBoxShadow,
  ///   ),
  /// )
  /// ```
  ///
  /// ### Properties:
  ///
  /// * [options] (required): A list of strings representing the radio button labels.
  /// * [onSelected] (required): Callback function that is triggered when an option is selected.
  /// * [decoration]: Custom decoration for the radio button group.
  /// * [selectedColor]: Selected color for the radio button. Defaults to [MyColors.buttonGreen].
  /// * [unselectedColor]: Unselected color for the radio button. Defaults to [MyColors.textField].
  /// * [contentPadding]: Padding in the radio button.
  /// * [unselectedTextColor]: Text color when the button is unselected.
  /// * [textStyle]: Text style for the radio button group.
  ///
  /// ### State Management:
  ///
  /// The widget maintains the currently selected option in [_selectedOption], which updates
  /// when a new button is selected. The selected button is highlighted, and the selection is passed to [onSelected].
  ///
  /// ### Build Method:
  ///
  /// The widget is wrapped in a [SingleChildScrollView] with horizontal scrolling to handle multiple buttons in a row.
  /// A [Gap] widget is used to add spacing between each radio button for better visual separation.
  /// Each option is rendered using the [RoundedRadioButton] widget.
  const RadioButtonGroup({
    super.key,
    required this.options,
    this.onSelected,
    this.decoration,
    this.selectedColor,
    this.unselectedColor,
    this.contentPadding,
    this.unselectedTextColor,
    this.textStyle,
    this.wrap,
    this.selectedIndex,
    required this.onChanged,
  });

  @override
  State<RadioButtonGroup> createState() => _RadioButtonGroupState();
}

class _RadioButtonGroupState extends State<RadioButtonGroup> {
  String? _selectedOption;

  @override
  void initState() {
    super.initState();
    if (widget.selectedIndex != null) {
      _selectedOption = widget.options[widget.selectedIndex!];
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.wrap == true
        ? Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              for (int i = 0; i < widget.options.length; i++)
                RoundedRadioButton(
                  label: widget.options[i],
                  isSelected: _selectedOption == widget.options[i],
                  decoration: widget.decoration,
                  selectedColor: widget.selectedColor,
                  unselectedColor: widget.unselectedColor,
                  contentPadding: widget.contentPadding,
                  unselectedTextColor: widget.unselectedTextColor,
                  textStyle: widget.textStyle,
                  onSelected: () {
                    if (widget.onSelected != null) {
                      if (_selectedOption == widget.options[i]) {
                        setState(() {
                          _selectedOption = null;
                        });
                        widget.onSelected!(false);
                        return;
                      }
                    }

                    // check values are different
                    if (widget.onSelected != null && _selectedOption == null) {
                      setState(() {
                        _selectedOption = widget.options[i];
                      });
                      widget.onSelected!(true);
                    }

                    // check if onChanged is not null, if so, call it
                    setState(() {
                      _selectedOption = widget.options[i];
                    });
                    widget.onChanged(widget.options[i], i);
                  },
                ),
            ],
          )
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < widget.options.length; i++) ...[
                  if (i > 0) const Gap(8),
                  RoundedRadioButton(
                    label: widget.options[i],
                    isSelected: _selectedOption == widget.options[i],
                    decoration: widget.decoration,
                    selectedColor: widget.selectedColor,
                    unselectedColor: widget.unselectedColor,
                    contentPadding: widget.contentPadding,
                    unselectedTextColor: widget.unselectedTextColor,
                    textStyle: widget.textStyle,
                    onSelected: () {
                      if (widget.onSelected != null) {
                        if (_selectedOption == widget.options[i]) {
                          setState(() {
                            _selectedOption = null;
                          });
                          widget.onSelected!(false);
                          return;
                        }
                      }

                      // check values are different
                      if (widget.onSelected != null &&
                          _selectedOption == null) {
                        setState(() {
                          _selectedOption = widget.options[i];
                        });
                        widget.onSelected!(true);
                      }

                      // check if onChanged is not null, if so, call it
                      setState(() {
                        _selectedOption = widget.options[i];
                      });
                      widget.onChanged(widget.options[i], i);
                    },
                  ),
                ],
              ],
            ),
          );
  }
}

class RoundedRadioButton extends StatelessWidget {
  /// Text label displayed on the radio button.
  ///
  /// Example:
  /// ```dart
  /// 'Option 1'
  /// ```
  final String label;

  /// Boolean flag indicating whether the button is currently selected.
  ///
  /// Example:
  /// ```dart
  /// true
  /// ```
  final bool isSelected;

  /// Callback function triggered when the button is tapped.
  ///
  /// Example:
  /// ```dart
  /// () {
  ///  print("Option 1 selected");
  /// }
  /// ```
  final VoidCallback onSelected;

  /// Color of the button when selected. Defaults to [MyColors.buttonGreen].
  ///
  /// Example:
  /// ```dart
  /// MyColors.buttonGreen
  /// ```
  final Color? selectedColor;

  /// Color of the button when unselected. Defaults to [MyColors.textField].
  ///
  /// Example:
  /// ```dart
  /// MyColors.textFieldBlack
  /// ```
  final Color? unselectedColor;

  /// Text color when the button is selected. Defaults to [Colors.white].
  ///
  /// Example:
  /// ```dart
  /// Colors.white
  /// ```
  final Color? selectedTextColor;

  /// Text style for the radio button group.
  ///
  /// Example:
  /// ```dart
  /// TextStyle(
  /// color: MyColors.black,
  /// fontSize: Font.small,
  /// fontWeight: FontWeight.normal,
  /// )
  /// ```
  final TextStyle? textStyle;

  /// Custom decoration for the radio button.
  ///
  /// Example:
  /// ```dart
  /// BoxDecoration(
  /// color: MyColors.white,
  /// borderRadius: kRadius10,
  /// border: Border.all(color: MyColors.grey),
  /// boxShadow: kBoxShadow,
  /// ),
  /// ```
  final BoxDecoration? decoration;

  /// Padding in the radio button.
  ///
  /// Example:
  /// ```dart
  /// EdgeInsets.symmetric(horizontal: 10, vertical: 5)
  /// ```
  final EdgeInsets? contentPadding;

  /// Text color when the button is unselected.
  ///
  /// Example:
  /// ```dart
  /// Colors.grey
  /// ```
  final Color? unselectedTextColor;

  /// A customizable, rounded radio-style button with selectable states.
  ///
  /// [RoundedRadioButton] displays a label within a rounded container, changing color
  /// based on whether it is selected. It responds to taps and triggers the [onSelected] callback when clicked.
  ///
  /// Example usage within [RadioButtonGroup]:
  /// ```dart
  /// RoundedRadioButton(
  ///   label: 'Option 1',
  ///   isSelected: true,
  ///   onSelected: () {
  ///     print("Option 1 selected");
  ///   },
  ///   selectedColor: MyColors.buttonGreen,
  ///   unselectedColor: MyColors.textField,
  ///   textColor: Colors.white,
  ///   decoration: BoxDecoration(
  ///   color: MyColors.white,
  ///   borderRadius: kRadius10,
  ///   border: Border.all(color: MyColors.grey),
  ///   boxShadow: kBoxShadow,
  ///   ),
  ///   contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  /// )
  /// ```
  ///
  /// ### Properties:
  ///
  /// * [label] (required): Text label displayed on the radio button.
  /// * [isSelected] (required): Boolean flag indicating whether the button is currently selected.
  /// * [onSelected] (required): Callback function triggered when the button is tapped.
  /// * [selectedColor]: Color of the button when selected. Defaults to [MyColors.buttonGreen].
  /// * [unselectedColor]: Color of the button when unselected. Defaults to [MyColors.textField].
  /// * [textColor]: Text color when the button is selected. Defaults to [Colors.white].
  /// * [decoration]: Custom decoration for the radio button.
  /// * [contentPadding]: Padding in the radio button.
  /// * [unselectedTextColor]: Text color when the button is unselected.
  /// * [textStyle]: Text style for the radio button group.
  ///
  /// ### Build Method:
  ///
  /// The button uses a [Container] with padding and a rounded [BoxDecoration] background.
  /// The [label] text color and background color depend on the [isSelected] property.
  /// Tapping the button triggers the [onSelected] callback.
  const RoundedRadioButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
    this.selectedColor,
    this.unselectedColor,
    this.unselectedTextColor,
    this.selectedTextColor = Colors.white,
    this.decoration,
    this.contentPadding,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        alignment: Alignment.center,
        padding: contentPadding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: decoration?.copyWith(
              color: isSelected
                  ? selectedColor ?? MyColors.buttonGreen
                  : unselectedColor,
            ) ??
            BoxDecoration(
              color: isSelected
                  ? selectedColor ?? MyColors.textField
                  : unselectedColor,
              borderRadius: kRadius10,
            ),
        child: Text(
          label,
          style: textStyle?.copyWith(
                color: isSelected
                    ? selectedTextColor
                    : unselectedTextColor ?? MyColors.grey,
              ) ??
              TextStyle(
                color: isSelected
                    ? selectedTextColor
                    : unselectedTextColor ?? MyColors.grey,
                fontWeight: FontWeight.normal,
                fontSize: Font.small,
              ),
        ),
      ),
    );
  }
}
