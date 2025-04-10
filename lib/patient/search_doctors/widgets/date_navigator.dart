import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:medtalk/styles/sizes.dart';

import '../../../styles/colors.dart';
import '../../../styles/font.dart';

class EnhancedDateNavigationWidget extends StatefulWidget {
  final ValueChanged<DateTime> onDateChanged;
  final DateTime? selectedDate;
  final List<bool>? availableDays;
  final Map<DateTime, String>? specialDates;

  /// Booking advance notice in hours - minimum notice required before booking
  /// For example, if set to 24, patients can only book appointments at least 24 hours in the future
  final int bookingAdvanceHours;

  /// Booking window in days - how far in the future appointments can be booked
  /// For example, if set to 30, patients can only book appointments up to 30 days from now
  final int bookingWindowDays;

  const EnhancedDateNavigationWidget({
    super.key,
    required this.onDateChanged,
    this.selectedDate,
    this.availableDays,
    this.specialDates,
    this.bookingAdvanceHours = 0, // Default to no advance notice required
    this.bookingWindowDays = 365, // Default to a year booking window
  });

  @override
  State<EnhancedDateNavigationWidget> createState() =>
      _EnhancedDateNavigationWidgetState();
}

class _EnhancedDateNavigationWidgetState
    extends State<EnhancedDateNavigationWidget>
    with SingleTickerProviderStateMixin {
  late DateTime currentDate;
  late PageController _pageController;
  late TabController _monthTabController;

  final List<String> months = [];
  final Map<int, int> monthToPageIndex = {};

  late DateTime firstDate;
  late DateTime lastDate;

  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();

    // Calculate first allowed date based on booking advance notice
    firstDate = DateTime.now().add(Duration(hours: widget.bookingAdvanceHours));
    firstDate = DateTime(firstDate.year, firstDate.month, firstDate.day);

    // Calculate last allowed date based on booking window
    lastDate = DateTime.now().add(Duration(days: widget.bookingWindowDays));
    lastDate =
        DateTime(lastDate.year, lastDate.month, lastDate.day, 23, 59, 59);

    // Initialize the current date (enforce it's within booking constraints)
    if (widget.selectedDate != null) {
      DateTime tempSelected = widget.selectedDate!;

      // If selected date is before first allowed date, use first date
      if (tempSelected.isBefore(firstDate)) {
        tempSelected = firstDate;
      }

      // If selected date is after last allowed date, use last date
      if (tempSelected.isAfter(lastDate)) {
        tempSelected = lastDate;
      }

      currentDate = tempSelected.copyWith(
          hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
    } else {
      currentDate = firstDate.copyWith(
          hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
    }

    // Set up the page controller
    _pageController = PageController(
      initialPage: _calculatePageIndex(currentDate),
      viewportFraction: 0.2, // Show more dates at once
    );

    // Set up the months for the tab bar
    _setupMonths();

    // Initialize the tab controller
    _monthTabController = TabController(
      length: months.length,
      vsync: this,
      initialIndex: _getMonthIndexForDate(currentDate),
    );

    // Listen to month tab changes
    _monthTabController.addListener(_handleMonthTabChange);
  }

  // Set up the month tabs
  void _setupMonths() {
    DateTime current = firstDate;
    int pageIndex = 0;

    while (current.isBefore(lastDate) || _isSameMonth(current, lastDate)) {
      String monthYear = DateFormat('MMM yyyy').format(current);

      if (!months.contains(monthYear)) {
        months.add(monthYear);
        monthToPageIndex[months.length - 1] = pageIndex;
      }

      // Move to next day
      current = current.add(const Duration(days: 1));
      pageIndex++;
    }
  }

  bool _isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  int _getMonthIndexForDate(DateTime date) {
    String monthYear = DateFormat('MMM yyyy').format(date);
    return months.indexOf(monthYear);
  }

  void _handleMonthTabChange() {
    if (!_isAnimating && _monthTabController.indexIsChanging) {
      _isAnimating = true;

      // Get the page index for the selected month
      int targetPageIndex = monthToPageIndex[_monthTabController.index] ?? 0;

      // Animate to the page
      _pageController
          .animateToPage(
        targetPageIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      )
          .then((_) {
        _isAnimating = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _monthTabController.removeListener(_handleMonthTabChange);
    _monthTabController.dispose();
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

    // Update the month tab if necessary
    int monthIndex = _getMonthIndexForDate(newDate);
    if (_monthTabController.index != monthIndex) {
      _monthTabController.animateTo(monthIndex);
    }

    setState(() {
      currentDate = newDate;
      widget.onDateChanged(newDate);
    });

    // Add haptic feedback for date selection
    HapticFeedback.selectionClick();
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

  void _scrollToToday() {
    // If today is before firstDate (due to advance notice), scroll to firstDate
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    DateTime targetDate;
    if (today.isBefore(firstDate)) {
      targetDate = firstDate;
    } else if (today.isAfter(lastDate)) {
      targetDate = lastDate;
    } else {
      targetDate = today;
    }

    int targetPageIndex = _calculatePageIndex(targetDate);

    _pageController.animateToPage(
      targetPageIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  bool compareDates(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _isDateAvailable(DateTime date) {
    // Check if the date is within booking constraints
    if (date.isBefore(firstDate) || date.isAfter(lastDate)) {
      return false;
    }

    // Check if the weekday is available according to doctor's schedule
    if (widget.availableDays != null) {
      // Get the weekday index (0 = Monday, 6 = Sunday)
      int weekdayIndex = date.weekday - 1;
      return widget.availableDays![weekdayIndex];
    }

    return true;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String? _getSpecialDateInfo(DateTime date) {
    if (widget.specialDates == null) return null;

    for (final specialDate in widget.specialDates!.keys) {
      if (compareDates(specialDate, date)) {
        return widget.specialDates![specialDate];
      }
    }

    return null;
  }

  void _showDateInfoDialog(DateTime date, bool isAvailable) {
    final specialInfo = _getSpecialDateInfo(date);
    final now = DateTime.now();

    String? unavailableReason;
    if (!isAvailable) {
      // Check why it's unavailable
      if (widget.availableDays != null) {
        int weekdayIndex = date.weekday - 1;
        if (!widget.availableDays![weekdayIndex]) {
          unavailableReason =
              'Doctor is not available on ${DateFormat('EEEE').format(date)}s';
        }
      }

      if (date.isBefore(firstDate) && date.isAfter(now)) {
        final difference = firstDate.difference(now).inHours;
        unavailableReason =
            'Doctor requires at least $difference hour${difference != 1 ? 's' : ''} advance notice';
      }

      if (date.isAfter(lastDate)) {
        unavailableReason =
            'Doctor only accepts bookings up to ${widget.bookingWindowDays} days in advance';
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          DateFormat('EEEE, MMMM d, yyyy').format(date),
          style: const TextStyle(
            fontSize: Font.medium,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isAvailable && unavailableReason != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FaIcon(
                    FontAwesomeIcons.ban,
                    color: Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      unavailableReason,
                      style: const TextStyle(
                        fontSize: Font.small,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            if (specialInfo != null) ...[
              Row(
                children: [
                  const FaIcon(
                    FontAwesomeIcons.circleInfo,
                    color: MyColors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      specialInfo,
                      style: const TextStyle(
                        fontSize: Font.small,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            if (_isToday(date)) ...[
              const Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.calendarDay,
                    color: MyColors.primary,
                    size: 16,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'This is today',
                    style: TextStyle(
                      fontSize: Font.small,
                      color: MyColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().copyWith(
        hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);

    return Column(
      children: [
        // Booking window information
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: MyColors.blueGrey.withValues(alpha: 0.1),
            borderRadius: kRadius10,
            border: Border.all(color: MyColors.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const FaIcon(
                FontAwesomeIcons.circleInfo,
                size: 14,
                color: MyColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: Font.extraSmall,
                      color: Colors.black87,
                    ),
                    children: [
                      const TextSpan(text: 'Doctor accepts bookings '),
                      TextSpan(
                        text: widget.bookingAdvanceHours >= 24
                            ? '${widget.bookingAdvanceHours ~/ 24} day(s)'
                            : '${widget.bookingAdvanceHours} hour(s)',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: ' in advance'),
                      const TextSpan(text: ' and '),
                      const TextSpan(text: 'up to '),
                      TextSpan(
                        text: '${widget.bookingWindowDays} day(s)',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: ' in the future'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        kGap10,

        // Month tabs
        Container(
          decoration: BoxDecoration(
            color: MyColors.blueGrey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TabBar(
            controller: _monthTabController,
            isScrollable: true,
            labelColor: MyColors.primary,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: Font.small,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: Font.small,
            ),
            indicatorColor: MyColors.primary,
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: Colors.transparent,
            tabs: months.map((month) => Tab(text: month)).toList(),
          ),
        ),

        kGap10,

        // Date selector row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left navigation
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.chevronLeft, size: 18),
              onPressed: _navigateToPreviousDate,
              style: IconButton.styleFrom(
                backgroundColor: MyColors.blueGrey.withValues(alpha: 0.1),
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(8),
              ),
              tooltip: 'Previous day',
            ),

            // Today button
            TextButton.icon(
              onPressed: _scrollToToday,
              icon: const FaIcon(
                FontAwesomeIcons.calendarDay,
                size: 14,
                color: MyColors.primary,
              ),
              label: Text(
                today.isBefore(firstDate) ? 'Earliest' : 'Today',
                style: const TextStyle(
                  color: MyColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: MyColors.primary.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),

            // Right navigation
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.chevronRight, size: 18),
              onPressed: _navigateToNextDate,
              style: IconButton.styleFrom(
                backgroundColor: MyColors.blueGrey.withValues(alpha: 0.1),
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(8),
              ),
              tooltip: 'Next day',
            ),
          ],
        ),

        kGap10,

        // Date cards
        SizedBox(
          height: 100,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onDateChanged,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final date = _calculateDateFromPageIndex(index);
              final isSelected = compareDates(date, currentDate);
              final isAvailable = _isDateAvailable(date);
              final isToday = _isToday(date);
              final specialInfo = _getSpecialDateInfo(date);

              return GestureDetector(
                onTap: () {
                  if (isAvailable) {
                    // If already selected, do nothing
                    if (!isSelected) {
                      setState(() {
                        currentDate = date;
                        widget.onDateChanged(date);
                      });
                    }
                  } else {
                    // Show information about unavailable date
                    _showDateInfoDialog(date, isAvailable);
                  }
                },
                onLongPress: () {
                  // Show date info on long press
                  _showDateInfoDialog(date, isAvailable);
                },
                child: FractionallySizedBox(
                  widthFactor: 0.8,
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                MyColors.primary,
                                MyColors.primary.withValues(alpha: 0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: !isSelected
                          ? (isAvailable ? Colors.white : Colors.grey.shade100)
                          : null,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? MyColors.primary.withValues(alpha: 0.3)
                              : Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : (isAvailable
                                ? (isToday
                                    ? MyColors.primary
                                    : Colors.grey.shade300)
                                : Colors.grey.shade300),
                        width: isToday && !isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Weekday
                        Text(
                          DateFormat('E').format(date),
                          style: TextStyle(
                            fontSize: isSelected ? Font.small : Font.extraSmall,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? Colors.white
                                : (isAvailable
                                    ? Colors.grey
                                    : Colors.grey.shade400),
                          ),
                        ),

                        // Day number
                        Text(
                          DateFormat('d').format(date),
                          style: TextStyle(
                            fontSize: isSelected ? 28 : 24,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : (isAvailable
                                    ? (isToday
                                        ? MyColors.primary
                                        : Colors.black87)
                                    : Colors.grey.shade400),
                          ),
                        ),

                        // Month
                        Text(
                          DateFormat('MMM').format(date),
                          style: TextStyle(
                            fontSize: isSelected ? Font.small : Font.extraSmall,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? Colors.white
                                : (isAvailable
                                    ? Colors.grey
                                    : Colors.grey.shade400),
                          ),
                        ),

                        // Special indicator
                        if (specialInfo != null && !isSelected)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isAvailable
                                  ? MyColors.primary
                                  : Colors.grey.shade400,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
            itemCount: _calculatePageIndex(lastDate) + 1,
          ),
        ),
      ],
    );
  }
}
