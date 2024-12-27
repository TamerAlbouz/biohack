import 'package:flutter/material.dart';

import '../colors.dart';
import '../font.dart';
import '../sizes.dart';

final kTextFieldButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: MyColors.textField,
  foregroundColor: MyColors.textGrey,
  elevation: 0,
  padding: kPadd0,
  shape: RoundedRectangleBorder(
    borderRadius: kRadius10,
  ),
  minimumSize: const Size(double.infinity, 50),
  alignment: Alignment.centerLeft,
  textStyle: const TextStyle(
    fontFamily: Font.family,
    fontSize: Font.mediumSmall,
    fontWeight: FontWeight.bold,
  ),
);
