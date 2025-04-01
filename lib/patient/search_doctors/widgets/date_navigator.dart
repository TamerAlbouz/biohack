import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:medtalk/styles/sizes.dart';

import '../../../styles/colors.dart';
import '../../../styles/font.dart';
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
  late DateTime currentDate;
  late PageController _pageController;

  final DateTime firstDate = DateTime.now()
      .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
  final DateTime lastDate = DateTime.now().add(const Duration(days: 364));

  @override
  void initState() {
    super.initState();
    currentDate = (widget.selectedDate ?? DateTime.now()).copyWith(
        hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
    _pageController = PageController(
      initialPage: _calculatePageIndex(currentDate),
      viewportFraction: 0.3,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int _calculatePageIndex(DateTime date) {
    return date.difference(firstDate).inDays;
  }

  DateTime _calculateDateFromPageIndex(int pageIndex) {
    return firstDate.add(Duration(days: pageIndex));
  }

  void _onDateChanged(int index) {
    final newDate = _calculateDateFromPageIndex(index);
    setState(() {
      currentDate = newDate;
      widget.onDateChanged(newDate);
    });
  }

  void _navigateToPreviousDate() {
    if (_pageController.page != null && _pageController.page! > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  void _navigateToNextDate() {
    if (_pageController.page != null &&
        _pageController.page! < _calculatePageIndex(lastDate)) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  bool compareDates(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomIconButton(
          icon: FontAwesomeIcons.arrowLeft,
          disabled: compareDates(currentDate, firstDate),
          onPressed: _navigateToPreviousDate,
        ),
        Expanded(
          child: SizedBox(
            height: 80,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onDateChanged,
              itemBuilder: (context, index) {
                final date = _calculateDateFromPageIndex(index);
                final isSelected = compareDates(date, currentDate);
                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isSelected ? 1.0 : 0.5,
                  child: Padding(
                    padding: kPaddH15,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: kRadius10,
                        border: Border.all(
                          color: isSelected
                              ? MyColors.primary
                              : MyColors.selectionCardStroke,
                          width: 1.5,
                        ),
                      ),
                      width: 80,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            DateFormat('d').format(date),
                            style: isSelected
                                ? kAppointmentSetupCalendarDate.copyWith(
                                    fontSize: Font.mediumLarge,
                                    fontWeight: FontWeight.bold,
                                    color: MyColors.primary,
                                  )
                                : kAppointmentSetupCalendarDate.copyWith(
                                    fontSize: 18,
                                  ),
                          ),
                          Divider(
                            color: isSelected
                                ? MyColors.primary
                                : MyColors.selectionCardStroke,
                            thickness: 1.5,
                            height: 0,
                          ),
                          Text(
                            DateFormat('MMM').format(date),
                            style: isSelected
                                ? kAppointmentSetupCalendarDate.copyWith(
                                    fontSize: Font.medium,
                                    fontWeight: FontWeight.bold,
                                    color: MyColors.primary,
                                  )
                                : kAppointmentSetupCalendarDate,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              itemCount: 365, // Assuming 1 year of dates for simplicity
            ),
          ),
        ),
        CustomIconButton(
          icon: FontAwesomeIcons.arrowRight,
          disabled: compareDates(currentDate, lastDate),
          onPressed: _navigateToNextDate,
        ),
      ],
    );
  }
}
