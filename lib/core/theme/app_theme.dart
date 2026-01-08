import 'package:birdo/core/theme/penguino_colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static const ColorPalette colors = ColorPalette();
  static const AppTypography typography = AppTypography();
  static const AppSpacing spacing = AppSpacing();
  static const AppElevation elevation = AppElevation();
  static const AppRadius radius = AppRadius();
  static const AppAnimationDuration animationDuration = AppAnimationDuration();

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: colors.primary,
      colorScheme: ColorScheme.light(
        primary: colors.primary,
        secondary: colors.secondary,
        tertiary: colors.accent,
        surface: colors.surface,
        error: colors.error,
      ),
      scaffoldBackgroundColor: colors.background,
      textTheme: _buildTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.primary,
        elevation: elevation.medium,
        titleTextStyle: typography.h6.copyWith(color: colors.onPrimary),
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: elevation.small,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius.medium),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          padding: EdgeInsets.symmetric(
            horizontal: spacing.large,
            vertical: spacing.medium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius.medium),
          ),
          elevation: elevation.medium,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius.medium),
          borderSide: BorderSide(color: colors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius.medium),
          borderSide: BorderSide(color: colors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius.medium),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius.medium),
          borderSide: BorderSide(color: colors.error, width: 2),
        ),
        contentPadding: EdgeInsets.all(spacing.medium),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: colors.primaryDark,
      colorScheme: ColorScheme.dark(
        primary: colors.primaryDark,
        secondary: colors.secondaryDark,
        tertiary: colors.accentDark,
        surface: colors.surfaceDark,
        error: colors.errorDark,
      ),
      scaffoldBackgroundColor: colors.backgroundDark,
      textTheme: _buildDarkTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.primaryDark,
        elevation: elevation.medium,
        titleTextStyle: typography.h6.copyWith(color: colors.onPrimaryDark),
      ),
      cardTheme: CardThemeData(
        color: colors.surfaceDark,
        elevation: elevation.small,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius.medium),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primaryDark,
          foregroundColor: colors.onPrimaryDark,
          padding: EdgeInsets.symmetric(
            horizontal: spacing.large,
            vertical: spacing.medium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius.medium),
          ),
          elevation: elevation.medium,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius.medium),
          borderSide: BorderSide(color: colors.outlineDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius.medium),
          borderSide: BorderSide(color: colors.outlineDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius.medium),
          borderSide: BorderSide(color: colors.primaryDark, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius.medium),
          borderSide: BorderSide(color: colors.errorDark, width: 2),
        ),
        contentPadding: EdgeInsets.all(spacing.medium),
      ),
    );
  }

  static TextTheme _buildTextTheme() {
    return TextTheme(
      displayLarge: typography.h1,
      displayMedium: typography.h2,
      displaySmall: typography.h3,
      headlineMedium: typography.h4,
      headlineSmall: typography.h5,
      titleLarge: typography.h6,
      bodyLarge: typography.body1,
      bodyMedium: typography.body2,
      labelLarge: typography.button,
      bodySmall: typography.caption,
    );
  }

  static TextTheme _buildDarkTextTheme() {
    return TextTheme(
      displayLarge: typography.h1.copyWith(color: colors.onBackgroundDark),
      displayMedium: typography.h2.copyWith(color: colors.onBackgroundDark),
      displaySmall: typography.h3.copyWith(color: colors.onBackgroundDark),
      headlineMedium: typography.h4.copyWith(color: colors.onBackgroundDark),
      headlineSmall: typography.h5.copyWith(color: colors.onBackgroundDark),
      titleLarge: typography.h6.copyWith(color: colors.onBackgroundDark),
      bodyLarge: typography.body1.copyWith(color: colors.onBackgroundDark),
      bodyMedium: typography.body2.copyWith(color: colors.onBackgroundDark),
      labelLarge: typography.button.copyWith(color: colors.onBackgroundDark),
      bodySmall: typography.caption.copyWith(color: colors.onBackgroundDark),
    );
  }
}

class ColorPalette {
  const ColorPalette();

  final Color primary = PenguinoColors.gooseBlue5;
  final Color primaryVariant = PenguinoColors.gooseBlue7;
  final Color onPrimary = PenguinoColors.textWhite;

