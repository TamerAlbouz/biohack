import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medtalk/patient/search_doctors/models/service_detail.dart';

import '../../../common/widgets/dropdown/custom_expansion_list_radio.dart';
import '../../../styles/colors.dart';
import '../../../styles/sizes.dart';
import '../../../styles/styles/text.dart';

class Services extends StatefulWidget {
  const Services({super.key});

  @override
  State<Services> createState() => _ServicesState();
}

class _ServicesState extends State<Services> {
  final List<ServiceDetail> _services = [
    const ServiceDetail(
      name: 'General Consultation',
      price: 100,
      duration: '45 mins',
      availability: 'In-Person &\nOnline',
      summary: 'General consultation for any health issues',
    ),
    const ServiceDetail(
      name: 'Dental Checkup',
      price: 150,
      duration: '1 hour',
      availability: 'In-Person',
      summary: 'Routine dental checkup and cleaning',
    ),
    const ServiceDetail(
      name: 'Vaccination',
      price: 50,
      duration: '30 mins',
      availability: 'In-Person',
      summary: 'Vaccination for children and adults',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Services',
          style: kAppointmentSetupSectionTitle,
        ),
        kGap4,
        // apply negative margin to remove the default padding
        CustomExpansionPanelList.radio(
          elevation: 0,
          materialGapSize: 16,
          dividerColor: Colors.transparent,
          expandedHeaderPadding: kPadd0,
          initialOpenPanelValue: 0,
          // This ensures first panel is open by default
          children: _services.asMap().entries.map((entry) {
            final index = entry.key;
            final service = entry.value;

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
                      service.name,
                      style: kServiceCardText.copyWith(),
                    ),
                    const Spacer(),
                    Text(
                      '\$${service.price}',
                      style: kServiceCardText.copyWith(
                        color: MyColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              body: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    service.summary,
                    style: kServiceCardSummary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              value: index,
            );
          }).toList(),
        ),
      ],
    );
  }
}
