import 'package:flutter/material.dart';

import '../../../../../styles/colors.dart';
import '../../../../../styles/font.dart';
import '../../../../../styles/sizes.dart';

class ImprovedStepperHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepTitles;

  const ImprovedStepperHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepTitles,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // // Progress indicator
        // Container(
        //   margin: const EdgeInsets.symmetric(vertical: 24),
        //   padding: const EdgeInsets.symmetric(horizontal: 10),
        //   child: Column(
        //     children: [
        //       // Step indicator with circles and lines
        //       Row(
        //         children: List.generate(
        //           totalSteps * 2 - 1, // Generate alternating circles and lines
        //           (index) {
        //             final isCircle = index % 2 == 0;
        //             final stepIndex = index ~/ 2;
        //
        //             if (isCircle) {
        //               // Step circle
        //               return Container(
        //                 width: 60,
        //                 height: 32,
        //                 decoration: BoxDecoration(
        //                   color: stepIndex <= currentStep
        //                       ? MyColors.primary
        //                       : MyColors.primary.withValues(alpha: 0.15),
        //                   shape: BoxShape.circle,
        //                 ),
        //                 child: Center(
        //                   child: stepIndex < currentStep
        //                       ? const FaIcon(
        //                           FontAwesomeIcons.check,
        //                           color: Colors.white,
        //                           size: 14,
        //                         )
        //                       : Text(
        //                           '${stepIndex + 1}',
        //                           style: TextStyle(
        //                             color: stepIndex <= currentStep
        //                                 ? Colors.white
        //                                 : MyColors.primary,
        //                             fontWeight: FontWeight.bold,
        //                           ),
        //                         ),
        //                 ),
        //               );
        //             } else {
        //               // Connecting line
        //               return Expanded(
        //                 child: Container(
        //                   height: 3,
        //                   decoration: BoxDecoration(
        //                     color: stepIndex < currentStep
        //                         ? MyColors.primary
        //                         : MyColors.primary.withValues(alpha: 0.15),
        //                     borderRadius: BorderRadius.circular(2),
        //                   ),
        //                 ),
        //               );
        //             }
        //           },
        //         ),
        //       ),
        //
        //       // Step titles
        //       kGap8,
        //       Padding(
        //         padding: const EdgeInsets.symmetric(horizontal: 0),
        //         child: Row(
        //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //           children: List.generate(
        //             totalSteps, // Generate only the labels
        //             (index) {
        //               return SizedBox(
        //                 width: 60, // Fixed width matching the circles
        //                 child: Text(
        //                   _getShortTitle(stepTitles[index]),
        //                   style: TextStyle(
        //                     fontSize: Font.extraSmall,
        //                     color: index <= currentStep
        //                         ? MyColors.textBlack
        //                         : MyColors.textGrey,
        //                     fontWeight: index == currentStep
        //                         ? FontWeight.bold
        //                         : FontWeight.normal,
        //                   ),
        //                   maxLines: 1,
        //                   overflow: TextOverflow.ellipsis,
        //                   textAlign: TextAlign.center, // Center the text
        //                 ),
        //               );
        //             },
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),

        // Current step title
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          width: double.infinity,
          decoration: BoxDecoration(
            color: MyColors.primary.withValues(alpha: 0.05),
            border: Border(
              top: BorderSide(
                  color: MyColors.primary.withValues(alpha: 0.1), width: 1),
              bottom: BorderSide(
                  color: MyColors.primary.withValues(alpha: 0.1), width: 1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Step ${currentStep + 1} of $totalSteps',
                style: const TextStyle(
                  fontSize: Font.small,
                  color: MyColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              kGap4,
              Text(
                stepTitles[currentStep],
                style: const TextStyle(
                  fontSize: Font.medium,
                  fontWeight: FontWeight.bold,
                  color: MyColors.textBlack,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper method to abbreviate titles for better fit
  String _getShortTitle(String title) {
    final parts = title.split(' ');

    if (parts.length <= 1) {
      return title;
    }

    // For "Date & Time" -> "Date"
    // For "Payment & Review" -> "Payment"
    // For "Service Type" -> "Service"
    // For "Appointment Type" -> "Appt."

    if (title.contains('Date')) return 'Date';
    if (title.contains('Payment')) return 'Payment';
    if (title.contains('Service')) return 'Service';
    if (title.contains('Appointment')) return 'Appt';

    return parts[0];
  }
}
