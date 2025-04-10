import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../patient/search_doctors/widgets/date_navigator.dart';
import '../../../styles/colors.dart';
import '../../../styles/font.dart';
import '../../../styles/sizes.dart';

class EnhancedTimeSlotSelector extends StatefulWidget {
  final List<String> amOptions;
  final List<String> pmOptions;
  final void Function(bool)? onSelected;
  final void Function(String, int) onChanged;
  final int? selectedIndex;

  /// Optional map to mark certain time slots as unavailable with reasons
  final Map<String, String>? unavailableSlots;

  /// Duration of each time slot in minutes
  final int slotDurationMinutes;

  /// Optional doctor name to display in headers
  final String? doctorName;

  const EnhancedTimeSlotSelector({
    super.key,
    required this.amOptions,
    required this.pmOptions,
    required this.onChanged,
    this.onSelected,
    this.selectedIndex,
    this.unavailableSlots,
    this.slotDurationMinutes = 30,
    this.doctorName,
  });

  @override
  State<EnhancedTimeSlotSelector> createState() =>
      _EnhancedTimeSlotSelectorState();
}

class _EnhancedTimeSlotSelectorState extends State<EnhancedTimeSlotSelector> {
  int? _selectedIndex;
  bool _amExpanded = true;
  bool _pmExpanded = true;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;

