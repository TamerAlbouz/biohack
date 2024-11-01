import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medtalk/styles/styles/text.dart';

import '../../styles/colors.dart';
import '../../styles/styles/text_field.dart';

class DatePicker extends StatefulWidget {
  /// A callback function that triggers when a date is selected, passing the selected [DateTime].
  ///
  /// Example:
  /// ```dart
  /// onSelected: (date) {
  ///  print('Selected date: $date');
  /// },
  /// ```
  final void Function(DateTime)? onSelected;

  /// The height of the button. Defaults to 50.
  ///
  /// Example:
  /// ```dart
  /// height: 60,
  /// ```
  final int height;

  /// A customizable date picker widget that allows users to select a date using a calendar interface.
  ///
  /// The [DatePicker] widget provides a button that opens a date selection dialog,
  /// displaying the selected date in a customizable format once chosen.
  ///
  /// ### Properties:
  ///
  /// * [onSelected]: A callback function that triggers when a date is selected, passing the selected [DateTime].
  /// * [height]: The height of the button. Defaults to 50.
  ///
  /// ### Example usage:
  /// ```dart
  /// DatePicker(
  ///   onSelected: (date) {
  ///     print('Selected date: $date');
  ///   },
  ///   height: 60,
  /// );
  /// ```
  ///
  /// ### Features:
  /// - Opens a calendar dialog with a dark theme and custom colors for date selection.
  /// - Uses [DateFormat] to format the date in `dd/MM/yyyy` format.
  /// - Displays 'Select Date' text initially, which updates to the selected date.
  ///
  /// ### Build Method:
  ///
  /// The widget builds an [ElevatedButton] that opens the date picker dialog upon pressing.
  /// Inside the button, the chosen date (or a placeholder text) and a calendar icon are displayed.
  ///
  /// - The date picker dialog is themed with a dark color scheme and custom button colors.
  /// - After a date is selected, it updates the displayed date and triggers the [onSelected] callback.
  const DatePicker({
    super.key,
    this.onSelected,
    this.height = 50,
  });

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  DateTime? selectedDate;
  final DateFormat formatter = DateFormat('dd/MM/yyyy');

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime(DateTime.now().year - 18),
      firstDate: DateTime(1900),
      lastDate: DateTime(DateTime.now().year - 18),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: MyColors.buttonGreen,
              onPrimary: MyColors.text,
              onSurface: MyColors.text,
              // on selected change color to white
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: MyColors.lightPurple,
                textStyle: kButtonHint,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      widget.onSelected?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _selectDate(context),
      style: kTextFieldButtonStyle,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            selectedDate != null
                ? formatter.format(selectedDate!)
                : 'Select Date',
            textAlign: TextAlign.left,
            style: selectedDate != null
                ? kButtonHint.copyWith(color: MyColors.text)
                : kButtonHint,
          ),
          const Icon(Icons.calendar_today),
        ],
      ),
    );
  }
}
