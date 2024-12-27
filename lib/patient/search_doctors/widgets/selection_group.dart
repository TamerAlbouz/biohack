import 'package:flutter/material.dart';
import 'package:medtalk/styles/font.dart';
import 'package:medtalk/styles/sizes.dart';

import '../../../styles/colors.dart';
import '../models/selection_item.dart';

class SelectionGroup extends StatefulWidget {
  final List<SelectionItem> items;
  final bool? disabled;
  final int? selectedIndex;
  final Function(SelectionItem, int) onSelected;

  const SelectionGroup({
    super.key,
    required this.items,
    this.selectedIndex,
    this.disabled,
    required this.onSelected,
  });

  @override
  State<SelectionGroup> createState() => _SelectionGroupState();
}

class _SelectionGroupState extends State<SelectionGroup> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: widget.items.length,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => kGap8,
      itemBuilder: (context, index) {
        final item = widget.items[index];
        return AbsorbPointer(
          absorbing: widget.disabled ?? false,
          child: Opacity(
            opacity: (widget.disabled ?? false) ? 0.5 : 1.0,
            child: _SelectionCard(
              title: item.title,
              subtitle: item.subtitle,
              price: item.price,
              isSelected:
                  selectedIndex == index || widget.selectedIndex == index,
              onTap: () {
                setState(() {
                  selectedIndex = index;
                });
                widget.onSelected.call(item, index);
              },
            ),
          ),
        );
      },
    );
  }
}

class _SelectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double? price;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectionCard({
    required this.title,
    required this.subtitle,
    this.price,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: kRadius12,
        child: Ink(
          padding: kPadd10,
          decoration: BoxDecoration(
            color: isSelected ? MyColors.primary : MyColors.selectionCardEmpty,
            borderRadius: kRadius12,
            border: Border.all(
              color:
                  isSelected ? MyColors.primary : MyColors.selectionCardStroke,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Radio<bool>(
                      value: true,
                      // hide the radio button
                      groupValue: isSelected ? true : false,
                      onChanged: (_) => onTap(),
                      fillColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                          return isSelected ? MyColors.white : MyColors.primary;
                        },
                      ),
                    ),
                    kGap8,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: Font.small,
                              fontWeight: FontWeight.w500,
                              color:
                                  isSelected ? MyColors.white : MyColors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: Font.extraSmall,
                              color: isSelected
                                  ? Colors.white70
                                  : MyColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (price != null)
                Padding(
                  padding: kPaddR8,
                  child: Text(
                    '\$${price?.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: Font.mediumSmall,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
