import 'package:flutter/material.dart';

import '../../../styles/colors.dart';

class CardDivider extends StatelessWidget {
  final double height;
  final double thickness;
  final Color color;
  final double padding;

  const CardDivider({
    super.key,
    this.height = 32,
    this.thickness = 1.5,
    this.color = MyColors.cardDivider,
    this.padding = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: color,
      height: height,
      thickness: thickness,
      indent: padding,
      endIndent: padding,
    );
  }
}
