import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Themes {
  static final primaryColor = createMaterialColor(0xFFFF8E2B);
  static final canvasColor = createMaterialColor(0xFFF1F1F1);
  static const backgroundColor = Colors.black;
  static final cardColor = createMaterialColor(0xFFFFFFFF);

  static final typography =
      Typography.material2021(platform: TargetPlatform.android);
  static final TextTheme textTheme = typography.black.copyWith(
    bodyText2: typography.black.bodyText2!.copyWith(fontSize: 16),
    bodyText1: typography.black.bodyText1!
        .copyWith(fontSize: 18, fontWeight: FontWeight.normal),
  );

  static final ThemeData mainTheme = ThemeData(
    primarySwatch: primaryColor,
    canvasColor: canvasColor,
    backgroundColor: backgroundColor,
    bottomAppBarTheme: BottomAppBarTheme(color: canvasColor, elevation: 0),
    appBarTheme: AppBarTheme(
        titleTextStyle: GoogleFonts.varelaRound(
            fontSize: 24, fontWeight: FontWeight.w500, color: primaryColor),
        color: canvasColor,
        elevation: 0),
    iconTheme: IconThemeData(color: primaryColor),
    textTheme: textTheme,
    cardColor: cardColor,
    floatingActionButtonTheme:
        const FloatingActionButtonThemeData(foregroundColor: Colors.white),
  );

  static MaterialColor createMaterialColor(int hex) {
    final color = Color(hex);
    List strengths = <double>[.05];
    final swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }

    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}
