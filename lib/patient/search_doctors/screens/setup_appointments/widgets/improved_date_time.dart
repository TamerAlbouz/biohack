import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../../../../doctor/design/models/design_models.dart';
import '../../../../../styles/colors.dart';
import '../../../../../styles/font.dart';
import '../../../../../styles/sizes.dart';

class ImprovedDateTimeSelection extends StatefulWidget {
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final List<bool> availableDays;
  final Function(DateTime) onDateChanged;
  final Function(TimeOfDay, int) onTimeChanged;
  final List<WorkingHours> doctorWorkingHours;
  final int serviceDuration;
  final int bufferTime;
  final bool hasCustomAvailability;

  const ImprovedDateTimeSelection({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    required this.availableDays,
    required this.onDateChanged,
    required this.onTimeChanged,
    required this.doctorWorkingHours,
    required this.serviceDuration,
    required this.bufferTime,
    this.hasCustomAvailability = false,
  });

  @override
  State<ImprovedDateTimeSelection> createState() =>
      _ImprovedDateTimeSelectionState();
}

class _ImprovedDateTimeSelectionState extends State<ImprovedDateTimeSelection> {
  final ScrollController _timeScrollController = ScrollController();
  int _selectedTimeIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // If using custom availability, show an info banner
        if (widget.hasCustomAvailability) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const FaIcon(
                    FontAwesomeIcons.calendarDay,
                    color: Colors.purple,
                    size: 16,
                  ),
                ),
                kGap12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Custom Service Hours',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: Font.small,
                          color: Colors.purple,
                        ),
                      ),
                      kGap4,
                      Text(
                        'This service has specific availability hours that may differ from the doctor\'s regular schedule.',
                        style: TextStyle(
                          fontSize: Font.small,
                          color: Colors.purple[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          kGap16,
        ],

        // Modern date picker
        _buildDatePicker(),

        kGap20,

        // Time slots section
        if (widget.selectedDate != null) _buildTimeSlots(),
      ],
    );
  }

  Widget _buildDatePicker() {
    // Get current date and build a 3-week calendar
    final now = DateTime.now();
    final List<DateTime> dates = [];

    // Add dates for the next 3 weeks
    for (int i = 0; i < 21; i++) {
      dates.add(now.add(Duration(days: i)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month section with navigation
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('MMMM yyyy').format(dates.first),
              style: const TextStyle(
                fontSize: Font.medium,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    // Previous week logic
                  },
                  icon: const FaIcon(FontAwesomeIcons.chevronLeft, size: 16),
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(8),
                    backgroundColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                kGap8,
                IconButton(
                  onPressed: () {
                    // Next week logic
                  },
                  icon: const FaIcon(FontAwesomeIcons.chevronRight, size: 16),
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(8),
                    backgroundColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        kGap16,

        // Day selection
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final date = dates[index];
              final dayOfWeek = date.weekday - 1; // 0 = Monday, 6 = Sunday
              final isAvailable = dayOfWeek < widget.availableDays.length
                  ? widget.availableDays[dayOfWeek]
                  : false;
              final isSelected = widget.selectedDate != null &&
                  date.year == widget.selectedDate!.year &&
                  date.month == widget.selectedDate!.month &&
                  date.day == widget.selectedDate!.day;
              final isToday = date.year == now.year &&
                  date.month == now.month &&
                  date.day == now.day;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: isAvailable ? () => widget.onDateChanged(date) : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
// In the _buildDatePicker() method, update the Container decoration for date items
                      Container(
                        width: 70,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? widget.hasCustomAvailability
                                  ? Colors.purple.withValues(
                                      alpha: 0.05) // Change to lighter tint
                                  : MyColors.primary.withValues(
                                      alpha: 0.05) // Change to lighter tint
                              : isAvailable
                                  ? MyColors.cardBackground
                                  : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? widget.hasCustomAvailability
                                    ? Colors.purple
                                    : MyColors.primary
                                : isToday
                                    ? widget.hasCustomAvailability
                                        ? Colors.purple.withValues(alpha: 0.5)
                                        : MyColors.primary
                                            .withValues(alpha: 0.5)
                                    : Colors.grey[300]!,
                            width: isSelected
                                ? 2
                                : 1, // Keep the thicker border for selected
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: widget.hasCustomAvailability
                                        ? Colors.purple.withValues(alpha: 0.1)
                                        : MyColors.primary
                                            .withValues(alpha: 0.1),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('E').format(date).substring(0, 1),
                              style: TextStyle(
                                fontSize: Font.small,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? widget.hasCustomAvailability
                                        ? Colors
                                            .purple // Change to colored text instead of white
                                        : MyColors
                                            .primary // Change to colored text instead of white
                                    : Colors.grey[500],
                              ),
                            ),
                            Text(
                              date.day.toString(),
                              style: TextStyle(
                                fontSize: Font.mediumLarge,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? widget.hasCustomAvailability
                                        ? Colors
                                            .purple // Change to colored text instead of white
                                        : MyColors
                                            .primary // Change to colored text instead of white
                                    : isAvailable
                                        ? MyColors.textBlack
                                        : Colors.grey[400],
                              ),
                            ),
                            if (isToday && !isSelected)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      MyColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Today',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: MyColors.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Add single diagonal strikethrough for unavailable days
                      if (!isAvailable)
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CustomPaint(
                              painter: StrikeThroughPainter(
                                color: Colors.grey[400]!,
                                strokeWidth: 5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlots() {
    if (widget.selectedDate == null) {
      return const SizedBox.shrink();
    }

    // Check if selected date is available
    final selectedDay =
        widget.selectedDate!.weekday - 1; // 0 = Monday, 6 = Sunday
    if (!widget.availableDays[selectedDay]) {
      return _buildNoAvailabilityMessage(
          'The doctor is not available on this day.');
    }

    // Get available time slots
    final slots = _generateTimeSlots(selectedDay);

    if (slots.isEmpty) {
      return _buildNoAvailabilityMessage(
          'No available time slots for this date.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time slots header
        const Row(
          children: [
            FaIcon(
              FontAwesomeIcons.clock,
              size: 16,
              color: MyColors.primary,
            ),
            SizedBox(width: 8),
            Text(
              'Available Time Slots',
              style: TextStyle(
                fontSize: Font.mediumSmall,
                fontWeight: FontWeight.bold,
                color: MyColors.textBlack,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Time slots grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2.2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: slots.length,
          itemBuilder: (context, index) {
            final timeSlot = slots[index];
            final isSelected = _selectedTimeIndex == index;

            // Parse the time
            final parts = timeSlot.split(':');
            final hour = int.parse(parts[0]);
            final minute = int.parse(parts[1]);
            final time = TimeOfDay(hour: hour, minute: minute);

            // Format for display
            final isPM = hour >= 12;
            final displayHour = hour > 12
                ? hour - 12
                : hour == 0
                    ? 12
                    : hour;
            final displayMinute = minute.toString().padLeft(2, '0');
            final amPm = isPM ? 'PM' : 'AM';

            return InkWell(
              onTap: () {
                setState(() {
                  _selectedTimeIndex = index;
                  widget.onTimeChanged(time, index);
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? widget.hasCustomAvailability
                          ? Colors.purple
                              .withValues(alpha: 0.05) // Change to lighter tint
                          : MyColors.primary
                              .withValues(alpha: 0.05) // Change to lighter tint
                      : MyColors.cardBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? widget.hasCustomAvailability
                            ? Colors.purple // Change to lighter tint
                            : MyColors.primary
                        : Colors.grey[300]!,
                    width:
                        isSelected ? 2 : 1, // Add thicker border for selected
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: widget.hasCustomAvailability
                                ? Colors.purple.withValues(
                                    alpha: 0.1) // Change to lighter tint
                                : MyColors.primary.withValues(alpha: 0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null, // Add shadow for selected
                ),
                alignment: Alignment.center,
                child: Text(
                  '$displayHour:$displayMinute $amPm',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? widget.hasCustomAvailability
                            ? Colors.purple // Change to lighter tint
                            : MyColors.primary
                        : MyColors
                            .textBlack, // Change to colored text instead of white
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNoAvailabilityMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          const FaIcon(
            FontAwesomeIcons.calendarXmark,
            color: Colors.grey,
            size: 30,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: Font.small,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Please select another date.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: Font.small,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  List<String> _generateTimeSlots(int selectedDay) {
    List<String> slots = [];

    // Get working hours for the selected day
    if (selectedDay >= widget.doctorWorkingHours.length) {
      return slots;
    }

    final workingHours = widget.doctorWorkingHours[selectedDay];
    final startTime = workingHours.startTime;
    final endTime = workingHours.endTime;
    final breaks = workingHours.breaks;

    // Parse start and end times
    final startParts = startTime.split(':');
    final endParts = endTime.split(':');

    int startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
    int endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

    // Calculate slots
    int currentMinute = startMinutes;
    while (currentMinute + widget.serviceDuration <= endMinutes) {
      final slotHour = currentMinute ~/ 60;
      final slotMinute = currentMinute % 60;

      final slotEndMinute = currentMinute + widget.serviceDuration;

      // Check if slot overlaps with any break
      bool overlapsBreak = false;
      for (final breakTime in breaks) {
        final breakStartParts = breakTime.startTime.split(':');
        final breakEndParts = breakTime.endTime.split(':');

        int breakStartMinutes =
            int.parse(breakStartParts[0]) * 60 + int.parse(breakStartParts[1]);
        int breakEndMinutes =
            int.parse(breakEndParts[0]) * 60 + int.parse(breakEndParts[1]);

        // Check for overlap
        if ((currentMinute >= breakStartMinutes &&
                currentMinute < breakEndMinutes) ||
            (slotEndMinute > breakStartMinutes &&
                slotEndMinute <= breakEndMinutes) ||
            (currentMinute <= breakStartMinutes &&
                slotEndMinute >= breakEndMinutes)) {
          overlapsBreak = true;
          break;
        }
      }

      if (!overlapsBreak) {
        // Format the time
        final hour = slotHour.toString().padLeft(2, '0');
        final minute = slotMinute.toString().padLeft(2, '0');
        slots.add('$hour:$minute');
      }

      // Move to next slot
      currentMinute += widget.serviceDuration + widget.bufferTime;
    }

    return slots;
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes minutes';
    } else if (minutes == 60) {
      return '1 hour';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;

      if (remainingMinutes == 0) {
        return '$hours hours';
      } else {
        return '$hours hour${hours > 1 ? 's' : ''} $remainingMinutes minute${remainingMinutes > 1 ? 's' : ''}';
      }
    }
  }
}

class StrikeThroughPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  StrikeThroughPainter({
    required this.color,
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Draw single diagonal line from top-left to bottom-right
    canvas.drawLine(
      const Offset(0, 0),
      Offset(size.width, size.height),
      paint,
    );

    // Draw second diagonal line from top-right to bottom-left
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(0, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
