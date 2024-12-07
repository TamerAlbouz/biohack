import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../../styles/colors.dart';
import '../../../styles/sizes.dart';
import '../../../styles/styles/text.dart';
import 'custom_icon_button.dart';

class DateNavigationWidget extends StatefulWidget {
  final ValueChanged<DateTime> onDateChanged;
  final DateTime? selectedDate;

  const DateNavigationWidget({
    super.key,
    required this.onDateChanged,
    this.selectedDate,
  });

  @override
  State<DateNavigationWidget> createState() => _DateNavigationWidgetState();
}

class _DateNavigationWidgetState extends State<DateNavigationWidget> {
  DateTime currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    currentDate = widget.selectedDate ?? DateTime.now();
  }

  void _navigateToPreviousDate() {
    final newDate = currentDate.subtract(const Duration(days: 1));
    setState(() {
      currentDate = newDate;
      widget.onDateChanged(newDate);
    });
  }

  void _navigateToNextDate() {
    final newDate = currentDate.add(const Duration(days: 1));
    setState(() {
      currentDate = newDate;
      widget.onDateChanged(newDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        CustomIconButton(
          icon: FaIcon(
            FontAwesomeIcons.arrowLeft,
            color: currentDate.isBefore(DateTime.now())
                ? MyColors.grey
                : MyColors.blue,
            size: 20,
          ),
          onPressed: _navigateToPreviousDate,
          disabled: currentDate.isBefore(DateTime.now()),
        ),
        Column(
          children: [
            const FaIcon(
              FontAwesomeIcons.calendar,
              color: MyColors.blue,
            ),
            kGap4,
            Text(
              DateFormat('EEEE, MMM d').format(currentDate),
              style: kAppointmentSetupCalendarDate,
            ),
          ],
        ),
        CustomIconButton(
          icon: const FaIcon(
            FontAwesomeIcons.arrowRight,
            color: MyColors.blue,
            size: 20,
          ),
          onPressed: _navigateToNextDate,
        ),
      ],
    );
  }
}
