import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../styles/font.dart';

class BadgedTab extends StatelessWidget {
  final String text;
  final IconData? icon;
  final int badgeCount;
  final Color badgeColor;
  final EdgeInsetsGeometry? padding;

  const BadgedTab({
    super.key,
    required this.text,
    this.icon,
    this.badgeCount = 0,
    this.badgeColor = Colors.red,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Container(
        padding: padding,
        child: Row(
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
            if (badgeCount > 0) ...[
              const SizedBox(width: 4),
              Container(
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Center(
                  child: Text(
                    badgeCount > 99 ? '99+' : badgeCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
