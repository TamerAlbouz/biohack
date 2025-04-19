import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:medtalk/backend/appointment/enums/appointment_type.dart';
import 'package:medtalk/backend/patient/models/patient.dart';
import 'package:medtalk/backend/payment/enums/payment_type.dart';

import '../../../common/widgets/base/custom_base.dart';
import '../../../styles/colors.dart';
import '../../../styles/font.dart';
import '../../../styles/sizes.dart';
import '../bloc/setup_appointment_bloc.dart';

class AppointmentsDetailsCard extends StatelessWidget {
  const AppointmentsDetailsCard({
    super.key,
    required this.state,
  });

  final SetupAppointmentState state;

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('EEEE, MMMM d, yyyy');

    final selectedCard = state.savedCreditCards!.firstWhere(
      (card) => card.id == state.selectedCardId,
      orElse: () => SavedCreditCard(
        id: '',
        cardNumber: '****',
        cardholderName: 'Unknown',
        expiryDate: '**/**',
        cardType: 'Credit Card',
      ),
    );

    return CustomBase(
      padding: kPadd0,
      child: Column(
        children: [
          // Date and time section
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  MyColors.primary,
                  MyColors.primary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const FaIcon(
                    FontAwesomeIcons.calendarCheck,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                kGap16,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Appointment',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: Font.mediumSmall,
                        ),
                      ),
                      kGap4,
                      Row(
                        children: [
                          Text(
                            dateFormat.format(state.appointmentDate!),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: Font.small,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Text(
                            state.appointmentTime!.format(context),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: Font.small,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Service details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildServiceSummarySection(state),
                kGap12,
                const Divider(),
                kGap12,
                _buildDetailItem(
                  title: 'Appointment Type',
                  value: state.selectedAppointment!.value,
                  icon:
                      _getAppointmentTypeIcon(state.selectedAppointment!.value),
                ),
                kGap12,
                _buildDetailItem(
                  title: 'Location',
                  value: state.appointmentLocation,
                  icon: FontAwesomeIcons.locationDot,
                ),
                kGap12,
                const Divider(),
                kGap12,
                _buildDetailItem(
                  title: 'Payment Method',
                  value: state.selectedPayment == PaymentType.creditCard &&
                          state.selectedCardId != null &&
                          state.savedCreditCards != null
                      ? '${selectedCard.cardType} ending in ${selectedCard.cardNumber}'
                      : state.selectedPayment?.value ?? 'Credit Card',
                  icon: _getPaymentTypeIcon(
                    state.selectedPayment?.value ?? 'Credit Card',
                  ),
                  trailing: Text(
                    '\$${state.selectedService!.price}',
                    style: const TextStyle(
                      fontFamily: Font.family,
                      color: MyColors.primary,
                      fontSize: Font.mediumSmall,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required String title,
    required String value,
    required IconData icon,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: MyColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: FaIcon(
              icon,
              size: 16,
              color: MyColors.primary,
            ),
          ),
        ),
        kGap16,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: Font.small,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: Font.family,
                  fontSize: Font.mediumSmall,
                  fontWeight: FontWeight.w500,
                  color: MyColors.textBlack,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildServiceSummarySection(SetupAppointmentState state) {
    return Column(
      children: [
        _buildDetailItem(
          title: 'Service',
          value: state.selectedService!.title,
          icon: FontAwesomeIcons.kitMedical,
        ),
        kGap12,
        _buildDetailItem(
          title: 'Duration',
          value: state.selectedService!.subtitle,
          icon: FontAwesomeIcons.clock,
        ),

        // If the service has custom availability, show it in the summary
        if (state.selectedServiceAvailability != null) ...[
          kGap12,
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.purple.withValues(alpha: 0.2)),
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
                          fontSize: Font.extraSmall,
                          color: Colors.purple[800],
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

  IconData _getPaymentTypeIcon(String paymentType) {
    switch (paymentType.toLowerCase()) {
      case 'cash':
        return FontAwesomeIcons.moneyBill;
      case 'credit card':
        return FontAwesomeIcons.creditCard;
      case 'insurance':
        return FontAwesomeIcons.fileInvoice;
      default:
        return FontAwesomeIcons.wallet;
    }
  }

  IconData _getAppointmentTypeIcon(String appointmentType) {
    switch (appointmentType.toLowerCase()) {
      case 'online':
        return FontAwesomeIcons.video;
      case 'in person':
        return FontAwesomeIcons.hospitalUser;
      case 'home visit':
        return FontAwesomeIcons.house;
      default:
        return FontAwesomeIcons.userDoctor;
    }
  }
}
