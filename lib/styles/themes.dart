import 'package:flutter/material.dart';
import 'package:medtalk/styles/colors.dart';
import 'package:medtalk/styles/font.dart';
import 'package:medtalk/styles/sizes.dart';

ThemeData get lightTheme {
  return ThemeData(
    fontFamily: Font.family,
    fontFamilyFallback: const [Font.family],
    scaffoldBackgroundColor: MyColors.background,
    // This sets the color for all progress indicators including RefreshIndicator
    colorScheme: ColorScheme.fromSeed(
      seedColor: MyColors.primary,
      // This specifically controls RefreshIndicator color
      primary: MyColors.primary,
    ),
    // You can also set it directly here, though colorScheme is preferred in newer Flutter versions
    primaryColor: MyColors.primary,
    timePickerTheme: TimePickerThemeData(
      helpTextStyle: const TextStyle(
        fontSize: Font.medium,
        fontWeight: FontWeight.normal,
        color: MyColors.textBlack,
      ),
      backgroundColor: MyColors.cardBackground,
      hourMinuteShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      dayPeriodShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      dayPeriodColor: WidgetStateColor.resolveWith((states) =>
          states.contains(WidgetState.selected)
              ? MyColors.primary
              : Colors.transparent),
      dayPeriodTextColor: WidgetStateColor.resolveWith((states) =>
          states.contains(WidgetState.selected)
              ? Colors.white
              : MyColors.textBlack),
      hourMinuteColor: WidgetStateColor.resolveWith((states) =>
          states.contains(WidgetState.selected)
              ? MyColors.primary.withOpacity(0.2)
              : Colors.transparent),
      hourMinuteTextColor: WidgetStateColor.resolveWith((states) =>
          states.contains(WidgetState.selected)
              ? MyColors.primary
              : MyColors.textBlack),
      dialBackgroundColor: MyColors.cardBackground,
      dialHandColor: MyColors.primary,
      dialTextColor: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? Colors.white
            : MyColors.textBlack,
      ),
      entryModeIconColor: MyColors.primary,
    ),
    dialogTheme: const DialogTheme(
      backgroundColor: MyColors.cardBackground,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: MyColors.primary,
        foregroundColor: MyColors.buttonText,
        shape: RoundedRectangleBorder(
          borderRadius: kRadius10,
        ),
      ),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: MyColors.primary,
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
        fontSize: 18,
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
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: const TextStyle(
          fontFamily: Font.family,
          fontSize: Font.medium,
          fontWeight: FontWeight.normal,
          color: MyColors.primary,
        ),
        foregroundColor: MyColors.primary,
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
      indicatorColor: MyColors.primary,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: MyColors.textBlack,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
      enableFeedback: true,
      showUnselectedLabels: true,
      unselectedIconTheme: IconThemeData(color: MyColors.white),
      selectedIconTheme: IconThemeData(color: MyColors.white),
      elevation: 0,
      selectedItemColor: MyColors.white,
      unselectedItemColor: MyColors.white,
      showSelectedLabels: true,
      selectedLabelStyle: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.tiny,
        color: MyColors.white,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.tiny,
        color: MyColors.white,
        fontWeight: FontWeight.normal,
      ),
    ),
    datePickerTheme: datePickerTheme,
  );
}

