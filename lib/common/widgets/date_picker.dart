import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../styles/colors.dart';

class DatePicker extends StatefulWidget {
  final void Function(DateTime)? onSelected;

  const DatePicker({
    super.key,
    this.onSelected,
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
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: MyColors.buttonGreen,
              onPrimary: MyColors.textWhite,
              onSurface: MyColors.textWhite,
              // on selected change color to white
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: MyColors.lightPurple,
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ElevatedButton(
          onPressed: () => _selectDate(context),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 8.0),
                Text(
                  selectedDate != null
                      ? formatter.format(selectedDate!)
                      : 'Select Date',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
