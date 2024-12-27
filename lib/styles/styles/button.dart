import 'package:flutter/material.dart';
import 'package:medtalk/styles/colors.dart';
import 'package:medtalk/styles/font.dart';

import '../sizes.dart';

final kElevatedButtonCommonStyle = ElevatedButton.styleFrom(
  shape: RoundedRectangleBorder(borderRadius: kRadius10),
  backgroundColor: MyColors.primary,
  foregroundColor: MyColors.buttonText,
  textStyle: const TextStyle(
    fontFamily: Font.family,
    fontSize: Font.mediumExtra,
    fontWeight: FontWeight.bold,
  ),
  elevation: 0,
  minimumSize: const Size(double.infinity, 50),
  alignment: Alignment.center,
);

final kElevatedButtonAddCardStyle = ElevatedButton.styleFrom(
  shape: RoundedRectangleBorder(borderRadius: kRadius10),
  backgroundColor: MyColors.selectionAddCard,
  foregroundColor: MyColors.textBlack,
  disabledBackgroundColor: MyColors.selectionAddCard,
  disabledForegroundColor: MyColors.textBlack,
  textStyle: const TextStyle(
    fontFamily: Font.family,
    fontSize: Font.small,
    color: MyColors.textBlack,
    fontWeight: FontWeight.normal,
  ),
  elevation: 0,
  minimumSize: const Size(double.infinity, 50),
);
