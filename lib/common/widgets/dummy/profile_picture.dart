import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../styles/sizes.dart';

class ProfilePicture extends StatelessWidget {
  final double width;
  final double height;

  const ProfilePicture({super.key, this.width = 60, this.height = 60});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: kRadiusAll,
      ),
      child: const Icon(
        FontAwesomeIcons.user,
        color: Colors.white,
      ),
    );
  }
}
