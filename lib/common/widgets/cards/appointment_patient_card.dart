import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:medtalk/backend/appointment/enums/appointment_status.dart';
import 'package:medtalk/common/widgets/base/custom_base.dart';
import 'package:medtalk/styles/colors.dart';
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
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(status, theme);
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
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.primaryColor,
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
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getStatusText(status),
                    style: theme.textTheme.labelSmall?.copyWith(
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
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.normal,
                color: theme.brightness == Brightness.light
                    ? MyColors.subtitle
                    : MyColors.textGrey,
              ),
            ),
            kGap8,

            // Date and time
            Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.calendarCheck,
                  size: 16,
                  color: theme.primaryColor,
                ),
                kGap8,
                Text(
                  DateFormat('EEEE, MMM dd, yyyy').format(appointmentDate),
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            kGap8,

            // Time and service
            Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.clock,
                  size: 14,
                  color: theme.brightness == Brightness.light
                      ? MyColors.subtitleDark
                      : MyColors.textGrey,
                ),
                kGap8,
                Text(
                  DateFormat('h:mm a').format(appointmentDate),
                  style: theme.textTheme.labelMedium,
                ),
                kGap16,
                FaIcon(
                  FontAwesomeIcons.stethoscope,
                  size: 14,
                  color: theme.brightness == Brightness.light
                      ? MyColors.subtitleDark
                      : MyColors.textGrey,
                ),
                kGap8,
                Expanded(
                  child: Text(
                    specialty,
                    style: theme.textTheme.labelMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            kGap8,

            // Location and fee
            Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.locationDot,
                  size: 14,
                  color: theme.brightness == Brightness.light
                      ? MyColors.subtitleDark
                      : MyColors.textGrey,
                ),
                kGap8,
                Expanded(
                  child: Text(
                    location,
                    style: theme.textTheme.labelMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '\$${fee.toStringAsFixed(2)}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            // Cancellation reason if cancelled
            if (isCanceled && cancelReason != null) ...[
              kGap8,
              Divider(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
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
                      style: theme.textTheme.labelMedium?.copyWith(
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
              Divider(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
              kGap8,
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isReady ? onJoinCall : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(42),
                    backgroundColor: theme.primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: kRadius10,
                    ),
                    disabledBackgroundColor:
                        theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  ),
                  child: Text(
                    isReady ? 'Join Call' : 'Waiting for scheduled time',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isReady
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ],

            // For non-past appointments that aren't cancelled and don't show a button
            if (!showButton && !isPast && !isCanceled) ...[
              kGap12,
              Divider(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
              kGap8,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    FontAwesomeIcons.circleInfo,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                  kGap8,
                  Expanded(
                    child: Text(
                      'Appointments are initiated by patients. You can view details but cannot reschedule or start calls.',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: theme.colorScheme.primary,
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

  Color _getStatusColor(AppointmentStatus? status, ThemeData theme) {
    switch (status) {
      case AppointmentStatus.completed:
        return MyColors.green;
      case AppointmentStatus.cancelled:
        return MyColors.cancel;
      case AppointmentStatus.missed:
        return MyColors.pending;
      case AppointmentStatus.scheduled:
        return theme.primaryColor;
      default:
        return theme.primaryColor;
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
