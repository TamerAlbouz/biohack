import 'package:flutter/material.dart';

import '../../styles/colors.dart';

class CustomDivider extends StatelessWidget {
  final double height;
  final double width;
  final Color color;

  const CustomDivider({
    super.key,
    this.height = 16,
    this.width = 0,
    this.color = MyColors.lineDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(color: color, height: height, thickness: width);
  }
}
