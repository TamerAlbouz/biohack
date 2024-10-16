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
        backgroundColor: MyColors.purple,
        foregroundColor: MyColors.textWhite,
        shape: RoundedRectangleBorder(
          borderRadius: kRadius10,
        ),
      ),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: MyColors.purple,
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
        fontFamily: Font.family,
        fontSize: Font.largest,
        color: MyColors.textWhite,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.large,
        color: MyColors.textWhite,
        fontWeight: FontWeight.bold,
      ),
      titleSmall: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.mediumLarge,
        color: MyColors.textWhite,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.sectionTitleSize,
        color: MyColors.textWhite,
      ),
      labelLarge: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.medium,
        color: MyColors.textWhite,
      ),
      labelMedium: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.mediumSmall,
        color: MyColors.textWhite,
      ),
      labelSmall: TextStyle(
        fontFamily: Font.family,
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
        fontFamily: Font.family,
        fontSize: Font.medium,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.medium,
        fontWeight: FontWeight.normal,
      ),
      unselectedLabelColor: MyColors.grey,
      dividerHeight: 0,
      indicatorColor: MyColors.purple,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: MyColors.textWhite,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
      enableFeedback: true,
      backgroundColor: Colors.transparent,
      showUnselectedLabels: false,
      unselectedIconTheme: IconThemeData(color: Colors.white54),
      selectedIconTheme: IconThemeData(color: Colors.white),
      elevation: 0,
      showSelectedLabels: false,
      selectedLabelStyle: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.medium,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.medium,
        fontWeight: FontWeight.normal,
      ),
    ),
  );
}
