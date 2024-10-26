import 'package:flutter/material.dart';

import '../../styles/colors.dart';
import '../../styles/font.dart';
import '../../styles/sizes.dart';

class Tag extends StatelessWidget {
  const Tag({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: kPaddH10V3,
      decoration: BoxDecoration(
        color: MyColors.green,
        borderRadius: kRadiusAll,
      ),
      child: const Text('Confirmed',
          style: TextStyle(
              fontSize: Font.extraSmall, fontWeight: FontWeight.bold)),
    );
  }
}
