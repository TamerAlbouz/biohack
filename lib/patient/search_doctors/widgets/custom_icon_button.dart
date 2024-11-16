import 'package:flutter/material.dart';

import '../../../styles/colors.dart';
import '../../../styles/sizes.dart';

class CustomIconButton extends StatelessWidget {
  // make this accept Icon or FaIcon
  final Widget icon;
  final Function onPressed;
  final bool? disabled;

  const CustomIconButton(
      {super.key, required this.icon, required this.onPressed, this.disabled});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled == true ? null : onPressed as void Function()?,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: kRadiusAll,
          border: Border.all(
            color: disabled == true ? MyColors.grey : MyColors.blue,
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        width: 35,
        height: 35,
        padding: kPadd0,
        alignment: Alignment.center,
        child: icon,
      ),
    );
  }
}
