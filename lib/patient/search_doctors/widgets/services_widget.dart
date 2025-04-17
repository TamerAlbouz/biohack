import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medtalk/patient/search_doctors/bloc/setup_appointment_bloc.dart';

import '../../../common/widgets/dropdown/custom_expansion_list_radio.dart';
import '../../../styles/colors.dart';
import '../../../styles/font.dart';
import '../../../styles/sizes.dart';
import '../../../styles/styles/text.dart';

class Services extends StatelessWidget {
  final String doctorId;

  const Services({super.key, required this.doctorId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SetupAppointmentBloc, SetupAppointmentState>(
      builder: (context, state) {
        // Show loading if services are being fetched
        if (state.doctorServices.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Services',
                style: kSectionTitle,
              ),
              kGap14,
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: MyColors.blueGrey.withValues(alpha: 0.1),
                  borderRadius: kRadius10,
                ),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Services',
              style: kSectionTitle,
            ),
            kGap4,
            CustomExpansionPanelList.radio(
              elevation: 0,
              materialGapSize: 16,
              dividerColor: Colors.transparent,
              expandedHeaderPadding: kPadd0,
              initialOpenPanelValue: 0,
              children: state.doctorServices.asMap().entries.map((entry) {
                final index = entry.key;
                final service = entry.value;

                // Format duration text
                String durationText = '';
                if (service.duration < 60) {
                  durationText = '${service.duration} mins';
                } else if (service.duration == 60) {
                  durationText = '1 hour';
                } else {
                  final hours = service.duration ~/ 60;
                  final minutes = service.duration % 60;
                  if (minutes == 0) {
                    durationText = '$hours hrs';
                  } else {
                    durationText = '$hours hr $minutes mins';
                  }
                }

                // Build appointment type tags
                List<Widget> appointmentTypeTags = [];
                if (service.isInPerson) {
                  appointmentTypeTags.add(
                    _buildAppointmentTypeTag(
                        FontAwesomeIcons.hospitalUser, 'In-Person'),
                  );
                }
                if (service.isOnline) {
                  if (appointmentTypeTags.isNotEmpty) {
                    appointmentTypeTags.add(kGap6);
                  }
                  appointmentTypeTags.add(
                    _buildAppointmentTypeTag(FontAwesomeIcons.video, 'Online'),
                  );
                }
                if (service.isHomeVisit) {
                  if (appointmentTypeTags.isNotEmpty) {
                    appointmentTypeTags.add(kGap6);
                  }
                  appointmentTypeTags.add(
                    _buildAppointmentTypeTag(
                        FontAwesomeIcons.house, 'Home Visit'),
                  );
                }

                return CustomExpansionPanelRadio(
                  backgroundColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  headerBuilder: (context, isExpanded) => Container(
                    padding: kPaddR8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const FaIcon(
                          FontAwesomeIcons.check,
                          color: MyColors.green,
                          size: 20,
                        ),
                        kGap8,
                        Text(
                          service.title,
                          style: kServiceTitle,
                        ),
                        const Spacer(),
                        Text(
                          '\$${service.price}',
                          style: kServiceTitle.copyWith(
                            color: MyColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  body: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Duration
                      Row(
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.clock,
                            size: 14,
                            color: MyColors.subtitleDark,
                          ),
                          kGap8,
                          Text(
                            durationText,
                            style: kServiceCardSummary,
                          ),
                        ],
                      ),
                      kGap10,

                      // Description
                      if (service.description!.isNotEmpty) ...[
                        Text(
                          service.description!,
                          style: kServiceCardSummary.copyWith(
                            color: MyColors.textGrey,
                          ),
                        ),
                        kGap10,
                      ],

                      // Appointment types
                      if (appointmentTypeTags.isNotEmpty) ...[
                        Row(children: appointmentTypeTags),
                        kGap10,
                      ],

                      // Pre-appointment instructions
                      if (service.preAppointmentInstructions?.isNotEmpty ??
                          false) ...[
                        Container(
                          padding: kPadd10,
                          decoration: BoxDecoration(
                            color: MyColors.blueGrey.withValues(alpha: 0.1),
                            borderRadius: kRadius10,
                            border: Border.all(
                                color: MyColors.primary.withValues(alpha: 0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.circleInfo,
                                    color: MyColors.primary,
                                    size: 14,
                                  ),
                                  kGap8,
                                  Text(
                                    'Pre-appointment Instructions',
                                    style: TextStyle(
                                      fontSize: Font.small,
                                      fontWeight: FontWeight.bold,
                                      color: MyColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              kGap6,
                              Text(
                                service.preAppointmentInstructions!,
                                style: kServiceCardSummary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  value: index,
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAppointmentTypeTag(IconData icon, String text) {
    return Container(
      padding: kPaddH6V2,
      decoration: BoxDecoration(
        color: MyColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MyColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(
            icon,
            size: 12,
            color: MyColors.primary,
          ),
          kGap4,
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: MyColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
