// Create a new widget for tabs with badges and icons
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../styles/font.dart';

class CustomTab extends StatelessWidget {
  final String text;
  final IconData? icon;

  const CustomTab({
    super.key,
    required this.text,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            FaIcon(icon, size: 16),
            const SizedBox(width: 6),
          ],
          Text(text,
              style: const TextStyle(
                fontSize: Font.mediumSmall,
              )),
        ],
      ),
    );
  }
}
