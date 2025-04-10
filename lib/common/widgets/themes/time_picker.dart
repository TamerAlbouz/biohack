import 'package:flutter/material.dart';

import '../../../styles/colors.dart';
import '../../../styles/font.dart';

Widget timePickerTheme(Widget? child) => Theme(
      data: ThemeData.light().copyWith(
        colorScheme: const ColorScheme.light(
          primary: MyColors.primary,
          onPrimary: Colors.white,
          onSurface: MyColors.textBlack,
          surface: MyColors.cardBackground,
        ),
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
                  ? MyColors.primary.withValues(alpha: 0.2)
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
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: MyColors.primary,
            textStyle: const TextStyle(
              fontSize: Font.smallExtra,
              fontWeight: FontWeight.normal,
              color: MyColors.primary,
            ),
          ),
        ),
      ),
      child: child!,
    );
