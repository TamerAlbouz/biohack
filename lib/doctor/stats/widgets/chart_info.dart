import 'package:flutter/material.dart';
import 'package:medtalk/common/widgets/base/custom_base.dart';
import 'package:medtalk/styles/font.dart';
import 'package:medtalk/styles/sizes.dart';

import '../../../styles/styles/text.dart';

/// A widget that wraps charts in a consistent card style.
///
/// This widget provides a standardized way to display charts with a title
/// and consistent padding throughout the statistics screens.
class ChartCard extends StatelessWidget {
  /// The title to show above the chart.
  final String title;

  /// The chart widget to display in the card.
  final Widget chart;

  /// The height of the chart area.
  final double? height;

  /// Optional subtitle to display below the title.
  final String? subtitle;

  const ChartCard({
    super.key,
    required this.title,
    required this.chart,
    this.height,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: kSectionTitle),
        if (subtitle != null) ...[
          Text(
            subtitle!,
            style: const TextStyle(
              fontSize: Font.small,
              color: Colors.grey,
            ),
          ),
        ],
        kGap10,
        CustomBase(
          shadow: false,
          child: SizedBox(
            height: height,
            child: chart,
          ),
        ),
      ],
    );
  }
}
