import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:medtalk/styles/colors.dart';
import 'package:medtalk/styles/sizes.dart';

import '../../styles/font.dart';

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
  ///  print("Selected option: $selected");
  /// }
  /// ```
  final void Function(String) onChanged;

  /// A horizontal, scrollable group of radio-style buttons, allowing users to select one option at a time.
  ///
  /// [RadioButtonGroup] displays a list of options horizontally as rounded radio buttons.
  /// It allows selecting a single option at a time and triggers the [onChanged] callback whenever a selection is made.
  ///
  /// Example usage:
  /// ```dart
  /// RadioButtonGroup(
  ///   options: ['Option 1', 'Option 2', 'Option 3'],
  ///   onChanged: (selected) {
  ///     print("Selected option: $selected");
  ///   },
  /// )
  /// ```
  ///
  /// ### Properties:
  ///
  /// * [options] (required): A list of strings representing the radio button labels.
  /// * [onChanged] (required): Callback function that is triggered when an option is selected.
  ///
  /// ### State Management:
  ///
  /// The widget maintains the currently selected option in [_selectedOption], which updates
  /// when a new button is selected. The selected button is highlighted, and the selection is passed to [onChanged].
  ///
  /// ### Build Method:
  ///
  /// The widget is wrapped in a [SingleChildScrollView] with horizontal scrolling to handle multiple buttons in a row.
  /// A [Gap] widget is used to add spacing between each radio button for better visual separation.
  /// Each option is rendered using the [RoundedRadioButton] widget.
  const RadioButtonGroup({
    super.key,
    required this.options,
    required this.onChanged,
  });

  @override
  State<RadioButtonGroup> createState() => _RadioButtonGroupState();
}

class _RadioButtonGroupState extends State<RadioButtonGroup> {
  String? _selectedOption;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < widget.options.length; i++) ...[
            if (i > 0) const Gap(8),
            RoundedRadioButton(
              label: widget.options[i],
              isSelected: _selectedOption == widget.options[i],
              onSelected: () {
                setState(() {
                  _selectedOption = widget.options[i];
                });
                widget.onChanged(widget.options[i]);
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
  final Color selectedColor;

  /// Color of the button when unselected. Defaults to [MyColors.textField].
  ///
  /// Example:
  /// ```dart
  /// MyColors.textFieldBlack
  /// ```
  final Color unselectedColor;

  /// Text color when the button is selected. Defaults to [Colors.white].
  ///
  /// Example:
  /// ```dart
  /// Colors.white
  /// ```
  final Color textColor;

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
    this.selectedColor = MyColors.buttonGreen,
    this.unselectedColor = MyColors.textField,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : unselectedColor,
          borderRadius: kRadius10,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? textColor : MyColors.grey,
            fontWeight: FontWeight.normal,
            fontSize: Font.small,
          ),
        ),
      ),
    );
  }
}
