import 'package:flutter/material.dart';

class AppColors {
  // Primary palette
  static const Color primaryLight = Color(0xFF6C5CE7);
  static const Color primaryDark = Color(0xFFA29BFE);

  // Secondary
  static const Color secondaryLight = Color(0xFF00CEC9);
  static const Color secondaryDark = Color(0xFF55EFC4);

  // Accent
  static const Color accentLight = Color(0xFFFD79A8);
  static const Color accentDark = Color(0xFFE84393);

  // Backgrounds
  static const Color bgLight = Color(0xFFF8F9FE);
  static const Color bgDark = Color(0xFF0D1117);

  // Surfaces
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF161B22);

  // Cards
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1C2333);

  // Text
  static const Color textPrimaryLight = Color(0xFF2D3436);
  static const Color textPrimaryDark = Color(0xFFE6E6E6);
  static const Color textSecondaryLight = Color(0xFF636E72);
  static const Color textSecondaryDark = Color(0xFF8B949E);

  // Status
  static const Color error = Color(0xFFFF6B6B);
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color info = Color(0xFF74B9FF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFD79A8), Color(0xFFE84393)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tealGradient = LinearGradient(
    colors: [Color(0xFF00CEC9), Color(0xFF55EFC4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0D1117), Color(0xFF161B22)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Event type colors
  static const Map<String, Color> eventTypeColors = {
    'SINH_NHAT': Color(0xFFFF6B6B),
    'KY_NIEM': Color(0xFFFD79A8),
    'LE': Color(0xFFFDCB6E),
    'NHA_O': Color(0xFF55EFC4),
    'HOA_DON': Color(0xFF74B9FF),
    'MUA_SAM': Color(0xFFA29BFE),
    'KHAC': Color(0xFF636E72),
  };

  // Group type colors
  static const Map<String, Color> groupTypeColors = {
    'GIA_DINH': Color(0xFF6C5CE7),
    'VO_CHONG': Color(0xFFFD79A8),
    'CON_CAI': Color(0xFF00CEC9),
    'BAN_BE': Color(0xFFFDCB6E),
  };
}
