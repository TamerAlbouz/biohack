import 'package:flutter/material.dart';

import '../../../styles/colors.dart';
import '../../../styles/sizes.dart';

class CustomBase extends StatelessWidget {
  final Widget? child;
  final bool shadow;
  final bool roundCorners;
  final int? fixedHeight;
  final int? fixedWidth;

  const CustomBase(
      {super.key,
      this.child,
      this.shadow = true,
      this.fixedWidth,
      this.fixedHeight,
      this.roundCorners = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: kPaddH20V15,
      width: fixedWidth?.toDouble() ?? double.infinity,
      height: fixedHeight?.toDouble(),
      decoration: BoxDecoration(
        color: MyColors.cardBackground,
        borderRadius: roundCorners ? kRadius20 : BorderRadius.zero,
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  offset: const Offset(0, 8),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}
