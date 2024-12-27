import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:medtalk/styles/styles/text.dart';

import '../../styles/colors.dart';
import '../../styles/sizes.dart';

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

  /// The hint text to display when no date is selected.
  /// Defaults to 'Select Date'.
  ///
  /// Example:
  /// ```dart
  /// hint: 'Select Date',
  /// ```
  final String hint;

  /// The earliest allowable date that the user can select.
  /// If null, there is no restriction on the earliest date.
  ///
  /// Example:
  /// ```dart
  /// firstDate: DateTime(2000),
  /// ```
  final DateTime firstDate;

  /// The latest allowable date that the user can select.
  /// If null, there is no restriction on the latest date.
  ///
  /// Example:
  /// ```dart
  /// lastDate: DateTime(2022),
  /// ```
  final DateTime lastDate;

  /// Initial date
  ///
  /// Example:
  /// ```dart
  /// initialDate: DateTime.now(),
  /// ```
  final DateTime? initialDate;

  /// A customizable date picker widget that allows users to select a date using a calendar interface.
  ///
  /// The [DatePicker] widget provides a button that opens a date selection dialog,
  /// displaying the selected date in a customizable format once chosen.
  ///
  /// ### Properties:
  ///
  /// * [onSelected]: A callback function that triggers when a date is selected, passing the selected [DateTime].
  /// * [height]: The height of the button. Defaults to 50.
  /// * [hint]: The hint text to display when no date is selected. Defaults to 'Select Date'.
  /// * [firstDate]: The earliest allowable date that the user can select. If null, there is no restriction on the earliest date.
  /// * [lastDate]: The latest allowable date that the user can select. If null, there is no restriction on the latest date.
  ///
  /// ### Example usage:
  /// ```dart
  /// DatePicker(
  ///   onSelected: (date) {
  ///     print('Selected date: $date');
  ///   },
  ///   height: 60,
  ///   hint: 'Select Date',
  ///   firstDate: DateTime(2000),
  ///   lastDate: DateTime(2022),
  /// );
  /// ```
  const DatePicker({
    super.key,
    this.onSelected,
    this.hint = 'Select Date',
    this.height = 50,
    required this.firstDate,
    required this.lastDate,
    this.initialDate,
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
      initialDate: selectedDate ?? widget.lastDate,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      initialEntryMode: DatePickerEntryMode.calendar,
      // initial date to display on text box
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: MyColors.primary,
              onPrimary: MyColors.white,
              onSurface: MyColors.textBlack,
              // on selected change color to white
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: MyColors.primaryLight,
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
    return GestureDetector(
      onTap: () {
        _selectDate(context);
      },
      child: Container(
        height: 50,
        padding: kPaddH15,
        decoration: BoxDecoration(
          borderRadius: kRadius10,
          color: MyColors.textField,
        ),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            if (selectedDate == null)
              const FaIcon(
                FontAwesomeIcons.calendar,
                color: MyColors.primary,
              )
            else
              const FaIcon(
                FontAwesomeIcons.solidCalendar,
                color: MyColors.primary,
              ),
            kGap18,
            Text(
              selectedDate != null
                  ? formatter.format(selectedDate!)
                  : widget.hint,
              textAlign: TextAlign.left,
              style: selectedDate != null
                  ? kButtonHint.copyWith(color: MyColors.textBlack)
                  : kButtonHint,
            ),
          ],
        ),
      ),
    );
  }
}
