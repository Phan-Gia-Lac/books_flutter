import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds — comfortable dark, not pure black
  static const background = Color(0xFF1C1C1E);      // main bg
  static const surface = Color(0xFF2C2C2E);          // cards, containers
  static const surfaceHigh = Color(0xFF3A3A3C);      // elevated elements

  // Text
  static const textPrimary = Color(0xFFE5E5E7);      // main text, easy on eyes
  static const textSecondary = Color(0xFF8E8E93);    // hints, labels
  static const textDisabled = Color(0xFF48484A);     // disabled

  // Accent
  static const accent = Color(0xFF6C63FF);           // purple accent
  static const accentLight = Color(0xFF857DFF);      // lighter purple

  // Input
  static const inputFill = Color(0xFF2C2C2E);
  static const inputBorder = Color(0xFF3A3A3C);
  static const inputFocusBorder = Color(0xFF6C63FF);

  // Status
  static const error = Color(0xFFFF453A);
  static const success = Color(0xFF32D74B);

  // Pure
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
}

/// Retro monochrome palette — grey/black base, lime accent (profile screens).
class ProfileColors {
  static const background = Color(0xFF0E0E0F);
  static const surface = Color(0xFF151617);
  static const surfaceRaised = Color(0xFF1C1E21);
  static const borderOuter = Color(0xFF2A2D31);
  static const borderInner = Color(0xFF0A0A0B);
  static const wireFrame = Color(0xFF2E3135);
  static const textPrimary = Color(0xFFB8B8BA);
  static const textSecondary = Color(0xFF6E6E73);
  static const textMuted = Color(0xFF48484A);
  static const lime = Color(0xFFC6FF00);
  static const limeDim = Color(0xFF8FB300);
  static const signOutIcon = Color(0xFF5C5C5E);
  static const inputFill = Color(0x59000000);
  static const headerGradientTop = Color(0xFF1A1A1B);
  static const headerGradientMid = Color(0xFF141516);
  static const headerGradientBottom = Color(0xFF101112);
  static const saveGradientStart = Color(0xFFD4FF33);
  static const saveGradientMid = Color(0xFFC6FF00);
  static const saveGradientEnd = Color(0xFF9ECC00);
  static const saveButtonText = Color(0xFF1A1A1A);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,

        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          secondary: AppColors.accentLight,
          surface: AppColors.surface,
          error: AppColors.error,
          onPrimary: AppColors.white,
          onSecondary: AppColors.white,
          onSurface: AppColors.textPrimary,
          onError: AppColors.white,
        ),

        // Text theme — system default but comfortable size
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
          displayMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
          labelLarge: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),

        // Input fields
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.inputFill,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.inputBorder, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.inputBorder, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.inputFocusBorder, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error, width: 1),
          ),
          hintStyle: const TextStyle(
            color: AppColors.textDisabled,
            fontSize: 15,
          ),
          prefixIconColor: AppColors.textSecondary,
          suffixIconColor: AppColors.textSecondary,
        ),

        // Elevated button
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Outlined button
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            minimumSize: const Size(double.infinity, 52),
            side: const BorderSide(color: AppColors.inputBorder, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Divider
        dividerTheme: const DividerThemeData(
          color: AppColors.inputBorder,
          thickness: 1,
        ),
      );
}