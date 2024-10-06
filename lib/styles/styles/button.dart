import 'package:flutter/material.dart';
import 'package:medtalk/styles/colors.dart';
import 'package:medtalk/styles/font.dart';

import '../sizes.dart';

final kMainButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: MyColors.buttonPurple,
  foregroundColor: MyColors.textWhite,
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: kRadius10,
  ),
  minimumSize: const Size(double.infinity, 50),
  textStyle: const TextStyle(
    fontSize: Font.mediumSmall,
    fontWeight: FontWeight.bold,
  ),
);