    // Auto-collapse sections if they have no available slots
    if (widget.unavailableSlots != null) {
      bool hasAvailableAmSlots = widget.amOptions.any((slot) => !widget
          .unavailableSlots!
          .containsKey(_convertTo24HourFormat(slot, isAm: true)));

      bool hasAvailablePmSlots = widget.pmOptions.any((slot) => !widget
          .unavailableSlots!
          .containsKey(_convertTo24HourFormat(slot, isAm: false)));

      _amExpanded = hasAvailableAmSlots || !hasAvailablePmSlots;
      _pmExpanded = hasAvailablePmSlots || !hasAvailableAmSlots;
    }
  }

  String _convertTo24HourFormat(String time, {bool isAm = true}) {
    List<String> parts = time.split(':');
    int hours = int.parse(parts[0]);
    String minutes = parts[1];

    if (!isAm && hours != 12) {
      hours += 12;
    } else if (isAm && hours == 12) {
      hours = 0;
    }

    return '${hours.toString().padLeft(2, '0')}:$minutes';
  }

  String _formatTimeSlot(String time) {
    return "$time - ${_calculateEndTime(time)}";
  }

  String _calculateEndTime(String startTime) {
    // Parse the start time
    List<String> parts = startTime.split(':');
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);

    // Add slot duration
    minutes += widget.slotDurationMinutes;
    if (minutes >= 60) {
      hours += minutes ~/ 60;
      minutes = minutes % 60;
    }

    // Handle day overflow
    hours = hours % 12;
    if (hours == 0) hours = 12;

    return "$hours:${minutes.toString().padLeft(2, '0')}";
  }

  bool _isSlotAvailable(String time, bool isAm) {
    final slot24h = _convertTo24HourFormat(time, isAm: isAm);
    return widget.unavailableSlots == null ||
        !widget.unavailableSlots!.containsKey(slot24h);
  }

  String? _getUnavailableReason(String time, bool isAm) {
    if (widget.unavailableSlots == null) return null;

    final slot24h = _convertTo24HourFormat(time, isAm: isAm);
    return widget.unavailableSlots![slot24h];
  }

  void _showUnavailableDialog(String time, bool isAm, String reason) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Time Slot Unavailable',
                style: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _formatTimeSlot(time),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FaIcon(
                    FontAwesomeIcons.circleInfo,
                    size: 16,
                    color: Colors.red[700],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      reason,
                      style: const TextStyle(
                        fontSize: Font.small,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.amOptions.isNotEmpty)
            _buildTimeSection(
              icon: FontAwesomeIcons.solidSun,
              iconColor: Colors.amber,
              title: 'Morning (AM)',
              options: widget.amOptions,
              isAm: true,
              startIndex: 0,
              isExpanded: _amExpanded,
              onExpandToggle: () => setState(() => _amExpanded = !_amExpanded),
            ),
          const SizedBox(height: 16),
          if (widget.pmOptions.isNotEmpty)
            _buildTimeSection(
              icon: FontAwesomeIcons.solidMoon,
              iconColor: Colors.indigo,
              title: 'Evening (PM)',
              options: widget.pmOptions,
              isAm: false,
              startIndex: widget.amOptions.length,
              isExpanded: _pmExpanded,
              onExpandToggle: () => setState(() => _pmExpanded = !_pmExpanded),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<String> options,
    required bool isAm,
    required int startIndex,
    required bool isExpanded,
    required VoidCallback onExpandToggle,
  }) {
    // Count available slots
    final availableCount =
        options.where((slot) => _isSlotAvailable(slot, isAm)).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with expansion toggle
        InkWell(
          onTap: onExpandToggle,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: FaIcon(
                      icon,
                      color: iconColor,
                      size: 16,
                    ),
                  ),
                ),
                kGap10,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: Font.family,
                        fontSize: Font.medium,
                      ),
                    ),
                    Text(
                      "$availableCount available slots",
                      style: TextStyle(
                        fontSize: Font.extraSmall,
                        color: availableCount > 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.grey[700],
                ),
              ],
            ),
          ),
        ),

        // Time slots
        if (isExpanded) ...[
          const SizedBox(height: 10),
          if (availableCount == 0)
            _buildNoSlotsMessage(isAm ? "morning" : "evening")
          else
            _buildTimeGrid(options, isAm, startIndex),
        ],
      ],
    );
  }

  Widget _buildNoSlotsMessage(String timeOfDay) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          const FaIcon(
            FontAwesomeIcons.calendarXmark,
            size: 18,
            color: Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "No Available Slots",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  "There are no available appointments in the $timeOfDay",
                  style: TextStyle(
                    fontSize: Font.small,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeGrid(List<String> options, bool isAm, int startIndex) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        childAspectRatio: 2.5,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final time = options[index];
        final isAvailable = _isSlotAvailable(time, isAm);
        final isSelected = _selectedIndex == (startIndex + index);
        final slot24h = _convertTo24HourFormat(time, isAm: isAm);

        return GestureDetector(
          onTap: () {
            if (isAvailable) {
              setState(() {
                if (widget.onSelected != null) {
                  widget.onSelected!(true);
                }
                _selectedIndex = startIndex + index;
                widget.onChanged(slot24h, _selectedIndex!);
              });

              // Add haptic feedback
              HapticFeedback.selectionClick();
            } else {
              // Show reason dialog
              final reason = _getUnavailableReason(time, isAm) ??
                  "This time slot is no longer available";
              _showUnavailableDialog(time, isAm, reason);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        MyColors.primary,
                        MyColors.primary.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: !isSelected
                  ? (isAvailable ? Colors.white : Colors.grey[100])
                  : null,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? MyColors.primary.withOpacity(0.3)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : (isAvailable ? Colors.grey[300]! : Colors.grey[400]!),
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Time display
                Text(
                  time,
                  style: TextStyle(
                    fontSize: isSelected ? Font.small : Font.extraSmall,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? Colors.white
                        : (isAvailable ? Colors.black87 : Colors.grey[500]),
                  ),
                ),

                // Unavailable overlay
                if (!isAvailable && !isSelected)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.red[400],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 8,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Wrapper that combines date and time selection
class AppointmentDateTimeSelector extends StatefulWidget {
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;

  // Doctor settings
  final List<bool> doctorAvailableDays;
  final int bookingAdvanceHours;
  final int bookingWindowDays;
  final int slotDurationMinutes;
  final Map<DateTime, List<String>>? bookedSlots;
  final String doctorName;

  const AppointmentDateTimeSelector({
    super.key,
    this.selectedDate,
    this.selectedTime,
    required this.onDateChanged,
    required this.onTimeChanged,
    required this.doctorAvailableDays,
    required this.bookingAdvanceHours,
    required this.bookingWindowDays,
    required this.slotDurationMinutes,
    this.bookedSlots,
    required this.doctorName,
  });

  @override
  State<AppointmentDateTimeSelector> createState() =>
      _AppointmentDateTimeSelectorState();
}

class _AppointmentDateTimeSelectorState
    extends State<AppointmentDateTimeSelector> {
  DateTime? _currentDate;

  @override
  void initState() {
    super.initState();
    _currentDate = widget.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    // Generate time slots based on doctor's working hours
    List<String> amSlots = [];
    List<String> pmSlots = [];

    // In a real app, generate these based on doctor's working hours for selected date
    // For this example, we'll show fixed slots
    for (int hour = 8; hour < 12; hour++) {
      amSlots.add('$hour:00');
      if (hour < 11) amSlots.add('$hour:30');
    }

    for (int hour = 12; hour <= 17; hour++) {
      final display = hour > 12 ? hour - 12 : hour;
      pmSlots.add('$display:00');
      if (hour < 17) pmSlots.add('$display:30');
    }

    // Generate unavailable slots map
    Map<String, String> unavailableSlots = {};

    if (_currentDate != null && widget.bookedSlots != null) {
      for (var entry in widget.bookedSlots!.entries) {
        // If this entry is for the current selected date
        if (_isSameDate(entry.key, _currentDate!)) {
          for (var timeSlot in entry.value) {
            unavailableSlots[timeSlot] = "Already booked by another patient";
          }
        }
      }
    }

    // Add some lunch break slots as unavailable
    unavailableSlots['12:00'] = "${widget.doctorName}'s lunch break";
    unavailableSlots['12:30'] = "${widget.doctorName}'s lunch break";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date selection
        EnhancedDateNavigationWidget(
          onDateChanged: (date) {
            setState(() {
              _currentDate = date;
// Reset time when date changes
            });
            widget.onDateChanged(date);
          },
          selectedDate: _currentDate,
          availableDays: widget.doctorAvailableDays,
          bookingAdvanceHours: widget.bookingAdvanceHours,
          bookingWindowDays: widget.bookingWindowDays,
          specialDates: {
            DateTime.now().add(const Duration(days: 3)):
                "${widget.doctorName} has limited availability",
          },
        ),

        const SizedBox(height: 24),

        // Time selection
        if (_currentDate != null) ...[
          const Text(
            'Choose Appointment Time',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          EnhancedTimeSlotSelector(
            amOptions: amSlots,
            pmOptions: pmSlots,
            slotDurationMinutes: widget.slotDurationMinutes,
            unavailableSlots: unavailableSlots,
            doctorName: widget.doctorName,
            onChanged: (timeString, index) {
              // Convert string time to TimeOfDay
              final parts = timeString.split(':');
              final hour = int.parse(parts[0]);
              final minute = int.parse(parts[1]);

              final time = TimeOfDay(hour: hour, minute: minute);
              setState(() {});
              widget.onTimeChanged(time);
            },
          ),
        ],
      ],
    );
  }

  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
