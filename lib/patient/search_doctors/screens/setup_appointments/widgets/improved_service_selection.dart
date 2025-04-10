import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../styles/colors.dart';
import '../../../../../styles/font.dart';
import '../../../../../styles/sizes.dart';
import '../../../models/selection_item.dart';

class ImprovedServiceSelection extends StatelessWidget {
  final List<SelectionItem> services;
  final int? selectedIndex;
  final Function(SelectionItem, int) onSelected;

  const ImprovedServiceSelection({
    super.key,
    required this.services,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: services.length,
          separatorBuilder: (context, index) => kGap12,
          itemBuilder: (context, index) {
            final service = services[index];
            final isSelected = selectedIndex == index;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected
                    ? MyColors.primary.withValues(alpha: 0.05)
                    : MyColors.cardBackground,
                borderRadius: kRadius16,
                border: Border.all(
                  color: isSelected ? MyColors.primary : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: MyColors.primary.withValues(alpha: 0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: InkWell(
                onTap: () => onSelected(service, index),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: kPadd20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Service title and duration
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service.title,
                                  style: TextStyle(
                                    fontSize: Font.mediumSmall,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? MyColors.primary
                                        : MyColors.textBlack,
                                  ),
                                ),
                                kGap4,
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? MyColors.primary
                                                .withValues(alpha: 0.1)
                                            : MyColors.grey
                                                .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          FaIcon(
                                            FontAwesomeIcons.clock,
                                            size: 12,
                                            color: isSelected
                                                ? MyColors.primary
                                                : MyColors.textGrey,
                                          ),
                                          kGap4,
                                          Text(
                                            service.subtitle,
                                            style: TextStyle(
                                              fontSize: Font.extraSmall,
                                              fontWeight: FontWeight.w500,
                                              color: isSelected
                                                  ? MyColors.primary
                                                  : MyColors.textGrey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                kGap8,
                                Row(
                                  children: [
                                    if (service.hasInPerson)
                                      _buildServiceTypeTag(
                                        'In-person',
                                        FontAwesomeIcons.hospitalUser,
                                        isSelected,
                                      ),
                                    if (service.hasOnline)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 4),
                                        child: _buildServiceTypeTag(
                                          'Online',
                                          FontAwesomeIcons.video,
                                          isSelected,
                                        ),
                                      ),
                                    if (service.hasHomeVisit)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 4),
                                        child: _buildServiceTypeTag(
                                          'Home',
                                          FontAwesomeIcons.house,
                                          isSelected,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Price
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? MyColors.primary
                                  : MyColors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '\$${service.price}',
                              style: TextStyle(
                                fontSize: Font.small,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : MyColors.textGrey,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Service description
                      if (service.description != null &&
                          service.description!.isNotEmpty) ...[
                        kGap12,
                        Text(
                          service.description!,
                          style: TextStyle(
                            fontSize: Font.small,
                            color: isSelected
                                ? MyColors.primary
                                : MyColors.textGrey,
                          ),
                          maxLines: isSelected ? 10 : 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      // Selected indicator
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildServiceTypeTag(String text, IconData icon, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? MyColors.primary.withValues(alpha: 0.1)
            : MyColors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(
            icon,
            size: 12,
            color: isSelected ? MyColors.primary : MyColors.textGrey,
          ),
          kGap4,
          Text(
            text,
            style: TextStyle(
              fontSize: Font.extraSmall,
              fontWeight: FontWeight.w500,
              color: isSelected ? MyColors.primary : MyColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }
}
