import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../styles/colors.dart';
import '../../styles/font.dart';
import '../../styles/sizes.dart';

class Toggle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool isEnabled;
  final ValueChanged<bool> onChanged;

  const Toggle({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.isEnabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isEnabled
                  ? MyColors.primary.withValues(alpha: 0.1)
                  : MyColors.grey.withValues(alpha: 0.1),
              borderRadius: kRadiusAll,
            ),
            alignment: Alignment.center,
            child: FaIcon(
              icon!,
              size: 16,
              color: isEnabled ? MyColors.primary : MyColors.grey,
            ),
          ),
          kGap10,
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: Font.small,
                  color: isEnabled ? MyColors.textBlack : MyColors.textGrey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: Font.extraSmall,
                    color: isEnabled ? MyColors.textGrey : MyColors.grey,
                  ),
                ),
            ],
          ),
        ),
        Switch(
          value: isEnabled,
          onChanged: onChanged,
          activeColor: MyColors.primary,
        ),
      ],
    );
  }
}
