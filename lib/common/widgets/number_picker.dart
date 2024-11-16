import 'package:flutter/material.dart';
import 'package:medtalk/styles/sizes.dart';

import '../../styles/colors.dart';
import '../../styles/font.dart';

class NumberPicker extends StatefulWidget {
  /// The minimum value for the picker.
  ///
  /// Example:
  /// ```dart
  /// minValue: 0
  /// ```
  final int minValue;

  /// The maximum value for the picker.
  ///
  /// Example:
  /// ```dart
  /// maxValue: 100
  /// ```
  final int maxValue;

  /// The initial starting value of the picker. Defaults to [minValue] if not provided.
  ///
  /// Example:
  /// ```dart
  /// initialValue: 10
  /// ```
  final int? initialValue;

  /// The amount to increment or decrement on each button press. Defaults to 1.
  ///
  /// Example:
  /// ```dart
  /// step: 5
  /// ```
  final int step;

  /// A callback function to handle the selection of a new value.
  ///
  /// Example:
  /// ```dart
  /// onSelected: (value) {
  ///  print('Selected value: $value');
  /// }
  /// ```
  final void Function(int)? onSelected;

  /// Optional label to display next to the number picker.
  ///
  /// Example:
  /// ```dart
  /// label: 'Weight'
  /// ```
  final String? label;

  /// Optional unit suffix to display alongside the current value (e.g., "kg", "cm").
  ///
  /// Example:
  /// ```dart
  /// unit: 'kg'
  /// ```
  final String? unit;

  /// Fixed width for the number display section; useful to prevent layout changes as numbers change.
  ///
  /// Example:
  /// ```dart
  /// fixedWidth: 60
  /// ```
  final double? fixedWidth;

  /// A customizable number picker widget that allows incrementing or decrementing within a defined range.
  ///
  /// The [NumberPicker] displays a numeric value within a specified range, controlled with plus and minus buttons.
  /// It allows customization of the range, step size, optional label, unit suffix, and more.
  ///
  /// ### Properties:
  ///
  /// * [minValue] (required): The minimum value for the picker.
  /// * [maxValue] (required): The maximum value for the picker.
  /// * [initialValue]: The initial starting value of the picker. Defaults to [minValue] if not provided.
  /// * [step]: The amount to increment or decrement on each button press. Defaults to 1.
  /// * [onSelected]: A callback function to handle the selection of a new value.
  /// * [label]: Optional label to display next to the number picker.
  /// * [unit]: Optional unit suffix to display alongside the current value (e.g., "kg", "cm").
  /// * [fixedWidth]: Fixed width for the number display section; useful to prevent layout changes as numbers change.
  ///
  /// ### Example usage:
  /// ```dart
  /// NumberPicker(
  ///   minValue: 0,
  ///   maxValue: 100,
  ///   initialValue: 10,
  ///   step: 5,
  ///   onSelected: (value) {
  ///     print('Selected value: $value');
  ///   },
  ///   label: 'Weight',
  ///   unit: 'kg',
  ///   fixedWidth: 60,
  /// );
  /// ```
  ///
  /// ### Assertions:
  /// * [minValue] should be less than [maxValue].
  /// * [step] must be a positive integer.
  /// * [initialValue] (if provided) must be within the range of [minValue] and [maxValue].
  /// * [fixedWidth] (if provided) must be non-negative.
  ///
  /// ### Build Method:
  ///
  /// The widget builds a horizontal row containing:
  /// - An optional label on the left, if [label] is specified.
  /// - A centered container with minus and plus buttons to adjust the numeric value, which is shown between the buttons.
  /// - [unit] is displayed next to the number, if provided.
  ///
  /// The picker value is updated and limited within the specified range using the provided [minValue] and [maxValue].
  const NumberPicker({
    super.key,
    required this.minValue,
    required this.maxValue,
    this.initialValue,
    this.step = 1,
    this.onSelected,
    this.label,
    this.unit,
    this.fixedWidth,
  })  : assert(minValue < maxValue, 'minValue must be less than maxValue'),
        assert(step > 0, 'step must be a positive number'),
        assert(
            initialValue == null ||
                (minValue <= initialValue && initialValue <= maxValue),
            'initialValue must be between minValue and maxValue'),
        assert(fixedWidth == null || fixedWidth >= 0,
            'fixedWidth must be a positive number or null');

  @override
  State<NumberPicker> createState() => _NumberPickerState();
}

class _NumberPickerState extends State<NumberPicker> {
  late int _currentValue;

  @override
  void initState() {
    super.initState();
    // Set initial value, defaulting to the minimum if not provided
    _currentValue = widget.initialValue ?? widget.minValue;
  }

  void _incrementValue() {
    setState(() {
      _currentValue = (_currentValue + widget.step > widget.maxValue)
          ? widget.maxValue
          : _currentValue + widget.step;
      widget.onSelected?.call(_currentValue);
    });
  }

  void _decrementValue() {
    setState(() {
      _currentValue = (_currentValue - widget.step < widget.minValue)
          ? widget.minValue
          : _currentValue - widget.step;
      widget.onSelected?.call(_currentValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (widget.label != null)
          Text(
            widget.label!,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontSize: Font.mediumSmall,
                  fontWeight: FontWeight.normal,
                ),
          ),
        Container(
          // if width is too small, the text will overflow, so we set a minimum width
          decoration: BoxDecoration(
            color: MyColors.textField,
            border: Border.all(color: MyColors.lightBlue, width: 2),
            borderRadius: kRadius10,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                color: MyColors.lightBlue,
                onPressed:
                    _currentValue > widget.minValue ? _decrementValue : null,
              ),
              SizedBox(
                width: widget.fixedWidth,
                child: Text(
                  '$_currentValue${widget.unit == null ? '' : ' ${widget.unit}'}',
                  style: Theme.of(context).textTheme.labelSmall,
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                color: MyColors.lightBlue,
                onPressed:
                    _currentValue < widget.maxValue ? _incrementValue : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