  final Color secondary = PenguinoColors.gooseBlue3;
  final Color secondaryVariant = PenguinoColors.blue2;
  final Color onSecondary = PenguinoColors.black9;

  final Color buttonPrimary = PenguinoColors.bgGrayLight;
  final Color buttonPrimaryVariant = PenguinoColors.black5;
  final Color buttonSecondary = PenguinoColors.blueLight;
  final Color buttonSecondaryVariant = PenguinoColors.blue2;
  final Color onButtonPrimary = PenguinoColors.textWhite;
  final Color onButtonSecondary = PenguinoColors.black9;

  final Color accent = PenguinoColors.gooseYellow;
  final Color onAccent = PenguinoColors.black9;

  final Color background = PenguinoColors.bgGrayUltraLight;
  final Color onBackground = PenguinoColors.black9;

  final Color surface = PenguinoColors.bgWhite;
  final Color onSurface = PenguinoColors.black7;

  final Color error = PenguinoColors.redLight;
  final Color onError = PenguinoColors.textWhite;

  final Color outline = PenguinoColors.black1;
  final Color disabled = PenguinoColors.black2;
  final Color onDisabled = PenguinoColors.black3;

  final Color primaryDark = PenguinoColors.gooseBlue5;
  final Color primaryVariantDark = PenguinoColors.gooseBlue7;
  final Color onPrimaryDark = PenguinoColors.textWhite;

  final Color secondaryDark = PenguinoColors.gooseBlue3;
  final Color secondaryVariantDark = PenguinoColors.blue2;
  final Color onSecondaryDark = PenguinoColors.black9;

  final Color accentDark = PenguinoColors.gooseYellow;
  final Color onAccentDark = PenguinoColors.black9;

  final Color backgroundDark = PenguinoColors.black7;
  final Color onBackgroundDark = PenguinoColors.textWhite;

  final Color surfaceDark = PenguinoColors.black6;
  final Color onSurfaceDark = PenguinoColors.textWhite;

  final Color errorDark = PenguinoColors.redLight;
  final Color onErrorDark = PenguinoColors.textWhite;

  final Color outlineDark = PenguinoColors.black5;
  final Color disabledDark = PenguinoColors.black3;
  final Color onDisabledDark = PenguinoColors.black2;
}

class AppTypography {
  const AppTypography();

  final TextStyle h1 = const TextStyle(
    fontSize: 96,
    fontWeight: FontWeight.w300,
    letterSpacing: -1.5,
  );

  final TextStyle h2 = const TextStyle(
    fontSize: 60,
    fontWeight: FontWeight.w300,
    letterSpacing: -0.5,
  );

  final TextStyle h3 = const TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w400,
  );

  final TextStyle h4 = const TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );

  final TextStyle h5 = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w400,
  );

  final TextStyle h6 = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  );

  final TextStyle subtitle1 = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
  );

  final TextStyle subtitle2 = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  final TextStyle body1 = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );

  final TextStyle body2 = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );

  final TextStyle button = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.25,
  );

  final TextStyle caption = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  );

  final TextStyle overline = const TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    letterSpacing: 1.5,
  );
}

class AppSpacing {
  const AppSpacing();

  final double xxsmall = 2.0;
  final double xsmall = 4.0;
  final double small = 8.0;
  final double medium = 16.0;
  final double large = 24.0;
  final double xlarge = 32.0;
  final double xxlarge = 48.0;
  final double xxxlarge = 64.0;
}

class AppElevation {
  const AppElevation();

  final double none = 0.0;
  final double xsmall = 1.0;
  final double small = 2.0;
  final double medium = 4.0;
  final double large = 8.0;
  final double xlarge = 16.0;
  final double xxlarge = 24.0;
}

class AppRadius {
  const AppRadius();

  final double none = 0.0;
  final double small = 4.0;
  final double medium = 8.0;
  final double large = 16.0;
  final double xlarge = 24.0;
  final double circular = 999.0;
}

class AppAnimationDuration {
  const AppAnimationDuration();

  final Duration fast = const Duration(milliseconds: 150);
  final Duration medium = const Duration(milliseconds: 300);
  final Duration slow = const Duration(milliseconds: 500);
}