// Dark theme implementation
ThemeData get darkTheme {
  return ThemeData(
    fontFamily: Font.family,
    fontFamilyFallback: const [Font.family],
    scaffoldBackgroundColor: const Color(0xFF121212),
    // Dark background
    // This sets the color for all progress indicators including RefreshIndicator
    colorScheme: ColorScheme.fromSeed(
      seedColor: MyColors.primary,
      brightness: Brightness.dark,
      primary: MyColors.primary,
      background: const Color(0xFF121212),
      surface: const Color(0xFF1E1E1E),
      onSurface: MyColors.white,
      onBackground: MyColors.white,
    ),
    // You can also set it directly here, though colorScheme is preferred in newer Flutter versions
    primaryColor: MyColors.primary,
    timePickerTheme: TimePickerThemeData(
      helpTextStyle: const TextStyle(
        fontSize: Font.medium,
        fontWeight: FontWeight.normal,
        color: MyColors.white,
      ),
      backgroundColor: const Color(0xFF1E1E1E),
      // Dark card background
      hourMinuteShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      dayPeriodShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      dayPeriodColor: WidgetStateColor.resolveWith((states) =>
          states.contains(WidgetState.selected)
              ? MyColors.primary
              : Colors.transparent),
      dayPeriodTextColor: WidgetStateColor.resolveWith((states) =>
          states.contains(WidgetState.selected)
              ? Colors.white
              : MyColors.white),
      hourMinuteColor: WidgetStateColor.resolveWith((states) =>
          states.contains(WidgetState.selected)
              ? MyColors.primary.withOpacity(0.2)
              : Colors.transparent),
      hourMinuteTextColor: WidgetStateColor.resolveWith((states) =>
          states.contains(WidgetState.selected)
              ? MyColors.primary
              : MyColors.white),
      dialBackgroundColor: const Color(0xFF1E1E1E),
      dialHandColor: MyColors.primary,
      dialTextColor: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? Colors.white
            : MyColors.white,
      ),
      entryModeIconColor: MyColors.primary,
    ),
    dialogTheme: const DialogTheme(
      backgroundColor: Color(0xFF1E1E1E),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: MyColors.primary,
        foregroundColor: MyColors.buttonText,
        shape: RoundedRectangleBorder(
          borderRadius: kRadius10,
        ),
      ),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: MyColors.primary,
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: kRadius10,
        side: const BorderSide(
          color: MyColors.buttonStroke,
        ),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF121212),
      elevation: 0,
      toolbarHeight: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: MyColors.white),
      titleTextStyle: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.large,
        color: MyColors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.large,
        color: MyColors.white,
      ),
      bodyMedium: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.medium,
        color: MyColors.white,
      ),
      bodySmall: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.mediumSmall,
        color: MyColors.white,
      ),
      displayLarge: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.largest,
        color: MyColors.white,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.large,
        color: MyColors.white,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.mediumLarge,
        color: MyColors.white,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.sectionTitleSize,
        color: MyColors.white,
      ),
      headlineSmall: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.medium,
        color: MyColors.white,
      ),
      titleLarge: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.largest,
        color: MyColors.white,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.large,
        color: MyColors.white,
        fontWeight: FontWeight.bold,
      ),
      titleSmall: TextStyle(
        fontFamily: Font.family,
        fontSize: 18,
        color: MyColors.white,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.sectionTitleSize,
        color: MyColors.white,
      ),
      labelLarge: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.medium,
        color: MyColors.white,
      ),
      labelMedium: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.mediumSmall,
        color: MyColors.white,
      ),
      labelSmall: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.cardSubTitleSize,
        color: MyColors.white,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: const TextStyle(
          fontFamily: Font.family,
          fontSize: Font.medium,
          fontWeight: FontWeight.normal,
          color: MyColors.primaryLight,
        ),
        foregroundColor: MyColors.primaryLight,
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
    cardTheme: const CardTheme(
      color: Color(0xFF1E1E1E), // Dark card background
    ),
    tabBarTheme: const TabBarTheme(
      labelColor: MyColors.white,
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
      unselectedLabelColor: Color(0xFFAAAAAA),
      // Lighter grey for dark mode
      dividerHeight: 0,
      indicatorColor: MyColors.primary,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: MyColors.white,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
      enableFeedback: true,
      showUnselectedLabels: true,
      backgroundColor: Color(0xFF151515),
      // Dark nav bar background
      unselectedIconTheme: IconThemeData(color: MyColors.grey),
      selectedIconTheme: IconThemeData(color: MyColors.white),
      elevation: 0,
      selectedItemColor: MyColors.white,
      unselectedItemColor: MyColors.grey,
      showSelectedLabels: true,
      selectedLabelStyle: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.tiny,
        color: MyColors.white,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.tiny,
        color: MyColors.grey,
        fontWeight: FontWeight.normal,
      ),
    ),
    datePickerTheme: darkDatePickerTheme,
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

