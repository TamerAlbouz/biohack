import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medtalk/common/widgets/base/custom_base.dart';
import 'package:medtalk/styles/font.dart';
import 'package:medtalk/styles/sizes.dart';

/// A widget that displays a statistic with trend information in a card format.
///
/// This widget shows a metric with a title, value, and trend indicator
/// showing whether the metric has increased or decreased compared to a previous period.
class StatInfoCard extends StatelessWidget {
  /// The title of the statistic.
  final String title;

  /// The value of the statistic to display.
  final String value;

  /// The icon to display in the card.
  final IconData icon;

  /// The color to use for the icon.
  final Color iconColor;

  /// The percentage change compared to the previous period.
  final double change;

  /// Whether an increase in this metric is considered positive.
  /// For metrics like revenue, an increase is positive, but for metrics
  /// like cancellation rate, an increase would be negative.
  final bool isIncreasePositive;

  const StatInfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.change,
    this.isIncreasePositive = true,
  });

  @override
  Widget build(BuildContext context) {
    // Determine if the change is positive based on the direction
    final isPositive = (change >= 0 && isIncreasePositive) ||
        (change < 0 && !isIncreasePositive);

    // Determine display color based on whether change is positive
    final changeColor = isPositive ? Colors.green : Colors.red;

    // Format the change for display
    final formattedChange = change.abs().toStringAsFixed(1);

    return CustomBase(
      shadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: kPadd6,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FaIcon(
                  icon,
                  color: iconColor,
                  size: 16,
                ),
              ),
              kGap6,
              Text(
                title,
                style: const TextStyle(
                  fontSize: Font.small,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          kGap10,
          Text(
            value,
            style: const TextStyle(
              fontSize: Font.medium,
              fontWeight: FontWeight.bold,
            ),
          ),
          kGap6,
          Row(
            children: [
              Icon(
                change >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                color: changeColor,
                size: 14,
              ),
              kGap2,
              Text(
                '$formattedChange%',
                style: TextStyle(
                  fontSize: Font.extraSmall,
                  color: changeColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              kGap4,
              Text(
                'vs. previous',
                style: TextStyle(
                  fontSize: Font.extraSmall,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
