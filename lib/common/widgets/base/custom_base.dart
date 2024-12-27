import 'package:flutter/material.dart';

import '../../../styles/colors.dart';
import '../../../styles/sizes.dart';

class CustomBase extends StatelessWidget {
  final Widget child;
  final bool shadow;

  const CustomBase({super.key, required this.child, this.shadow = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: kPaddH20V15,
      width: double.infinity,
      decoration: BoxDecoration(
        color: MyColors.cardBackground,
        borderRadius: kRadius20,
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
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
