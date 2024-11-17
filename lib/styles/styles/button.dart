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

final kElevatedButtonBookAppointmentStyle = ElevatedButton.styleFrom(
  shape: RoundedRectangleBorder(borderRadius: kRadius12),
  backgroundColor: MyColors.blue,
  foregroundColor: MyColors.buttonText,
  textStyle: const TextStyle(
    fontFamily: Font.family,
    fontSize: Font.mediumSmall,
    fontWeight: FontWeight.bold,
  ),
  elevation: 0,
  minimumSize: const Size(double.infinity, 50),
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
