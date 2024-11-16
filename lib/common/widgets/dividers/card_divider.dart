import 'package:flutter/material.dart';

import '../../../styles/colors.dart';

class CardDivider extends StatelessWidget {
  final double height;
  final double width;
  final Color color;

  const CardDivider({
    super.key,
    this.height = 32,
    this.width = 1.5,
    this.color = MyColors.cardDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(color: color, height: height, thickness: width);
  }
}
