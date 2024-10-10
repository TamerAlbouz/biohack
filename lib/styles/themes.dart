import 'package:flutter/material.dart';
import 'package:medtalk/styles/colors.dart';
import 'package:medtalk/styles/font.dart';
import 'package:medtalk/styles/sizes.dart';

ThemeData get darkTheme {
  return ThemeData(
    fontFamily: Font.family,
    fontFamilyFallback: const [Font.family],
    scaffoldBackgroundColor: MyColors.background,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: MyColors.buttonPurple,
        foregroundColor: MyColors.textWhite,
        shape: RoundedRectangleBorder(
          borderRadius: kRadius10,
        ),
      ),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: MyColors.buttonPurple,
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: kRadius10,
        side: const BorderSide(
          color: MyColors.buttonStroke,
        ),
      ),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: Font.largest,
        color: MyColors.textWhite,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        fontSize: Font.large,
        color: MyColors.textWhite,
        fontWeight: FontWeight.bold,
      ),
      titleSmall: TextStyle(
        fontSize: Font.mediumLarge,
        color: MyColors.textWhite,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: TextStyle(
        fontSize: Font.sectionTitleSize,
        color: MyColors.textWhite,
      ),
      labelLarge: TextStyle(
        fontSize: Font.medium,
        color: MyColors.textWhite,
      ),
      labelMedium: TextStyle(
        fontSize: Font.mediumSmall,
        color: MyColors.textWhite,
      ),
      labelSmall: TextStyle(
        fontSize: Font.cardSubTitleSize,
        color: MyColors.textWhite,
      ),
    ),
    cardTheme: const CardTheme(
      color: MyColors.card,
    ),
    tabBarTheme: const TabBarTheme(
      labelColor: MyColors.textWhite,
      labelStyle: TextStyle(
        fontSize: Font.medium,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: Font.medium,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelColor: MyColors.textWhite,
      dividerHeight: 0,
      indicatorColor: MyColors.buttonPurple,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: MyColors.textWhite,
    ),
  );
}
