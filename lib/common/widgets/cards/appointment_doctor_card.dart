import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:medtalk/backend/appointment/enums/appointment_status.dart';
import 'package:medtalk/common/widgets/base/custom_base.dart';
import 'package:medtalk/styles/colors.dart';
import 'package:medtalk/styles/font.dart';
import 'package:medtalk/styles/sizes.dart';

import '../../../agora/screens/call.dart';
import '../../globals/globals.dart';
import '../dividers/section_divider.dart';

class AppointmentWidgetDoctor extends StatelessWidget {
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
  final VoidCallback? onCancel;

  const AppointmentWidgetDoctor(
      {super.key,
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
      required this.showButton,
      required this.isPast,
      this.cancelReason,
      this.onCancel});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(status);
    final isCanceled = status == AppointmentStatus.cancelled;

    void showAppointmentDetails() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => _AppointmentDetailsSheet(
          appointmentDate: appointmentDate,
          name: name,
          biography: null,
          location: location,
          serviceName: serviceName,
          duration: null,
          fee: fee,
          status: status,
          cancelReason: cancelReason,
          onCancel: onCancel,
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        showAppointmentDetails();

        onCardTap?.call();
      },
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
                    color: statusColor.withValues(alpha: 0.1),
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

// Usage example widget for the patient dashboard
class _AppointmentDetailsSheet extends StatelessWidget {
  final DateTime appointmentDate;
  final String? name;
  final String? biography;
  final String? location;
  final String serviceName;
  final int? duration;
  final int fee;
  final AppointmentStatus? status;
  final String? cancelReason;
  final VoidCallback? onCancel;

  const _AppointmentDetailsSheet({
    required this.appointmentDate,
    required this.name,
    required this.biography,
    required this.location,
    required this.serviceName,
    required this.duration,
    required this.fee,
    required this.status,
    required this.cancelReason,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPast = appointmentDate.isBefore(DateTime.now());

    return Container(
      padding: kPadd20,
      decoration: const BoxDecoration(
        color: MyColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          kGap20,
          const Text(
            'Appointment Details',
            style: TextStyle(
              fontSize: Font.mediumLarge,
              fontWeight: FontWeight.bold,
            ),
          ),
          kGap14,
          const SectionDivider(),
          kGap14,
          _DetailRow(
            icon: FontAwesomeIcons.user,
            title: 'Patient',
            value: name ?? 'Unknown Patient',
          ),
          _DetailRow(
            icon: FontAwesomeIcons.calendar,
            title: 'Date',
            value: DateFormat('EEEE, MMM dd, yyyy').format(appointmentDate),
          ),
          _DetailRow(
            icon: FontAwesomeIcons.clock,
            title: 'Time',
            value: DateFormat('h:mm a').format(appointmentDate),
          ),
          _DetailRow(
            icon: FontAwesomeIcons.stethoscope,
            title: 'Service',
            value: serviceName,
          ),
          _DetailRow(
            icon: FontAwesomeIcons.locationDot,
            title: 'Location',
            value: location ?? 'Online Consultation',
          ),
          _DetailRow(
            icon: FontAwesomeIcons.tag,
            title: 'Status',
            value: _capitalizeStatus(status),
          ),
          _DetailRow(
            icon: FontAwesomeIcons.dollarSign,
            title: 'Fee',
            value: '\$${fee}',
          ),
          kGap14,
          _DetailTextArea(
            icon: FontAwesomeIcons.comment,
            title: 'Patient Biography',
            value: biography ?? 'No Biography',
          ),
          kGap20,
          if (_canJoinCall())
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  AppGlobal.navigatorKey.currentState!.push(
                    VideoCallScreen.route(),
                  );
                },
                icon: const FaIcon(FontAwesomeIcons.video),
                label: const Text('Join Call'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.primary,
                  foregroundColor: Colors.white,
                  padding: kPaddV14,
                ),
              ),
            ),
          kGap14,

          // Status update buttons for non-completed/canceled appointments
          if (!isPast &&
              status != AppointmentStatus.completed &&
              status != AppointmentStatus.cancelled)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // are you sure? (omni-man meme)
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: MyColors.cardBackground,
                          title: const Text('Are you sure?',
                              style: TextStyle(
                                fontSize: Font.medium,
                                fontWeight: FontWeight.bold,
                              )),
                          content: const Text('This action cannot be undone.',
                              style: TextStyle(
                                fontSize: Font.mediumSmall,
                              )),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Update status to completed
                                onCancel?.call();
                                // context.read<DoctorAppointmentsBloc>().add(
                                //   UpdateAppointmentStatus(
                                //     appointmentId:
                                //     appointment.appointmentId ?? '',
                                //     newStatus: AppointmentStatus.completed,
                                //   ),
                                // );
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: MyColors.buttonRed,
                                foregroundColor: Colors.white,
                                padding: kPaddH8V4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: kRadiusAll,
                                ),
                              ),
                              child: const Text('Yes'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const FaIcon(FontAwesomeIcons.ban, size: 16),
                    label: const Text('Cancel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.buttonRed,
                      foregroundColor: Colors.white,
                      padding: kPaddV6,
                      shape: RoundedRectangleBorder(
                        borderRadius: kRadiusAll,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          kGap2,
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close',
                  style: TextStyle(color: MyColors.primary)),
            ),
          ),
        ],
      ),
    );
  }

  bool _canJoinCall() {
    final now = DateTime.now();
    final startWindow = appointmentDate.subtract(const Duration(minutes: 10));
    final endWindow = appointmentDate.add(Duration(minutes: duration ?? 30));

    return now.isAfter(startWindow) &&
        now.isBefore(endWindow) &&
        status != AppointmentStatus.cancelled;
  }

  String _capitalizeStatus(AppointmentStatus? status) {
    if (status == null) return "Scheduled";

    return status
        .toString()
        .split('.')
        .last
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}

class _DetailTextArea extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DetailTextArea({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kPaddV6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 16,
                child: FaIcon(
                  icon,
                  size: 16,
                  color: MyColors.primary,
                ),
              ),
              kGap10,
              SizedBox(
                width: 180,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: Font.small,
                    color: MyColors.subtitleDark,
                  ),
                ),
              ),
            ],
          ),
          kGap10,
          Container(
            padding: kPadd10,
            decoration: BoxDecoration(
              color: MyColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: Font.small,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kPaddV6,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            child: FaIcon(
              icon,
              size: 16,
              color: MyColors.primary,
            ),
          ),
          kGap10,
          SizedBox(
            width: 80,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: Font.small,
                color: MyColors.subtitleDark,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: Font.small,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
