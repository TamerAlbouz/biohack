import 'package:flutter/material.dart';

import '../../../styles/colors.dart';

class CardDivider extends StatelessWidget {
  final double height;
  final double thickness;
  final Color color;
  final double padding;
  final double? startIndent;
  final double? endIndent;

  const CardDivider({
    super.key,
    this.height = 32,
    this.thickness = 1.5,
    this.color = MyColors.cardDivider,
    this.padding = 0,
    this.startIndent,
    this.endIndent,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: color,
      height: height,
      thickness: thickness,
      indent: startIndent ?? padding,
      endIndent: endIndent ?? padding,
    );
  }
}
