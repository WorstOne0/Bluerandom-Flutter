// Flutter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

// https://codelabs.developers.google.com/codelabs/flutter-boring-to-beautiful?hl=pt-br#4
// https://m3.material.io/theme-builder#/custom

TonalPalette toTonalPalette(int value) {
  final color = Hct.fromInt(value);
  return TonalPalette.of(color.hue, color.chroma);
}

TonalPalette primaryTonalP = toTonalPalette(Color(0xFF385B3E).value);

// Color Scheme
const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF005DB7),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFD6E3FF),
  onPrimaryContainer: Color(0xFF001B3D),
  secondary: Color(0xFF555F71),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFDAE2F9),
  onSecondaryContainer: Color(0xFF131C2B),
  tertiary: Color(0xFF5A51B2),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFE4DFFF),
  onTertiaryContainer: Color(0xFF150066),
  error: Color(0xFFBA1A1A),
  errorContainer: Color(0xFFFFDAD6),
  onError: Color(0xFFFFFFFF),
  onErrorContainer: Color(0xFF410002),
  background: Color(0xFFFAFAFA),
  onBackground: Color(0xFF1A1B1E),
  surface: Color(0xFFFCFDF7),
  onSurface: Color(0xFF1A1B1E),
  surfaceVariant: Color(0xFFE0E2EC),
  onSurfaceVariant: Color(0xFF44474E),
  outline: Color(0xFF74777F),
  onInverseSurface: Color(0xFFF1F0F4),
  inverseSurface: Color(0xFF2F3033),
  inversePrimary: Color(0xFFA9C7FF),
  shadow: Color(0xFF000000),
  surfaceTint: Colors.transparent,
  outlineVariant: Color(0xFFC4C6D0),
  scrim: Color(0xFF000000),
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFA9C7FF),
  onPrimary: Color(0xFF003063),
  primaryContainer: Color(0xFF00468C),
  onPrimaryContainer: Color(0xFFD6E3FF),
  secondary: Color(0xFFBEC7DC),
  onSecondary: Color(0xFF283141),
  secondaryContainer: Color(0xFF3E4759),
  onSecondaryContainer: Color(0xFFDAE2F9),
  tertiary: Color(0xFFC6C0FF),
  onTertiary: Color(0xFF2B1D82),
  tertiaryContainer: Color(0xFF423899),
  onTertiaryContainer: Color(0xFFE4DFFF),
  error: Color(0xFFFFB4AB),
  errorContainer: Color(0xFF93000A),
  onError: Color(0xFF690005),
  onErrorContainer: Color(0xFFFFDAD6),
  background: Color(0xFF1A1C19),
  onBackground: Color(0xFFE3E2E6),
  surface: Color(0xFF1A1B1E),
  onSurface: Color(0xFFE3E2E6),
  surfaceVariant: Color(0xFF44474E),
  onSurfaceVariant: Color(0xFFC4C6D0),
  outline: Color(0xFF8E9099),
  onInverseSurface: Color(0xFF1A1B1E),
  inverseSurface: Color(0xFFE3E2E6),
  inversePrimary: Color(0xFF005DB7),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFFA9C7FF),
  outlineVariant: Color(0xFF44474E),
  scrim: Color(0xFF000000),
);

// Default Design
ShapeBorder get shapeMedium => RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    );

// Themes
CardTheme cardTheme(bool isDark) {
  return CardTheme(
    elevation: 0,
    shape: shapeMedium,
    color: isDark ? null : Colors.white,
    surfaceTintColor: !isDark ? null : Colors.white,
  );
}

AppBarTheme appBarTheme(ColorScheme colors, bool isDark) {
  return AppBarTheme(
    elevation: 0,
    backgroundColor: isDark ? colors.background : colors.primary,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    ),

    // MD3
    scrolledUnderElevation: 0,
    surfaceTintColor: Colors.transparent,
  );
}

TabBarTheme tabBarTheme(ColorScheme colors) {
  return TabBarTheme(
    labelColor: colors.secondary,
    unselectedLabelColor: colors.onSurfaceVariant,
    indicator: BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: colors.secondary,
          width: 2,
        ),
      ),
    ),
  );
}

BottomAppBarTheme bottomAppBarTheme(ColorScheme colors) {
  return BottomAppBarTheme(
    color: colors.surface,
    elevation: 0,
  );
}

BottomNavigationBarThemeData bottomNavigationBarTheme(ColorScheme colors) {
  return BottomNavigationBarThemeData(
    elevation: 0,
    type: BottomNavigationBarType.fixed,
    landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
    backgroundColor: colors.background,
    selectedItemColor: colors.primary,
  );
}

FloatingActionButtonThemeData floatingActionButtonTheme(ColorScheme colors) {
  return FloatingActionButtonThemeData(
    backgroundColor: colors.primary,
    foregroundColor: Colors.white,
  );
}

DialogTheme dialogTheme(ColorScheme colors) {
  return DialogTheme(
    backgroundColor: colors.background,
    surfaceTintColor: Colors.transparent,
  );
}

ButtonThemeData buttonThemeData() {
  return ButtonThemeData(
    height: 48,
    textTheme: ButtonTextTheme.accent,
  );
}

BottomSheetThemeData bottomSheetThemeData(ColorScheme colors) {
  return BottomSheetThemeData(
    backgroundColor: colors.background,
    surfaceTintColor: Colors.transparent,
  );
}

// Light
ThemeData light() {
  return ThemeData.light().copyWith(
    useMaterial3: true,
    colorScheme: lightColorScheme,
    typography: Typography.material2021(colorScheme: lightColorScheme),
    appBarTheme: appBarTheme(lightColorScheme, false),
    cardTheme: cardTheme(false),
    dialogTheme: dialogTheme(lightColorScheme),
    // bottomAppBarTheme: bottomAppBarTheme(lightColorScheme),
    bottomNavigationBarTheme: bottomNavigationBarTheme(lightColorScheme),
    // tabBarTheme: tabBarTheme(lightColorScheme),
    floatingActionButtonTheme: floatingActionButtonTheme(lightColorScheme),
    buttonTheme: buttonThemeData(),
    bottomSheetTheme: bottomSheetThemeData(lightColorScheme),
  );
}

// Dark
ThemeData dark() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: darkColorScheme,
    typography: Typography.material2021(colorScheme: darkColorScheme),
    appBarTheme: appBarTheme(darkColorScheme, true),
    cardTheme: cardTheme(true),
    dialogTheme: dialogTheme(darkColorScheme),
    // bottomAppBarTheme: bottomAppBarTheme(darkColorScheme),
    bottomNavigationBarTheme: bottomNavigationBarTheme(darkColorScheme),
    // tabBarTheme: tabBarTheme(darkColorScheme),
    scaffoldBackgroundColor: darkColorScheme.background,
    floatingActionButtonTheme: floatingActionButtonTheme(darkColorScheme),
    buttonTheme: buttonThemeData(),
    bottomSheetTheme: bottomSheetThemeData(darkColorScheme),
  );
}
