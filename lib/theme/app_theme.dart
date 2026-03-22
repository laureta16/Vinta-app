import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vinta/theme/app_colors.dart';

class AppTheme {
  // Elite Senior UI - Web-Stable High-Fidelity Design System
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accentColor,
        primary: AppColors.textPrimary,
        secondary: AppColors.secondaryColor,
        surface: AppColors.background,
        background: AppColors.background,
        error: AppColors.error,
        onPrimary: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.background,
      
      // Elite Typography (Optimized for Web Stability - Sans Serif with Senior-level Stylization)
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -1.5, fontSize: 36, color: AppColors.textPrimary),
        displayMedium: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -1, fontSize: 28, color: AppColors.textPrimary),
        headlineMedium: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5, fontSize: 24, color: AppColors.textPrimary),
        titleLarge: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: AppColors.textPrimary),
        bodyLarge: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.textPrimary),
        bodyMedium: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: AppColors.textSecondary),
        labelLarge: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1, color: AppColors.mediumGray),
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w900,
          letterSpacing: -1,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary, size: 24),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.accentColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
        hintStyle: const TextStyle(color: AppColors.mediumGray, fontWeight: FontWeight.w500),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 64),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 15),
          elevation: 0,
        ),
      ),
      
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: Colors.white,
      ),
    );
  }
}
