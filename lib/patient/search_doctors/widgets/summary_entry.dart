import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medtalk/common/widgets/scrolling_text.dart';
import 'package:medtalk/styles/colors.dart';

import '../../../styles/sizes.dart';
import '../../../styles/styles/text.dart';

class SummaryEntry extends StatelessWidget {
  final FaIcon icon;
  final String title;
  final String value;

  const SummaryEntry(
      {super.key,
      required this.title,
      required this.value,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 20,
          child: icon,
        ),
        kGap10,
        Text(
          title,
          style: kServiceCardText,
        ),
        const Spacer(),
        ScrollingText(
          text: value,
          width: 150,
          fadeWidth: 10,
          backgroundColor: MyColors.cardBackground,
          minCharactersToScroll: 20,
          textAlign: TextAlign.end,
          style: kServiceCardSummary,
        ),
      ],
    );
  }
}
