import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:medtalk/patient/search_doctors/widgets/appointments_details_card.dart';

import '../../../../../styles/colors.dart';
import '../../../../../styles/font.dart';
import '../../../../../styles/sizes.dart';
import '../../../bloc/setup_appointment_bloc.dart';

class ImprovedSummaryScreen extends StatelessWidget {
  final SetupAppointmentState state;
  final VoidCallback onConfirm;
  final Function(bool) onTermsChanged;

  const ImprovedSummaryScreen({
    super.key,
    required this.state,
    required this.onConfirm,
    required this.onTermsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('EEEE, MMMM d, yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with confirmation icon
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: FaIcon(
                  FontAwesomeIcons.checkDouble,
                  color: Colors.green,
                  size: 20,
                ),
              ),
            ),
            kGap16,
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Almost Done!',
                    style: TextStyle(
                      fontSize: Font.medium,
                      fontWeight: FontWeight.bold,
                      color: MyColors.textBlack,
                    ),
                  ),
                  Text(
                    'Please review your appointment details',
                    style: TextStyle(
                      fontSize: Font.small,
                      color: MyColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        kGap24,

        // Doctor information card
        AppointmentsDetailsCard(
          state: state,
        ),

        kGap16,

        // Payment notice
        Container(
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[100]!),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  shape: BoxShape.circle,
                ),
                child: const FaIcon(
                  FontAwesomeIcons.circleInfo,
                  color: Colors.blue,
                  size: 14,
                ),
              ),
              kGap12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Policy',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: Font.small,
                        color: Colors.blue[800],
                      ),
                    ),
                    kGap4,
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: Font.family,
                          fontSize: Font.small,
                          color: Colors.blue[800],
                        ),
                        children: [
                          const TextSpan(text: 'You will '),
                          TextSpan(
                            text: 'NOT',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                          const TextSpan(
                            text:
                                ' be charged until the consultation is completed. If the appointment is canceled or not conducted, no charge will be made.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Cancellation policy if available
        if (state.cancellationPolicy > 0) ...[
          kGap16,
          Container(
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange[100]!),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    shape: BoxShape.circle,
                  ),
                  child: const FaIcon(
                    FontAwesomeIcons.circleExclamation,
                    color: Colors.orange,
                    size: 14,
                  ),
                ),
                kGap12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cancellation Policy',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: Font.small,
                          color: Colors.orange,
                        ),
                      ),
                      kGap4,
                      Text(
                        _formatCancellationPolicy(state.cancellationPolicy),
                        style: TextStyle(
                          fontSize: Font.small,
                          color: Colors.orange[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _formatCancellationPolicy(int hours) {
    if (hours == 0) {
      return 'No cancellations allowed.';
    } else if (hours < 24) {
      return 'Free cancellation up to $hours hours before the appointment.';
    } else {
      final days = hours ~/ 24;
      return 'Free cancellation up to $days ${days == 1 ? 'day' : 'days'} before the appointment.';
    }
  }
}
