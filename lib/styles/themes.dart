import 'package:flutter/material.dart';
import 'package:medtalk/styles/colors.dart';
import 'package:medtalk/styles/font.dart';
import 'package:medtalk/styles/sizes.dart';

ThemeData get lightTheme {
  return ThemeData(
    fontFamily: Font.family,
    fontFamilyFallback: const [Font.family],
    scaffoldBackgroundColor: MyColors.background,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: MyColors.blue,
        foregroundColor: MyColors.buttonText,
        shape: RoundedRectangleBorder(
          borderRadius: kRadius10,
        ),
      ),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: MyColors.blue,
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: kRadius10,
        side: const BorderSide(
          color: MyColors.buttonStroke,
        ),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: MyColors.background,
      elevation: 0,
      toolbarHeight: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: MyColors.textBlack),
      titleTextStyle: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.large,
        color: MyColors.textBlack,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.large,
        color: MyColors.textBlack,
      ),
      bodyMedium: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.medium,
        color: MyColors.textBlack,
      ),
      bodySmall: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.mediumSmall,
        color: MyColors.textBlack,
      ),
      displayLarge: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.largest,
        color: MyColors.textBlack,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.large,
        color: MyColors.textBlack,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.mediumLarge,
        color: MyColors.textBlack,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.sectionTitleSize,
        color: MyColors.textBlack,
      ),
      headlineSmall: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.medium,
        color: MyColors.textBlack,
      ),
      titleLarge: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.largest,
        color: MyColors.textBlack,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.large,
        color: MyColors.textBlack,
        fontWeight: FontWeight.bold,
      ),
      titleSmall: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.mediumLarge,
        color: MyColors.textBlack,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.sectionTitleSize,
        color: MyColors.textBlack,
      ),
      labelLarge: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.medium,
        color: MyColors.textBlack,
      ),
      labelMedium: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.mediumSmall,
        color: MyColors.textBlack,
      ),
      labelSmall: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.cardSubTitleSize,
        color: MyColors.textBlack,
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
    cardTheme: const CardTheme(
      color: MyColors.cardBackground,
    ),
    tabBarTheme: const TabBarTheme(
      labelColor: MyColors.textBlack,
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
      indicatorColor: MyColors.blue,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: MyColors.textBlack,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
      enableFeedback: true,
      backgroundColor: Colors.transparent,
      showUnselectedLabels: false,
      unselectedIconTheme: IconThemeData(color: Colors.white),
      selectedIconTheme: IconThemeData(color: Colors.white),
      elevation: 0,
      selectedItemColor: MyColors.textWhite,
      showSelectedLabels: true,
      selectedLabelStyle: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.extraSmall,
        color: MyColors.textWhite,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.medium,
        fontWeight: FontWeight.normal,
      ),
    ),
    datePickerTheme: datePickerTheme,
  );
}

// card text theme
ThemeData get cardTextTheme {
  return ThemeData(
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.large,
        color: MyColors.black,
      ),
      bodyMedium: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.medium,
        color: MyColors.black,
      ),
      bodySmall: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.mediumSmall,
        color: MyColors.black,
      ),
      displayLarge: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.largest,
        color: MyColors.black,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.large,
        color: MyColors.black,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.mediumLarge,
        color: MyColors.black,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.sectionTitleSize,
        color: MyColors.black,
      ),
      headlineSmall: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.medium,
        color: MyColors.black,
      ),
      titleLarge: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.largest,
        color: MyColors.black,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.large,
        color: MyColors.black,
        fontWeight: FontWeight.bold,
      ),
      titleSmall: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.mediumLarge,
        color: MyColors.black,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.sectionTitleSize,
        color: MyColors.black,
      ),
      labelLarge: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.medium,
        color: MyColors.black,
      ),
      labelMedium: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.mediumSmall,
        color: MyColors.black,
      ),
      labelSmall: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.cardSubTitleSize,
        color: MyColors.black,
      ),
    ),
  );
}

// Date picker theme
DatePickerThemeData get datePickerTheme {
  return DatePickerThemeData(
    backgroundColor: MyColors.textField,
    cancelButtonStyle: const ButtonStyle(
      foregroundColor: WidgetStatePropertyAll(MyColors.lightBlue),
      textStyle: WidgetStatePropertyAll(TextStyle(
        fontFamily: Font.family,
        fontSize: Font.medium,
        color: MyColors.blue,
      )),
    ),
    confirmButtonStyle: const ButtonStyle(
      foregroundColor: WidgetStatePropertyAll(MyColors.lightBlue),
      textStyle: WidgetStatePropertyAll(TextStyle(
        fontFamily: Font.family,
        fontSize: Font.medium,
        color: MyColors.blue,
      )),
    ),
    dividerColor: MyColors.lineDivider,
    headerForegroundColor: MyColors.textBlack,
    headerHeadlineStyle: const TextStyle(
      fontFamily: Font.family,
      fontSize: Font.large,
      color: MyColors.textBlack,
    ),
    headerHelpStyle: const TextStyle(
      fontFamily: Font.family,
      fontSize: Font.medium,
      color: MyColors.textBlack,
    ),
    dayStyle: const TextStyle(
      fontFamily: Font.family,
      fontSize: Font.medium,
      color: MyColors.textBlack,
    ),
    yearStyle: const TextStyle(
      fontFamily: Font.family,
      fontSize: Font.medium,
      color: MyColors.grey,
    ),
    weekdayStyle: const TextStyle(
      fontFamily: Font.family,
      fontSize: Font.mediumLarge,
      color: MyColors.textBlack,
      fontWeight: FontWeight.bold,
    ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: const TextStyle(
        fontFamily: Font.family,
        fontSize: Font.medium,
        color: MyColors.grey,
        fontWeight: FontWeight.normal,
      ),
      activeIndicatorBorder: const BorderSide(
        color: MyColors.lightBlue,
        width: 2,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: MyColors.lightBlue,
          width: 2,
        ),
        borderRadius: kRadius10,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: MyColors.lightBlue,
          width: 2,
        ),
        borderRadius: kRadius10,
      ),
      errorStyle: const TextStyle(
        fontFamily: Font.family,
        fontSize: Font.medium,
        color: MyColors.errorRed,
      ),
      helperStyle: const TextStyle(
        fontFamily: Font.family,
        fontSize: Font.medium,
        color: MyColors.grey,
      ),
      labelStyle: const TextStyle(
        fontFamily: Font.family,
        fontSize: Font.mediumLarge,
        color: MyColors.lightBlue,
      ),
      // inner value style
      errorMaxLines: 2,
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: MyColors.errorRed,
          width: 2,
        ),
        borderRadius: kRadius10,
      ),
    ),
  );
}
