import 'package:backend/backend.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:medtalk/common/widgets/base/custom_base.dart';
import 'package:medtalk/styles/colors.dart';
import 'package:medtalk/styles/font.dart';
import 'package:medtalk/styles/sizes.dart';

class AppointmentWidgetPatient extends StatelessWidget {
  final String specialty;
  final String name;
  final DateTime appointmentDate;
  final String location;
  final String serviceName;
  final int fee;
  final AppointmentStatus? status;
  final bool isReady;
  final VoidCallback? onJoinCall;
  final VoidCallback? onCardTap;
  final bool showButton;
  final bool isPast;
  final String? cancelReason;

  const AppointmentWidgetPatient({
    super.key,
    required this.specialty,
    required this.name,
    required this.appointmentDate,
    required this.location,
    required this.serviceName,
    required this.fee,
    this.status,
    required this.isReady,
    this.onJoinCall,
    this.onCardTap,
    this.showButton = true,
    this.isPast = false,
    this.cancelReason,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(status);
    final isCanceled = status == AppointmentStatus.cancelled;

    return GestureDetector(
      onTap: onCardTap,
      child: CustomBase(
        shadow: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with specialty and status
            Row(
              children: [
                Text(
                  serviceName,
                  style: const TextStyle(
                    fontSize: Font.medium,
                    color: MyColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getStatusText(status),
                    style: TextStyle(
                      fontSize: Font.extraSmall,
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            // Doctor name
            Text(
              name,
              style: const TextStyle(
                fontSize: Font.cardSubTitleSize,
                fontWeight: FontWeight.normal,
                color: MyColors.subtitle,
              ),
            ),
            kGap8,

            // Date and time
            Row(
              children: [
                const FaIcon(
                  FontAwesomeIcons.calendarCheck,
                  size: 16,
                  color: MyColors.primary,
                ),
                kGap8,
                Text(
                  DateFormat('EEEE, MMM dd, yyyy').format(appointmentDate),
                  style: const TextStyle(
                    fontSize: Font.small,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            kGap8,

            // Time and service
            Row(
              children: [
                const FaIcon(
                  FontAwesomeIcons.clock,
                  size: 14,
                  color: MyColors.subtitleDark,
                ),
                kGap8,
                Text(
                  DateFormat('h:mm a').format(appointmentDate),
                  style: const TextStyle(
                    fontSize: Font.small,
                  ),
                ),
                kGap16,
                const FaIcon(
                  FontAwesomeIcons.stethoscope,
                  size: 14,
                  color: MyColors.subtitleDark,
                ),
                kGap8,
                Expanded(
                  child: Text(
                    specialty,
                    style: const TextStyle(
                      fontSize: Font.small,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            kGap8,

            // Location and fee
            Row(
              children: [
                const FaIcon(
                  FontAwesomeIcons.locationDot,
                  size: 14,
                  color: MyColors.subtitleDark,
                ),
                kGap8,
                Expanded(
                  child: Text(
                    location,
                    style: const TextStyle(
                      fontSize: Font.small,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '\$${fee.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: Font.small,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            // Cancellation reason if cancelled
            if (isCanceled && cancelReason != null) ...[
              kGap8,
              const Divider(),
              kGap8,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FaIcon(
                    FontAwesomeIcons.circleInfo,
                    size: 14,
                    color: Colors.red,
                  ),
                  kGap8,
                  Expanded(
                    child: Text(
                      'Reason: $cancelReason',
                      style: const TextStyle(
                        fontSize: Font.small,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Join call button (if applicable)
            if (showButton && !isPast && !isCanceled) ...[
              kGap12,
              const Divider(),
              kGap8,
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isReady ? onJoinCall : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(42),
                    backgroundColor: MyColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: kRadius10,
                    ),
                  ),
                  child: Text(
                    isReady ? 'Join Call' : 'Waiting for scheduled time',
                    style: TextStyle(
                      fontSize: Font.small,
                      fontWeight: FontWeight.bold,
                      color: isReady ? MyColors.buttonText : MyColors.textGrey,
                    ),
                  ),
                ),
              ),
            ],

            // For non-past appointments that aren't cancelled and don't show a button
            if (!showButton && !isPast && !isCanceled) ...[
              kGap12,
              const Divider(),
              kGap8,
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    FontAwesomeIcons.circleInfo,
                    size: 14,
                    color: Colors.blue,
                  ),
                  kGap8,
                  Expanded(
                    child: Text(
                      'Appointments are initiated by patients. You can view details but cannot reschedule or start calls.',
                      style: TextStyle(
                        fontSize: Font.extraSmall,
                        fontStyle: FontStyle.italic,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(AppointmentStatus? status) {
    switch (status) {
      case AppointmentStatus.completed:
        return Colors.green;
      case AppointmentStatus.cancelled:
        return Colors.red;
      case AppointmentStatus.missed:
        return Colors.orange;
      case AppointmentStatus.scheduled:
        return MyColors.primary;
      default:
        return MyColors.primary;
    }
  }

  String _getStatusText(AppointmentStatus? status) {
    switch (status) {
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.missed:
        return 'Missed';
      case AppointmentStatus.scheduled:
        return 'Scheduled';
      default:
        return 'Scheduled';
    }
  }
}
