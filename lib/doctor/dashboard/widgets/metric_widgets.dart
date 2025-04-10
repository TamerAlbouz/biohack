import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medtalk/common/widgets/base/custom_base.dart';
import 'package:medtalk/styles/font.dart';
import 'package:medtalk/styles/sizes.dart';

/// A widget that displays a metric in a card format.
///
/// This widget displays a metric with a title, value, optional subtitle, and an icon.
/// It's used on the dashboard to show key metrics in a visually appealing way.
class MetricCard extends StatelessWidget {
  /// The title of the metric.
  final String title;

  /// The value of the metric to display.
  final String value;

  /// An optional subtitle to display below the value.
  final String? subtitle;

  /// The icon to display in the card.
  final IconData icon;

  /// The color to use for the icon and accent.
  final Color color;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomBase(
      fixedHeight: 130,
      shadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: kPadd6,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FaIcon(
                  icon,
                  color: color,
                  size: 16,
                ),
              ),
              kGap6,
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: Font.small,
                    color: Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          kGap10,
          Text(
            value,
            style: const TextStyle(
              fontSize: Font.large,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: Font.extraSmall,
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
