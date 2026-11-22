import 'package:material_ui/material_ui.dart';

class AppColors {
  static const bg = Color(0xFF0E0B14);
  static const surface = Color(0xFF1A1622);
  static const surface2 = Color(0xFF241F2E);
  static const accent = Color(0xFFFF4FA3);
  static const accent2 = Color(0xFF26C6DA);
  static const gold = Color(0xFFF2B33D);
  static const text2 = Color(0xFFB9B2C6);
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      brightness: Brightness.dark,
      surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.bg,
  );
  return base.copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
          fontFamily: 'Anton', fontSize: 24, letterSpacing: 0.5, color: Colors.white),
    ),
    cardTheme: const CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}

const display = TextStyle(fontFamily: 'Anton', letterSpacing: 0.5);
