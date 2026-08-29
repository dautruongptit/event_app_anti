import 'package:flutter/material.dart';

/// Nino design tokens — coral / mint / amber / violet.
/// Values copied from `Nino App.dc.html` (Claude Design project
/// "Mobile app với 8 màn hình"). See
/// docs/superpowers/specs/2026-08-29-nino-redesign-design.md.
class AppColors {
  // ─── Surfaces ───
  static const Color pageLight = Color(0xFFEFEDEA);
  static const Color bgLight = Color(0xFFFBFAF9);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFFFFFFF);

  static const Color pageDark = Color(0xFF0C0E11);
  static const Color bgDark = Color(0xFF15171B);
  static const Color cardDark = Color(0xFF1E2126);
  static const Color surfaceDark = Color(0xFF1E2126);

  // ─── Text ───
  static const Color textPrimaryLight = Color(0xFF1F2530);
  static const Color textSecondaryLight = Color(0xFF8A94A6);
  static const Color textFaintLight = Color(0xFFB4BBC7);

  static const Color textPrimaryDark = Color(0xFFF2F4F7);
  static const Color textSecondaryDark = Color(0xFF98A0AE);
  static const Color textFaintDark = Color(0xFF6C7480);

  // ─── Borders ───
  static const Color lineLight = Color(0x0F1F2530); // rgba(31,37,48,.06)
  static const Color line2Light = Color(0x1A1F2530); // rgba(31,37,48,.10)
  static const Color lineDark = Color(0x12FFFFFF); // rgba(255,255,255,.07)
  static const Color line2Dark = Color(0x21FFFFFF); // rgba(255,255,255,.13)

  // ─── Brand accents (light) ───
  static const Color primaryLight = Color(0xFFFF5A5F); // coral
  static const Color primarySoftLight = Color(0x1AFF5A5F); // 10%
  static const Color secondaryLight = Color(0xFF2F9E97); // mint (text/icon)
  static const Color secondarySoftLight = Color(0x214ECDC4); // 13% over #4ECDC4
  static const Color amberLight = Color(0xFFD69C13);
  static const Color amberSoftLight = Color(0x29FFC93C); // 16% over #FFC93C
  static const Color accentLight = Color(0xFF8B6BE0); // violet
  static const Color accentSoftLight = Color(0x21A78BFA); // 13% over #A78BFA

  // ─── Brand accents (dark) ───
  static const Color primaryDark = Color(0xFFFF7075);
  static const Color primarySoftDark = Color(0x29FF7075); // 16%
  static const Color secondaryDark = Color(0xFF5CD0C8);
  static const Color secondarySoftDark = Color(0x295CD0C8); // 16%
  static const Color amberDark = Color(0xFFF0BC48);
  static const Color amberSoftDark = Color(0x29F0BC48); // 16%
  static const Color accentDark = Color(0xFFB79DFF);
  static const Color accentSoftDark = Color(0x2EB79DFF); // 18%

  // ─── Neutral / status ───
  static const Color neutralSoftLight = Color(0x0D1F2530); // rgba(31,37,48,.05)
  static const Color neutralSoftDark = Color(0x0FFFFFFF); // rgba(255,255,255,.06)

  static const Color error = Color(0xFFFF4757);
  static const Color errorSoftLight = Color(0x12FF4757); // rgba(255,71,87,.07)
  static const Color errorDark = Color(0xFFFF6B78);
  static const Color errorSoftDark = Color(0x1FFF6B78); // rgba(255,107,120,.12)
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color info = Color(0xFF74B9FF);

  // ─── Nav / sticky-bar background (translucent, blurred) ───
  static const Color navBarLight = Color(0xF0FFFFFF); // rgba(255,255,255,.94)
  static const Color navBarDark = Color(0xF01E2126); // rgba(30,33,38,.94)

  // ─── Card shadow color (used as BoxShadow.color) ───
  static const Color shadowLight = Color(0x0D1F2530); // rgba(31,37,48,.05)
  static const Color shadowDark = Color(0x73000000); // rgba(0,0,0,.45)

  // ─── Gradients (brand marks — same in light & dark) ───
  static const LinearGradient coralGradient = LinearGradient(
    colors: [Color(0xFFFF8285), Color(0xFFFF5A5F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// "Đăng ký với Google" button on the Sign-up screen.
  static const LinearGradient signupGradient = LinearGradient(
    colors: [Color(0xFFFF6A70), Color(0xFF4ECDC4)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Hero card on the Holidays screen ("ngày lễ sắp tới").
  static const LinearGradient holidayHeroGradient = LinearGradient(
    colors: [Color(0xFFFF8080), Color(0xFFFF5A5F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0C0E11), Color(0xFF15171B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ─── Relative avatar palette — cycles by groupType (spec §A) ───
  static const Map<String, Color> groupTypeColors = {
    'GIA_DINH': primaryLight, // gia đình → coral
    'VO_CHONG': secondaryLight, // vợ/chồng → mint
    'CON_CAI': accentLight, // con cái → violet
    'BAN_BE': Color(0xFFD69C13), // bạn bè → amber
  };

  static const Map<String, Color> groupTypeColorsDark = {
    'GIA_DINH': primaryDark,
    'VO_CHONG': secondaryDark,
    'CON_CAI': accentDark,
    'BAN_BE': Color(0xFFF0BC48),
  };

  static const Map<String, Color> groupTypeSoftColors = {
    'GIA_DINH': primarySoftLight,
    'VO_CHONG': secondarySoftLight,
    'CON_CAI': accentSoftLight,
    'BAN_BE': amberSoftLight,
  };

  static const Map<String, Color> groupTypeSoftColorsDark = {
    'GIA_DINH': primarySoftDark,
    'VO_CHONG': secondarySoftDark,
    'CON_CAI': accentSoftDark,
    'BAN_BE': amberSoftDark,
  };

  // Kept for backward compatibility with EventModel.eventTypeIcon fallback
  // paths (old category codes) — not used by any redesigned screen.
  static const Map<String, Color> eventTypeColors = {
    'SINH_NHAT': Color(0xFFFF5A5F),
    'KY_NIEM': Color(0xFFFF5A5F),
    'LE': Color(0xFFD69C13),
    'NHA_O': Color(0xFF2F9E97),
    'HOA_DON': Color(0xFFD69C13),
    'MUA_SAM': Color(0xFF2F9E97),
    'KHAC': Color(0xFF8A94A6),
  };

  static const Color iconBgPink = primarySoftLight;
  static const Color iconBgTeal = secondarySoftLight;
  static const Color iconBgPurple = accentSoftLight;
  static const Color iconBgOrange = amberSoftLight;
  static const Color iconBgYellow = amberSoftLight;
}
