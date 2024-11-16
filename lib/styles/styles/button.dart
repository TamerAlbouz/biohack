import 'package:flutter/material.dart';
import 'package:medtalk/styles/colors.dart';
import 'package:medtalk/styles/font.dart';

import '../sizes.dart';

final kElevatedButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: MyColors.blue,
  foregroundColor: MyColors.buttonText,
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: kRadius10,
  ),
  minimumSize: const Size(double.infinity, 50),
  textStyle: const TextStyle(
    fontFamily: Font.family,
    fontSize: Font.mediumSmall,
    fontWeight: FontWeight.bold,
  ),
);
