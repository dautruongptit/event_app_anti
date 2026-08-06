import 'package:flutter/material.dart';

class AppColors {
  // Primary palette — Coral/Salmon (from Figma)
  static const Color primaryLight = Color(0xFFF87171);
  static const Color primaryDark = Color(0xFFEF5350);

  // Secondary — Teal/Mint
  static const Color secondaryLight = Color(0xFF26A69A);
  static const Color secondaryDark = Color(0xFF4DB6AC);

  // Accent — Pink
  static const Color accentLight = Color(0xFFFD79A8);
  static const Color accentDark = Color(0xFFE84393);

  // Backgrounds
  static const Color bgLight = Color(0xFFFFF8F8);
  static const Color bgDark = Color(0xFF0D1117);

  // Surfaces
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF161B22);

  // Cards
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1C2333);

  // Text
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textPrimaryDark = Color(0xFFE6E6E6);
  static const Color textSecondaryLight = Color(0xFF9E9E9E);
  static const Color textSecondaryDark = Color(0xFF8B949E);

  // Status
  static const Color error = Color(0xFFFF6B6B);
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color info = Color(0xFF74B9FF);

  // Icon background — pastel pink
  static const Color iconBgPink = Color(0xFFFCE4EC);
  static const Color iconBgTeal = Color(0xFFE0F2F1);
  static const Color iconBgPurple = Color(0xFFF3E5F5);
  static const Color iconBgOrange = Color(0xFFFFF3E0);
  static const Color iconBgYellow = Color(0xFFFFF8E1);

  // Gradients — Figma header gradient (coral → teal)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFF87171), Color(0xFFEF5350)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFFF87171), Color(0xFFEF9A9A), Color(0xFF80CBC4), Color(0xFF26A69A)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient tealGradient = LinearGradient(
    colors: [Color(0xFF26A69A), Color(0xFF4DB6AC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFF87171), Color(0xFF26A69A)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0D1117), Color(0xFF161B22)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Event type colors (from Figma)
  static const Map<String, Color> eventTypeColors = {
    'SINH_NHAT': Color(0xFFF87171),
    'KY_NIEM': Color(0xFFF87171),
    'LE': Color(0xFFFDCB6E),
    'NHA_O': Color(0xFF26A69A),
    'HOA_DON': Color(0xFFFFC107),
    'MUA_SAM': Color(0xFF26A69A),
    'KHAC': Color(0xFF9E9E9E),
  };

  // Group type colors
  static const Map<String, Color> groupTypeColors = {
    'GIA_DINH': Color(0xFFF87171),
    'VO_CHONG': Color(0xFF26A69A),
    'CON_CAI': Color(0xFFCE93D8),
    'BAN_BE': Color(0xFFFFB74D),
  };
}
