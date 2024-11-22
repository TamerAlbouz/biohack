import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medtalk/patient/search_doctors/models/service_detail.dart';

import '../../../styles/colors.dart';
import '../../../styles/sizes.dart';
import '../../../styles/styles/text.dart';

class Services extends StatefulWidget {
  const Services({super.key});

  @override
  State<Services> createState() => _ServicesState();
}

class _ServicesState extends State<Services> {
  // Track which service is expanded
  int? _expandedIndex;

  // Service details data structure
  final List<ServiceDetail> _services = [
    const ServiceDetail(
      name: 'Haircut',
      price: 100,
      duration: '45 mins',
      availability: 'In-Person & Online',
      summary:
          'Professional styling tailored to your unique look and preferences.',
      icon: FontAwesomeIcons.cut,
    ),
    const ServiceDetail(
      name: 'Color Treatment',
      price: 150,
      duration: '90 mins',
      availability: 'In-Person Only',
      summary:
          'Expert coloring using premium, hair-friendly products for vibrant, long-lasting results.',
      icon: FontAwesomeIcons.palette,
    ),
    const ServiceDetail(
      name: 'Consultation',
      price: 50,
      duration: '30 mins',
      availability: 'In-Person & Online',
      summary:
          'Personalized hair care advice and styling recommendations from our expert stylists.',
      icon: FontAwesomeIcons.comments,
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
        kGap14,
        ListView.separated(
          shrinkWrap: true,
          itemCount: _services.length,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) => kGap12,
          itemBuilder: (context, index) {
            final service = _services[index];
            final isExpanded = _expandedIndex == index;

            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                setState(() {
                  if (_expandedIndex == index) {
                    _expandedIndex = null;
                  } else {
                    _expandedIndex = index;
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                constraints: BoxConstraints(
                  minHeight: 30,
                  maxHeight: isExpanded ? 210 : 30,
                ),
                curve: Curves.easeInOut,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.check,
                            color: MyColors.green,
                            size: 20,
                          ),
                          kGap10,
                          Text(service.name, style: kServiceCardText),
                          const Spacer(),
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: isExpanded ? 0 : 1,
                            child: Text(
                              '\$${service.price}',
                              style: kServiceCardText.copyWith(
                                  color: MyColors.textBlack),
                            ),
                          ),
                          kGap10,
                          FaIcon(
                            isExpanded
                                ? FontAwesomeIcons.chevronDown
                                : FontAwesomeIcons.chevronRight,
                            color: MyColors.black,
                            size: 18,
                          ),
                        ],
                      ),
                    ),

                    // Expanded Details with Fade-in Animation
                    if (isExpanded)
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: isExpanded ? 1.0 : 0.0,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  FaIcon(service.icon,
                                      size: 16, color: MyColors.textGrey),
                                  kGap8,
                                  Expanded(
                                    child: Text(
                                      service.summary,
                                      style: kServiceDetailText,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              kGap14,
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      const FaIcon(FontAwesomeIcons.clock,
                                          size: 16, color: MyColors.textGrey),
                                      kGap8,
                                      Text(service.duration,
                                          style: kServiceDetailText),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      FaIcon(
                                          service.availability
                                                  .contains('Online')
                                              ? FontAwesomeIcons.video
                                              : FontAwesomeIcons.mapPin,
                                          size: 16,
                                          color: MyColors.textGrey),
                                      kGap8,
                                      Text(service.availability,
                                          style: kServiceDetailText),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      const FaIcon(FontAwesomeIcons.moneyBill,
                                          size: 16, color: MyColors.textGrey),
                                      kGap8,
                                      Text('\$${service.price}',
                                          style: kServiceDetailText),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