// Dark card text theme
ThemeData get darkCardTextTheme {
  return ThemeData(
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.large,
        color: MyColors.white,
      ),
      bodyMedium: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.medium,
        color: MyColors.white,
      ),
      bodySmall: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.mediumSmall,
        color: MyColors.white,
      ),
      displayLarge: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.largest,
        color: MyColors.white,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.large,
        color: MyColors.white,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.mediumLarge,
        color: MyColors.white,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.sectionTitleSize,
        color: MyColors.white,
      ),
      headlineSmall: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.medium,
        color: MyColors.white,
      ),
      titleLarge: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.largest,
        color: MyColors.white,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.large,
        color: MyColors.white,
        fontWeight: FontWeight.bold,
      ),
      titleSmall: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.mediumLarge,
        color: MyColors.white,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.sectionTitleSize,
        color: MyColors.white,
      ),
      labelLarge: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.medium,
        color: MyColors.white,
      ),
      labelMedium: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.mediumSmall,
        color: MyColors.white,
      ),
      labelSmall: TextStyle(
        fontFamily: Font.family,
        fontSize: Font.cardSubTitleSize,
        color: MyColors.white,
      ),
    ),
  );
}

// Date picker theme
DatePickerThemeData get datePickerTheme {
  return DatePickerThemeData(
    backgroundColor: MyColors.textField,
    cancelButtonStyle: const ButtonStyle(
      foregroundColor: WidgetStatePropertyAll(MyColors.primaryLight),
      textStyle: WidgetStatePropertyAll(TextStyle(
        fontFamily: Font.family,
        fontSize: Font.medium,
        color: MyColors.primary,
      )),
    ),
    confirmButtonStyle: const ButtonStyle(
      foregroundColor: WidgetStatePropertyAll(MyColors.primaryLight),
      textStyle: WidgetStatePropertyAll(TextStyle(
        fontFamily: Font.family,
        fontSize: Font.medium,
        color: MyColors.primary,
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
        color: MyColors.primaryLight,
        width: 2,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: MyColors.primaryLight,
          width: 2,
        ),
        borderRadius: kRadius10,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: MyColors.primaryLight,
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
        color: MyColors.primaryLight,
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

// Dark date picker theme
DatePickerThemeData get darkDatePickerTheme {
  return DatePickerThemeData(
    backgroundColor: const Color(0xFF1E1E1E),
    cancelButtonStyle: const ButtonStyle(
      foregroundColor: WidgetStatePropertyAll(MyColors.primaryLight),
      textStyle: WidgetStatePropertyAll(TextStyle(
        fontFamily: Font.family,
        fontSize: Font.medium,
        color: MyColors.primaryLight,
      )),
    ),
    confirmButtonStyle: const ButtonStyle(
      foregroundColor: WidgetStatePropertyAll(MyColors.primaryLight),
      textStyle: WidgetStatePropertyAll(TextStyle(
        fontFamily: Font.family,
        fontSize: Font.medium,
        color: MyColors.primaryLight,
      )),
    ),
    dividerColor: MyColors.lineDivider,
    headerForegroundColor: MyColors.white,
    headerHeadlineStyle: const TextStyle(
      fontFamily: Font.family,
      fontSize: Font.large,
      color: MyColors.white,
    ),
    headerHelpStyle: const TextStyle(
      fontFamily: Font.family,
      fontSize: Font.medium,
      color: MyColors.white,
    ),
    dayStyle: const TextStyle(
      fontFamily: Font.family,
      fontSize: Font.medium,
      color: MyColors.white,
    ),
    yearStyle: const TextStyle(
      fontFamily: Font.family,
      fontSize: Font.medium,
      color: Color(0xFFBBBBBB), // Lighter grey for dark mode
    ),
    weekdayStyle: const TextStyle(
      fontFamily: Font.family,
      fontSize: Font.mediumLarge,
      color: MyColors.white,
      fontWeight: FontWeight.bold,
    ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: const TextStyle(
        fontFamily: Font.family,
        fontSize: Font.medium,
        color: Color(0xFFBBBBBB), // Lighter grey for dark mode
        fontWeight: FontWeight.normal,
      ),
      activeIndicatorBorder: const BorderSide(
        color: MyColors.primaryLight,
        width: 2,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: MyColors.primaryLight,
          width: 2,
        ),
        borderRadius: kRadius10,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: MyColors.primaryLight,
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
        color: Color(0xFFBBBBBB), // Lighter grey for dark mode
      ),
      labelStyle: const TextStyle(
        fontFamily: Font.family,
        fontSize: Font.mediumLarge,
        color: MyColors.primaryLight,
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
