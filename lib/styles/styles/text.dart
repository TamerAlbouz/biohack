import 'package:flutter/material.dart';

import '../colors.dart';
import '../font.dart';

const kButtonHint = TextStyle(
  fontFamily: Font.family,
  color: MyColors.grey,
  fontSize: Font.small,
  fontWeight: FontWeight.normal,
);

const kButtonText = TextStyle(
  fontFamily: Font.family,
  fontSize: Font.medium,
  fontWeight: FontWeight.bold,
);

const kTextFieldDropdown = TextStyle(
  fontFamily: Font.family,
  color: MyColors.textWhite,
  fontSize: Font.mediumSmall,
  fontWeight: FontWeight.normal,
);

const kErrorText = TextStyle(
  fontFamily: Font.family,
  color: MyColors.errorRed,
  fontSize: Font.small,
);

const kDropdownText = TextStyle(
  fontFamily: Font.family,
  color: MyColors.blue,
  fontSize: Font.medium,
  fontWeight: FontWeight.bold,
);

const kTimeslotText = TextStyle(
  fontFamily: Font.family,
  color: MyColors.textWhite,
  fontSize: Font.extraSmall,
  fontWeight: FontWeight.normal,
);

const kAppBarText = TextStyle(
  fontFamily: Font.family,
  color: MyColors.textBlack,
  fontSize: Font.medium,
  fontWeight: FontWeight.bold,
);

const kAppointmentSetupSectionTitle = TextStyle(
  fontFamily: Font.family,
  color: MyColors.textBlack,
  fontSize: Font.mediumSmall,
  fontWeight: FontWeight.bold,
);

const kAppointmentSetupCalendarDate = TextStyle(
  fontFamily: Font.family,
  color: MyColors.textBlack,
  fontSize: Font.mediumSmall,
  fontWeight: FontWeight.normal,
);

const kServiceCardText = TextStyle(
  fontFamily: Font.family,
  color: MyColors.textGrey,
  fontSize: Font.small,
  fontWeight: FontWeight.normal,
);

const kServiceCardSummary = TextStyle(
  fontFamily: Font.family,
  color: MyColors.textBlack,
  fontSize: Font.small,
  fontWeight: FontWeight.normal,
);

const kServiceDetailText = TextStyle(
  fontSize: Font.extraSmall,
  // Slightly smaller than the main text
  color: MyColors.textGrey,
  // Using a predefined grey color from your color palette
  fontWeight: FontWeight.w400,
  // Regular weight
  letterSpacing: 0.5, // Slight letter spacing for readability
);
