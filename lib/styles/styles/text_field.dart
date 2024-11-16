import 'package:flutter/material.dart';

import '../colors.dart';
import '../font.dart';
import '../sizes.dart';

final kTextFieldButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: MyColors.textGrey,
  foregroundColor: MyColors.textGrey,
  elevation: 0,
  padding: kPaddH20,
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
