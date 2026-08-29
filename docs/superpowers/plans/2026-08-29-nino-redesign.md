# Nino Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reskin all 13 screens of `event_app` from the "Zalo-blue" palette to the "Nino" coral/mint/amber/violet design system, and add a new Lịch nghỉ lễ (Vietnamese holidays) feature with client-side lunar calendar conversion.

**Architecture:** Rewrite the two central design-system files (`AppColors`, `AppTheme`) first so every screen inherits the new palette automatically. Build a small shared-widget library (`lib/ui/widgets/nino/`) implementing the recurring visual patterns (avatar, card-row, pill tabs, bottom sheet picker, sticky save bar, toast, toggle). Then reskin each of the 13 screens on top of that library, preserving all existing provider/state wiring verbatim. Add a self-contained lunar-calendar utility and a new Holidays screen as the only new feature.

**Tech Stack:** Flutter 3 / Dart, `provider` (state), `go_router` (routing), `google_fonts` (Inter — already in use, unchanged), `flutter_animate` (existing entrance animations — kept), `shared_preferences` (new: persisting "reminder on" holiday names).

**Spec:** `docs/superpowers/specs/2026-08-29-nino-redesign-design.md`

## Global Constraints

- Keep cỡ chữ (font sizes) as they are today — do not scale up. Only replace colors, shapes, spacing and add the new components described below (decided during brainstorm, spec "Bối cảnh").
- App name/tagline "NINO" stays unchanged — visual only.
- No backend/API schema changes. `EventModel`/`RelativeModel` already carry every field the new screens need (verified against `lib/models/event.dart` and `lib/models/relative.dart`).
- Every screen keeps its existing `Provider`/`go_router` wiring (method names, routes, arguments) exactly as today — only the widget tree inside `build()` changes.
- Every new/modified file must pass `flutter analyze` with zero new warnings before its task's commit.
- Vietnamese UI strings are copied verbatim from the design source (`Nino App.dc.html`) — do not paraphrase.
- Gradient angles from the CSS design (`150deg`, `100deg`) are approximated with Flutter `Alignment` diagonals (`topLeft`→`bottomRight` for `150deg`, `centerLeft`→`centerRight` for `100deg`) — exact angle fidelity is not required, only the same two color stops in the same order.

---

## Task 1: Rewrite design tokens (`AppColors`)

**Files:**
- Modify: `lib/core/constants/app_colors.dart` (full rewrite)

**Interfaces:**
- Produces: every named `Color`/`LinearGradient` constant below — every later task's code references these exact names. Do not rename any of them once this task is committed.

Note: `pageLight`/`pageDark` are defined below (matching the design source's `--page` token, the letterboxed background behind the phone mockup in the web prototype) but **no screen task uses them** — on a real device there is no device-frame letterbox, so every screen's `Scaffold.backgroundColor` uses `bgLight`/`bgDark` instead (this resolves the spec's open question in "Rủi ro / lưu ý" about whether the `page` token has a real use). They stay defined for completeness/future use rather than being removed now.

- [ ] **Step 1: Replace the full content of `app_colors.dart`**

```dart
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
```

- [ ] **Step 2: Run analyzer**

Run: `C:\flutter\bin\flutter.bat analyze lib/core/constants/app_colors.dart`
Expected: `No issues found!` — if other files reference old constants removed here (e.g. `AppColors.primaryGradient`, `AppColors.headerGradient`, `AppColors.tealGradient`, `AppColors.accentGradient`, `AppColors.cardLight`/`surfaceLight` renamed — note: these two keep their names, only new ones added), analyze will list every call site that needs Task 15+ to fix. Note them down; they get fixed as each screen's task is done, not here.

- [ ] **Step 3: Commit**

```bash
git add lib/core/constants/app_colors.dart
git commit -m "feat(nino): rewrite AppColors with coral/mint/amber/violet tokens"
```

---

## Task 2: Update `AppTheme` for the new tokens

**Files:**
- Modify: `lib/core/theme/app_theme.dart` (full rewrite)

**Interfaces:**
- Consumes: every `AppColors.*` name from Task 1.
- Produces: `AppTheme.lightTheme`, `AppTheme.darkTheme` (unchanged public API — `main.dart`/`app.dart` keep working without changes).

- [ ] **Step 1: Replace the full content of `app_theme.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryLight,
        secondary: AppColors.secondaryLight,
        tertiary: AppColors.accentLight,
        background: AppColors.pageLight,
        surface: AppColors.bgLight,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: AppColors.textPrimaryLight,
        onSurface: AppColors.textPrimaryLight,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.bgLight,
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
        bodyLarge: const TextStyle(color: AppColors.textPrimaryLight),
        bodyMedium: const TextStyle(color: AppColors.textSecondaryLight),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textPrimaryLight),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimaryLight,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.line2Light),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.line2Light),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          elevation: 0,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.navBarLight,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.textSecondaryLight,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(18))),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.neutralSoftLight,
        selectedColor: AppColors.primaryLight,
        labelStyle: const TextStyle(color: AppColors.textPrimaryLight),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cardLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimaryLight,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryDark,
        secondary: AppColors.secondaryDark,
        tertiary: AppColors.accentDark,
        background: AppColors.pageDark,
        surface: AppColors.bgDark,
        error: AppColors.errorDark,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: AppColors.textPrimaryDark,
        onSurface: AppColors.textPrimaryDark,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.bgDark,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        bodyLarge: const TextStyle(color: AppColors.textPrimaryDark),
        bodyMedium: const TextStyle(color: AppColors.textSecondaryDark),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textPrimaryDark),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimaryDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.line2Dark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.line2Dark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.primaryDark, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.errorDark, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          elevation: 0,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.navBarDark,
        selectedItemColor: AppColors.primaryDark,
        unselectedItemColor: AppColors.textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(18))),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.neutralSoftDark,
        selectedColor: AppColors.primaryDark,
        labelStyle: const TextStyle(color: AppColors.textPrimaryDark),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimaryDark,
        contentTextStyle: const TextStyle(color: AppColors.bgDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
```

- [ ] **Step 2: Run analyzer**

Run: `C:\flutter\bin\flutter.bat analyze lib/core/theme/app_theme.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/core/theme/app_theme.dart
git commit -m "feat(nino): update AppTheme for new color tokens"
```

---

## Task 3: Shared widget — `NinoLogo` / `NinoWordmark`

**Files:**
- Create: `lib/ui/widgets/nino/nino_logo.dart`

**Interfaces:**
- Consumes: `AppColors.coralGradient` (Task 1).
- Produces: `NinoLogo({size, showBadge})`, `NinoWordmark({logoSize, fontSize, textColor})` — used by Tasks 15 (Welcome), 16 (Sign up), 17 (Home), 24 (Tôi).

- [ ] **Step 1: Create the file**

```dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Brand mark — direction 1a "Near Ones": a coral rounded square holding
/// the letter N, a translucent ring hugging it, and a small mint dot
/// (coral-bordered) top-right when [showBadge] is true.
class NinoLogo extends StatelessWidget {
  final double size;
  final bool showBadge;

  const NinoLogo({super.key, this.size = 84, this.showBadge = true});

  @override
  Widget build(BuildContext context) {
    final ringSize = size * 0.71;
    final ringWidth = size * 0.048;
    final fontSize = size * 0.452;
    final badgeSize = size * 0.131;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: AppColors.coralGradient,
              borderRadius: BorderRadius.circular(size * 0.286),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF5A5F).withValues(alpha: 0.3),
                  blurRadius: size * 0.14,
                  offset: Offset(0, size * 0.06),
                ),
              ],
            ),
          ),
          Container(
            width: ringSize,
            height: ringSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.28), width: ringWidth),
            ),
          ),
          Text(
            'N',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -fontSize * 0.05,
              height: 1,
            ),
          ),
          if (showBadge)
            Positioned(
              top: size * 0.167,
              right: size * 0.167,
              child: Container(
                width: badgeSize,
                height: badgeSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4ECDC4),
                  border: Border.all(color: const Color(0xFFFF6266), width: badgeSize * 0.24),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Small horizontal lockup: [NinoLogo] + "nino" wordmark. Used in headers
/// and footers where the full square mark would be too big.
class NinoWordmark extends StatelessWidget {
  final double logoSize;
  final double fontSize;
  final Color? textColor;

  const NinoWordmark({super.key, this.logoSize = 20, this.fontSize = 14, this.textColor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        NinoLogo(size: logoSize, showBadge: false),
        SizedBox(width: logoSize * 0.4),
        Text(
          'nino',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: -fontSize * 0.04,
            color: textColor ?? (isDark ? Colors.white : const Color(0xFF1F2530)),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Run analyzer**

Run: `C:\flutter\bin\flutter.bat analyze lib/ui/widgets/nino/nino_logo.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/ui/widgets/nino/nino_logo.dart
git commit -m "feat(nino): add NinoLogo/NinoWordmark shared widget"
```

---

## Task 4: Shared widget — `InitialsAvatar`

**Files:**
- Create: `lib/ui/widgets/nino/initials_avatar.dart`

**Interfaces:**
- Produces: `InitialsAvatar({name, color, softColor, radius, avatarUrl})` — used by Tasks 17-20, 24.

- [ ] **Step 1: Create the file**

```dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Circle avatar: shows [avatarUrl] when present, otherwise the first
/// letter of [name] on a soft-tinted [softColor] background in [color].
class InitialsAvatar extends StatelessWidget {
  final String name;
  final Color color;
  final Color softColor;
  final double radius;
  final String? avatarUrl;

  const InitialsAvatar({
    super.key,
    required this.name,
    required this.color,
    required this.softColor,
    this.radius = 24,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final initial = trimmed.isNotEmpty ? trimmed[0].toUpperCase() : '?';
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: softColor,
        backgroundImage: CachedNetworkImageProvider(avatarUrl!),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: softColor,
      child: Text(
        initial,
        style: TextStyle(fontSize: radius * 0.62, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}
```

- [ ] **Step 2: Run analyzer**

Run: `C:\flutter\bin\flutter.bat analyze lib/ui/widgets/nino/initials_avatar.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/ui/widgets/nino/initials_avatar.dart
git commit -m "feat(nino): add InitialsAvatar shared widget"
```

---

## Task 5: Shared widget — `CardRow` / `SquareIconBadge`

**Files:**
- Create: `lib/ui/widgets/nino/card_row.dart`

**Interfaces:**
- Consumes: `AppColors.{cardLight,cardDark,lineLight,lineDark,shadowLight,shadowDark,textPrimaryLight,textPrimaryDark}` (Task 1).
- Produces: `CardRow({leading, title, meta, trailing, onTap, borderColor, padding})`, `SquareIconBadge({icon, color, background, size})` — used by Tasks 17-21, 24-25 and the Holidays task.

- [ ] **Step 1: Create the file**

```dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Standard list row: a leading icon/avatar, a title + optional meta
/// line, and an optional trailing widget — used for people, events,
/// notifications and holidays lists.
class CardRow extends StatelessWidget {
  final Widget leading;
  final String title;
  final Widget? meta;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;

  const CardRow({
    super.key,
    required this.leading,
    required this.title,
    this.meta,
    this.trailing,
    this.onTap,
    this.borderColor,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor ?? (isDark ? AppColors.lineDark : AppColors.lineLight)),
          boxShadow: [
            BoxShadow(
              color: isDark ? AppColors.shadowDark : AppColors.shadowLight,
              blurRadius: isDark ? 12 : 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (meta != null) ...[
                    const SizedBox(height: 3),
                    meta!,
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

/// The colored square icon badge used as [CardRow.leading] throughout the
/// app (events, notifications, holidays).
class SquareIconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final double size;

  const SquareIconBadge({
    super.key,
    required this.icon,
    required this.color,
    required this.background,
    this.size = 42,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(size * 0.33)),
      child: Icon(icon, color: color, size: size * 0.45),
    );
  }
}
```

- [ ] **Step 2: Run analyzer**

Run: `C:\flutter\bin\flutter.bat analyze lib/ui/widgets/nino/card_row.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/ui/widgets/nino/card_row.dart
git commit -m "feat(nino): add CardRow/SquareIconBadge shared widget"
```

---

## Task 6: Shared widget — `PillTabs` / `FilterChipsRow` / `SegmentedPillTabs`

**Files:**
- Create: `lib/ui/widgets/nino/pill_tabs.dart`

**Interfaces:**
- Produces: `PillTabs({labels, selectedIndex, onChanged})` (Home), `FilterChipsRow({labels, selected, onChanged})` (Sự kiện), `SegmentedPillTabs({labels, selected, onChanged})` (Lịch nghỉ lễ).

- [ ] **Step 1: Create the file**

```dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Underlined text tabs (Home's "Người thân" / "Sự kiện của tôi").
class PillTabs extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const PillTabs({super.key, required this.labels, required this.selectedIndex, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pri = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final mut = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    return Row(
      children: List.generate(labels.length, (i) {
        final selected = i == selectedIndex;
        return Padding(
          padding: EdgeInsets.only(right: i == labels.length - 1 ? 0 : 24),
          child: GestureDetector(
            onTap: () => onChanged(i),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? pri : mut,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 2.5,
                  width: 28,
                  decoration: BoxDecoration(
                    color: selected ? pri : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

/// Row of standalone pill filter chips (Sự kiện's 4 filters).
class FilterChipsRow extends StatelessWidget {
  final List<String> labels;
  final String selected;
  final ValueChanged<String> onChanged;

  const FilterChipsRow({super.key, required this.labels, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final txt = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mut = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final line2 = isDark ? AppColors.line2Dark : AppColors.line2Light;

    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 7),
        itemBuilder: (context, i) {
          final label = labels[i];
          final isOn = label == selected;
          return GestureDetector(
            onTap: () => onChanged(label),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
              decoration: BoxDecoration(
                color: isOn ? txt : card,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: isOn ? txt : line2),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isOn ? (isDark ? AppColors.bgDark : Colors.white) : mut,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 3-way segmented control (Lịch nghỉ lễ's Tất cả/Dương lịch/Âm lịch).
class SegmentedPillTabs extends StatelessWidget {
  final List<String> labels;
  final String selected;
  final ValueChanged<String> onChanged;

  const SegmentedPillTabs({super.key, required this.labels, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final txt = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mut = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final card = isDark ? AppColors.cardDark : Colors.white;
    final track = isDark ? AppColors.neutralSoftDark : AppColors.neutralSoftLight;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: track, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: labels.map((label) {
          final isOn = label == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(label),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: isOn ? card : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: isOn
                      ? [BoxShadow(color: isDark ? AppColors.shadowDark : AppColors.shadowLight, blurRadius: 4)]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isOn ? FontWeight.w700 : FontWeight.w500,
                    color: isOn ? txt : mut,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
```

- [ ] **Step 2: Run analyzer**

Run: `C:\flutter\bin\flutter.bat analyze lib/ui/widgets/nino/pill_tabs.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/ui/widgets/nino/pill_tabs.dart
git commit -m "feat(nino): add PillTabs/FilterChipsRow/SegmentedPillTabs shared widget"
```

---

## Task 7: Shared widget — `SoftToggle`

**Files:**
- Create: `lib/ui/widgets/nino/soft_toggle.dart`

**Interfaces:**
- Produces: `SoftToggle({value, onChanged, activeColor})` — used by Tasks 22 (Add Event), 24 (Tôi).

- [ ] **Step 1: Create the file**

```dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Self-drawn track/knob switch matching the design (Material [Switch]
/// has different proportions). 46×27, knob slides 3px↔22px.
class SoftToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;

  const SoftToggle({super.key, required this.value, required this.onChanged, this.activeColor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final on = activeColor ?? (isDark ? AppColors.primaryDark : AppColors.primaryLight);
    final off = isDark ? AppColors.line2Dark : AppColors.line2Light;

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 46,
        height: 27,
        decoration: BoxDecoration(color: value ? on : off, borderRadius: BorderRadius.circular(999)),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: 21,
            height: 21,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Color(0x40000000), blurRadius: 5, offset: Offset(0, 2))],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Run analyzer**

Run: `C:\flutter\bin\flutter.bat analyze lib/ui/widgets/nino/soft_toggle.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/ui/widgets/nino/soft_toggle.dart
git commit -m "feat(nino): add SoftToggle shared widget"
```

---

## Task 8: Shared widget — `showNinoToast`

**Files:**
- Create: `lib/ui/widgets/nino/nino_toast.dart`

**Interfaces:**
- Produces: `showNinoToast(BuildContext context, String message)` — used by any screen that currently calls `ScaffoldMessenger.of(context).showSnackBar(...)` for a transient confirmation (Tasks 17-25 as they come up; existing error snackbars stay as `ScaffoldMessenger` since those use the themed `SnackBarTheme` from Task 2, not this toast).

- [ ] **Step 1: Create the file**

```dart
import 'package:flutter/material.dart';

/// Floating dark pill toast, auto-dismisses after ~1.9s — matches the
/// design's toast (distinct from Material's full-width SnackBar, used
/// only for brief confirmations like "Đã lưu thay đổi").
void showNinoToast(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => Positioned(
      left: 18,
      right: 18,
      bottom: 96,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          decoration: BoxDecoration(
            color: const Color(0xFF22262C),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Color(0x59000000), blurRadius: 28, offset: Offset(0, 12))],
          ),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFF2F4F7), fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    ),
  );
  overlay.insert(entry);
  Future.delayed(const Duration(milliseconds: 1900), () {
    if (entry.mounted) entry.remove();
  });
}
```

- [ ] **Step 2: Run analyzer**

Run: `C:\flutter\bin\flutter.bat analyze lib/ui/widgets/nino/nino_toast.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/ui/widgets/nino/nino_toast.dart
git commit -m "feat(nino): add showNinoToast shared helper"
```

---

## Task 9: Shared widget — `showBottomOptionSheet` / `NinoOption`

**Files:**
- Create: `lib/ui/widgets/nino/bottom_option_sheet.dart`

**Interfaces:**
- Produces: `NinoOption({label, sublabel, icon, selected, onTap})`, `showBottomOptionSheet({context, title, options, doneLabel})` — used by Tasks 20 (Relative form: quan hệ), 22 (Event form: danh mục/lặp lại/nhắc nhở/người thân), and the Holidays task (chọn năm).

- [ ] **Step 1: Create the file**

```dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class NinoOption {
  final String label;
  final String? sublabel;
  final String icon; // emoji glyph, matches the design source
  final bool selected;
  final VoidCallback onTap;

  const NinoOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.sublabel,
  });
}

/// Bottom sheet with a title bar and a scrollable list of [NinoOption]s —
/// used for every "pick one of many" picker (quan hệ, danh mục, lặp lại,
/// nhắc nhở, năm, người thân).
Future<void> showBottomOptionSheet({
  required BuildContext context,
  required String title,
  required List<NinoOption> options,
  String doneLabel = 'Đóng',
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return showModalBottomSheet(
    context: context,
    backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    isScrollControlled: true,
    builder: (ctx) {
      final txt = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
      final mut = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
      final pri = isDark ? AppColors.primaryDark : AppColors.primaryLight;
      final priSoft = isDark ? AppColors.primarySoftDark : AppColors.primarySoftLight;
      final line2 = isDark ? AppColors.line2Dark : AppColors.line2Light;

      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.74),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 4),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: line2, borderRadius: BorderRadius.circular(999)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 6, 8, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: txt)),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(doneLabel, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: mut)),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 22),
                  itemCount: options.length,
                  itemBuilder: (context, i) {
                    final o = options[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      child: Material(
                        color: o.selected ? priSoft : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: o.onTap,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 12),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 26,
                                  child: Text(o.icon, style: const TextStyle(fontSize: 15), textAlign: TextAlign.center),
                                ),
                                const SizedBox(width: 11),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        o.label,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: o.selected ? FontWeight.w700 : FontWeight.w500,
                                          color: o.selected ? pri : txt,
                                        ),
                                      ),
                                      if (o.sublabel != null && o.sublabel!.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 1),
                                          child: Text(
                                            o.sublabel!,
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: mut),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (o.selected) Icon(Icons.check_rounded, size: 18, color: pri),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
```

- [ ] **Step 2: Run analyzer**

Run: `C:\flutter\bin\flutter.bat analyze lib/ui/widgets/nino/bottom_option_sheet.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/ui/widgets/nino/bottom_option_sheet.dart
git commit -m "feat(nino): add showBottomOptionSheet shared widget"
```

---

## Task 10: Shared widget — `StickySaveBar` / `showDeleteConfirmSheet`

**Files:**
- Create: `lib/ui/widgets/nino/sticky_action_bars.dart`

**Interfaces:**
- Produces: `StickySaveBar({label, onPressed, loading})` (used by Task 22, Add Event), `showDeleteConfirmSheet({context, title, message}) → Future<bool>` (used by Task 19, Relative detail). `HolidayActionBar` is **not** a shared file — the spec listed it as reusable, but it is only used once (Holidays screen), so it is defined inline in that task instead (YAGNI; noted here so the deviation from the spec's component table is intentional, not missed).

- [ ] **Step 1: Create the file**

```dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Sticky bottom bar with a single full-width CTA button — used on the
/// Add Event screen ("Lưu sự kiện").
class StickySaveBar extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  const StickySaveBar({super.key, required this.label, required this.onPressed, this.loading = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pri = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: isDark ? AppColors.navBarDark : AppColors.navBarLight,
        border: Border(top: BorderSide(color: isDark ? AppColors.lineDark : AppColors.lineLight)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: pri,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4),
                )
              : Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      ),
    );
  }
}

/// Confirm-delete bottom sheet — "Xoá {label} này?". Returns `true` if the
/// user tapped the destructive action, `false`/`null` (never — always
/// resolves to a bool) otherwise.
Future<bool> showDeleteConfirmSheet({
  required BuildContext context,
  required String title,
  required String message,
}) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final result = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
    builder: (ctx) {
      final txt = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
      final mut = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
      final line2 = isDark ? AppColors.line2Dark : AppColors.line2Light;
      final danger = isDark ? AppColors.errorDark : AppColors.error;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: txt)),
              const SizedBox(height: 7),
              Text(message, style: TextStyle(fontSize: 12, color: mut, height: 1.55)),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        side: BorderSide(color: line2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text('Giữ lại', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: txt)),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: danger,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Xoá', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
  return result ?? false;
}
```

- [ ] **Step 2: Run analyzer**

Run: `C:\flutter\bin\flutter.bat analyze lib/ui/widgets/nino/sticky_action_bars.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/ui/widgets/nino/sticky_action_bars.dart
git commit -m "feat(nino): add StickySaveBar/showDeleteConfirmSheet shared widget"
```

---

## Task 11: Redesign bottom navigation

**Files:**
- Modify: `lib/ui/widgets/bottom_nav_scaffold.dart` (full rewrite)

**Interfaces:**
- Consumes: `AppColors.{navBarLight,navBarDark,lineLight,lineDark,primaryLight,primaryDark,primarySoftLight,primarySoftDark,textSecondaryLight,textSecondaryDark}` (Task 1).

Note: the current nav shows an unread-count `Badge` on the "Tôi" tab (from `NotificationProvider.unreadCount`). The new design's bottom nav has no badge — the unread count stays visible via the bell icon on Home (kept in Task 17). This is a deliberate relocation, not a functionality loss.

- [ ] **Step 1: Replace the full content of `bottom_nav_scaffold.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

class BottomNavScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const BottomNavScaffold({super.key, required this.navigationShell});

  static const List<(IconData, String)> _items = [
    (Icons.home_rounded, 'Home'),
    (Icons.people_alt_rounded, 'Người thân'),
    (Icons.calendar_month_rounded, 'Sự kiện'),
    (Icons.person_rounded, 'Tôi'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pri = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final priSoft = isDark ? AppColors.primarySoftDark : AppColors.primarySoftLight;
    final mut = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.navBarDark : AppColors.navBarLight,
          border: Border(top: BorderSide(color: isDark ? AppColors.lineDark : AppColors.lineLight)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_items.length, (i) {
                final active = navigationShell.currentIndex == i;
                final (icon, label) = _items[i];
                return GestureDetector(
                  onTap: () => navigationShell.goBranch(i, initialLocation: i == navigationShell.currentIndex),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 34,
                          height: 28,
                          decoration: BoxDecoration(
                            color: active ? priSoft : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Icon(icon, size: 20, color: active ? pri : mut),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          label,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: active ? pri : mut),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Run analyzer**

Run: `C:\flutter\bin\flutter.bat analyze lib/ui/widgets/bottom_nav_scaffold.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/ui/widgets/bottom_nav_scaffold.dart
git commit -m "feat(nino): redesign bottom navigation with pill highlight"
```

---

## Task 12: Lunar calendar conversion utility + tests

**Files:**
- Create: `lib/core/utils/lunar_utils.dart`
- Test: `test/core/utils/lunar_utils_test.dart`

**Interfaces:**
- Produces: `LunarUtils.solarToLunar(DateTime date) → (int day, int month, int year, bool isLeapMonth)`, `LunarUtils.lunarToSolar(int day, int month, int year, {bool lunarLeap}) → DateTime`, `LunarUtils.lunarNewYear(int year) → DateTime` — consumed by Task 13 (`vn_holidays.dart`).

- [ ] **Step 1: Write the failing tests**

Create `test/core/utils/lunar_utils_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:event_app/core/utils/lunar_utils.dart';

void main() {
  group('LunarUtils.lunarToSolar — Tết Nguyên Đán (mùng 1 tháng Giêng)', () {
    test('2026 falls on 17/02/2026', () {
      expect(LunarUtils.lunarToSolar(1, 1, 2026), DateTime(2026, 2, 17));
    });
    test('2027 falls on 06/02/2027', () {
      expect(LunarUtils.lunarToSolar(1, 1, 2027), DateTime(2027, 2, 6));
    });
    test('2028 falls on 26/01/2028', () {
      expect(LunarUtils.lunarToSolar(1, 1, 2028), DateTime(2028, 1, 26));
    });
  });

  test('Giỗ Tổ Hùng Vương (10/03 ÂL) 2026 falls on 26/04/2026', () {
    expect(LunarUtils.lunarToSolar(10, 3, 2026), DateTime(2026, 4, 26));
  });

  test('lunarNewYear(2026) matches lunarToSolar(1, 1, 2026)', () {
    expect(LunarUtils.lunarNewYear(2026), DateTime(2026, 2, 17));
  });

  test('solarToLunar/lunarToSolar round-trip for an arbitrary date', () {
    final solar = DateTime(2026, 8, 29);
    final (day, month, year, leap) = LunarUtils.solarToLunar(solar);
    final back = LunarUtils.lunarToSolar(day, month, year, lunarLeap: leap);
    expect(back, solar);
  });
}
```

- [ ] **Step 2: Run tests to verify they fail (no implementation yet)**

Run: `C:\flutter\bin\flutter.bat test test/core/utils/lunar_utils_test.dart`
Expected: FAIL — `Error: Method not found: 'LunarUtils'` (or "package:event_app/core/utils/lunar_utils.dart" not found).

- [ ] **Step 3: Create `lib/core/utils/lunar_utils.dart`**

```dart
import 'dart:math' as math;

/// Vietnamese lunar calendar conversion — a Dart port of Hồ Ngọc Đức's
/// public-domain algorithm (http://www.informatik.uni-leipzig.de/~duc/amlich/),
/// fixed to Vietnam's timezone (UTC+7). No external package dependency.
class LunarUtils {
  static const int _vnTimeZone = 7;
  static const double _pi2 = 2 * math.pi;

  static int _jdFromDate(int dd, int mm, int yy) {
    final a = ((14 - mm) / 12).floor();
    final y = yy + 4800 - a;
    final m = mm + 12 * a - 3;
    var jd = dd +
        ((153 * m + 2) / 5).floor() +
        365 * y +
        (y / 4).floor() -
        (y / 100).floor() +
        (y / 400).floor() -
        32045;
    if (jd < 2299161) {
      jd = dd + ((153 * m + 2) / 5).floor() + 365 * y + (y / 4).floor() - 32083;
    }
    return jd;
  }

  static List<int> _jdToDate(int jd) {
    int a, b, c, d, e, m;
    if (jd > 2299160) {
      a = jd + 32044;
      b = ((4 * a + 3) / 146097).floor();
      c = a - ((b * 146097) / 4).floor();
    } else {
      b = 0;
      c = jd + 32082;
    }
    d = ((4 * c + 3) / 1461).floor();
    e = c - ((1461 * d) / 4).floor();
    m = ((5 * e + 2) / 153).floor();
    final day = e - ((153 * m + 2) / 5).floor() + 1;
    final month = m + 3 - 12 * (m / 10).floor();
    final year = b * 100 + d - 4800 + (m / 10).floor();
    return [day, month, year];
  }

  static double _newMoon(int k) {
    final t = k / 1236.85;
    final t2 = t * t;
    final t3 = t2 * t;
    final dr = math.pi / 180;
    var jd1 = 2415020.75933 + 29.53058868 * k + 0.0001178 * t2 - 0.000000155 * t3;
    jd1 += 0.00033 * math.sin((166.56 + 132.87 * t - 0.009173 * t2) * dr);
    final m = 359.2242 + 29.10535608 * k - 0.0000333 * t2 - 0.00000347 * t3;
    final mpr = 306.0253 + 385.81691806 * k + 0.0107306 * t2 + 0.00001236 * t3;
    final f = 21.2964 + 390.67050646 * k - 0.0016528 * t2 - 0.00000239 * t3;
    var c1 = (0.1734 - 0.000393 * t) * math.sin(m * dr) + 0.0021 * math.sin(2 * dr * m);
    c1 = c1 - 0.4068 * math.sin(mpr * dr) + 0.0161 * math.sin(dr * 2 * mpr);
    c1 = c1 - 0.0004 * math.sin(dr * 3 * mpr);
    c1 = c1 + 0.0104 * math.sin(dr * 2 * f) - 0.0051 * math.sin(dr * (m + mpr));
    c1 = c1 - 0.0074 * math.sin(dr * (m - mpr)) + 0.0004 * math.sin(dr * (2 * f + m));
    c1 = c1 - 0.0004 * math.sin(dr * (2 * f - m)) - 0.0006 * math.sin(dr * (2 * f + mpr));
    c1 = c1 + 0.0010 * math.sin(dr * (2 * f - mpr)) + 0.0005 * math.sin(dr * (2 * mpr + m));
    double deltat;
    if (t < -11) {
      deltat = 0.001 + 0.000839 * t + 0.0002261 * t2 - 0.00000845 * t3 - 0.000000081 * t * t3;
    } else {
      deltat = -0.000278 + 0.000265 * t + 0.000262 * t2;
    }
    return jd1 + c1 - deltat;
  }

  static int _sunLongitude(double jdn) {
    final t = (jdn - 2451545.0) / 36525;
    final t2 = t * t;
    final dr = math.pi / 180;
    final m = 357.52910 + 35999.05030 * t - 0.0001559 * t2 - 0.00000048 * t * t2;
    final l0 = 280.46645 + 36000.76983 * t + 0.0003032 * t2;
    var dl = (1.914600 - 0.004817 * t - 0.000014 * t2) * math.sin(dr * m);
    dl = dl + (0.019993 - 0.000101 * t) * math.sin(dr * 2 * m) + 0.000290 * math.sin(dr * 3 * m);
    var l = (l0 + dl) * dr;
    l = l - _pi2 * (l / _pi2).floor();
    // 12-bucket solar-term index (each bucket = 30° = π/6 rad), matching the
    // reference algorithm's `getSunLongitude` (`INT(SunLongitude(jdn)/PI*6)`).
    // NOT a 24-bucket (15°) division — that silently breaks the `sunLong >= 9`
    // (270°, winter solstice) threshold used by `_getLunarMonth11`.
    return (l / math.pi * 6).floor();
  }

  static int _getSunLongitude(int dayNumber, int timeZone) => _sunLongitude(dayNumber - 0.5 - timeZone / 24);

  static int _getNewMoonDay(int k, int timeZone) => (_newMoon(k) + 0.5 + timeZone / 24).floor();

  static int _getLunarMonth11(int yy, int timeZone) {
    final off = _jdFromDate(31, 12, yy) - 2415021;
    final k = (off / 29.530588853).floor();
    var nm = _getNewMoonDay(k, timeZone);
    final sunLong = _getSunLongitude(nm, timeZone);
    if (sunLong >= 9) {
      nm = _getNewMoonDay(k - 1, timeZone);
    }
    return nm;
  }

  static int _getLeapMonthOffset(int a11, int timeZone) {
    final k = (0.5 + (a11 - 2415021.076998695) / 29.530588853).floor();
    var last = 0;
    var i = 1;
    var arc = _getSunLongitude(_getNewMoonDay(k + i, timeZone), timeZone);
    do {
      last = arc;
      i++;
      arc = _getSunLongitude(_getNewMoonDay(k + i, timeZone), timeZone);
    } while (arc != last && i < 14);
    return i - 1;
  }

  /// Converts a solar (Gregorian) date to its Vietnamese lunar equivalent.
  /// Returns `(day, month, year, isLeapMonth)`.
  static (int, int, int, bool) solarToLunar(DateTime date) {
    final dayNumber = _jdFromDate(date.day, date.month, date.year);
    final k = ((dayNumber - 2415021.076998695) / 29.530588853).floor();
    var monthStart = _getNewMoonDay(k + 1, _vnTimeZone);
    if (monthStart > dayNumber) {
      monthStart = _getNewMoonDay(k, _vnTimeZone);
    }
    var a11 = _getLunarMonth11(date.year, _vnTimeZone);
    var b11 = a11;
    int lunarYear;
    if (a11 >= monthStart) {
      lunarYear = date.year;
      a11 = _getLunarMonth11(date.year - 1, _vnTimeZone);
    } else {
      lunarYear = date.year + 1;
      b11 = _getLunarMonth11(date.year + 1, _vnTimeZone);
    }
    final lunarDay = dayNumber - monthStart + 1;
    final diff = ((monthStart - a11) / 29).floor();
    var lunarLeap = false;
    var lunarMonth = diff + 11;
    if (b11 - a11 > 365) {
      final leapMonthDiff = _getLeapMonthOffset(a11, _vnTimeZone);
      if (diff >= leapMonthDiff) {
        lunarMonth = diff + 10;
        if (diff == leapMonthDiff) lunarLeap = true;
      }
    }
    if (lunarMonth > 12) lunarMonth -= 12;
    if (lunarMonth >= 11 && diff < 4) lunarYear -= 1;
    return (lunarDay, lunarMonth, lunarYear, lunarLeap);
  }

  /// Converts a Vietnamese lunar date to its solar (Gregorian) equivalent.
  /// [lunarLeap] must be true only when the date falls in a leap month;
  /// throws [ArgumentError] if [lunarMonth]/[lunarYear] has no leap month.
  static DateTime lunarToSolar(int lunarDay, int lunarMonth, int lunarYear, {bool lunarLeap = false}) {
    int a11, b11;
    if (lunarMonth < 11) {
      a11 = _getLunarMonth11(lunarYear - 1, _vnTimeZone);
      b11 = _getLunarMonth11(lunarYear, _vnTimeZone);
    } else {
      a11 = _getLunarMonth11(lunarYear, _vnTimeZone);
      b11 = _getLunarMonth11(lunarYear + 1, _vnTimeZone);
    }
    var off = lunarMonth - 11;
    if (off < 0) off += 12;
    if (b11 - a11 > 365) {
      final leapOff = _getLeapMonthOffset(a11, _vnTimeZone);
      var leapMonth = leapOff - 2;
      if (leapMonth < 0) leapMonth += 12;
      if (lunarLeap && lunarMonth != leapMonth) {
        throw ArgumentError('Tháng $lunarMonth/$lunarYear không có tháng nhuận.');
      } else if (lunarLeap || off >= leapOff) {
        off += 1;
      }
    }
    final k = (0.5 + (a11 - 2415021.076998695) / 29.530588853 + off).floor();
    final monthStart = _getNewMoonDay(k, _vnTimeZone);
    final ymd = _jdToDate(monthStart + lunarDay - 1);
    return DateTime(ymd[2], ymd[1], ymd[0]);
  }

  /// Solar date of Tết Nguyên Đán (mùng 1 tháng Giêng) for lunar [year].
  static DateTime lunarNewYear(int year) => lunarToSolar(1, 1, year);
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `C:\flutter\bin\flutter.bat test test/core/utils/lunar_utils_test.dart`
Expected: `All tests passed!`. If any date assertion fails, the arithmetic was mistyped during the port — compare the failing internal step against the reference algorithm at http://www.informatik.uni-leipzig.de/~duc/amlich/ (or any faithful port, e.g. search "jdFromDate NewMoon SunLongitude getLunarMonth11 Ho Ngoc Duc") rather than adjusting the known-answer test dates.

- [ ] **Step 5: Commit**

```bash
git add lib/core/utils/lunar_utils.dart test/core/utils/lunar_utils_test.dart
git commit -m "feat(nino): add LunarUtils Vietnamese lunar calendar conversion"
```

---

## Task 13: Vietnamese holidays static data

**Files:**
- Create: `lib/core/constants/vn_holidays.dart`

**Interfaces:**
- Consumes: `LunarUtils.solarToLunar`, `LunarUtils.lunarToSolar` (Task 12).
- Produces: `VnHolidayKind` enum, `VnHoliday`, `ResolvedVnHoliday`, `resolveVnHolidays(int year) → List<ResolvedVnHoliday>` (sorted chronologically) — consumed by Task 14 (Holidays screen).

- [ ] **Step 1: Create the file**

```dart
import 'package:event_app/core/utils/lunar_utils.dart';

enum VnHolidayKind { solar, lunar }

/// A Vietnamese holiday definition. Solar-fixed holidays give their solar
/// (month, day) directly; lunar-fixed holidays give their lunar (month,
/// day) and are converted to an actual solar date per year in
/// [resolveVnHolidays] — no per-year table is hard-coded (per spec §D).
class VnHoliday {
  final String icon;
  final String name;
  final VnHolidayKind kind;
  final bool official;
  final int officialDaysOff;
  final int month;
  final int day;

  const VnHoliday({
    required this.icon,
    required this.name,
    required this.kind,
    required this.official,
    required this.officialDaysOff,
    required this.month,
    required this.day,
  });
}

const List<VnHoliday> vnHolidays = [
  VnHoliday(icon: '🎉', name: 'Tết Dương lịch', kind: VnHolidayKind.solar, official: true, officialDaysOff: 1, month: 1, day: 1),
  VnHoliday(icon: '🧧', name: 'Tết Nguyên Đán', kind: VnHolidayKind.lunar, official: true, officialDaysOff: 5, month: 1, day: 1),
  VnHoliday(icon: '🏮', name: 'Rằm tháng Giêng', kind: VnHolidayKind.lunar, official: false, officialDaysOff: 0, month: 1, day: 15),
  VnHoliday(icon: '🏯', name: 'Giỗ Tổ Hùng Vương', kind: VnHolidayKind.lunar, official: true, officialDaysOff: 1, month: 3, day: 10),
  VnHoliday(icon: '🇻🇳', name: 'Ngày Chiến thắng 30/4', kind: VnHolidayKind.solar, official: true, officialDaysOff: 1, month: 4, day: 30),
  VnHoliday(icon: '🌏', name: 'Ngày Quốc tế Lao động', kind: VnHolidayKind.solar, official: true, officialDaysOff: 1, month: 5, day: 1),
  VnHoliday(icon: '🕯', name: 'Lễ Vu Lan', kind: VnHolidayKind.lunar, official: false, officialDaysOff: 0, month: 7, day: 15),
  VnHoliday(icon: '🇻🇳', name: 'Ngày Quốc khánh', kind: VnHolidayKind.solar, official: true, officialDaysOff: 2, month: 9, day: 2),
  VnHoliday(icon: '🌕', name: 'Tết Trung Thu', kind: VnHolidayKind.lunar, official: false, officialDaysOff: 0, month: 8, day: 15),
];

/// One [VnHoliday] resolved to a concrete solar date for a given year.
class ResolvedVnHoliday {
  final VnHoliday def;
  final DateTime solarDate;
  final String lunarText; // e.g. "01/01 ÂL"

  const ResolvedVnHoliday({required this.def, required this.solarDate, required this.lunarText});
}

/// Resolves every [vnHolidays] entry to an actual solar date for [year],
/// sorted chronologically.
List<ResolvedVnHoliday> resolveVnHolidays(int year) {
  final resolved = vnHolidays.map((h) {
    late DateTime solar;
    late String lunarText;
    if (h.kind == VnHolidayKind.solar) {
      solar = DateTime(year, h.month, h.day);
      final (ld, lm, ly, _) = LunarUtils.solarToLunar(solar);
      lunarText = '${ld.toString().padLeft(2, '0')}/${lm.toString().padLeft(2, '0')}${ly != year ? '/$ly' : ''} ÂL';
    } else {
      solar = LunarUtils.lunarToSolar(h.day, h.month, year);
      lunarText = '${h.day.toString().padLeft(2, '0')}/${h.month.toString().padLeft(2, '0')} ÂL';
    }
    return ResolvedVnHoliday(def: h, solarDate: solar, lunarText: lunarText);
  }).toList();
  resolved.sort((a, b) => a.solarDate.compareTo(b.solarDate));
  return resolved;
}
```

- [ ] **Step 2: Run analyzer**

Run: `C:\flutter\bin\flutter.bat analyze lib/core/constants/vn_holidays.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/core/constants/vn_holidays.dart
git commit -m "feat(nino): add static Vietnamese holidays resolved via LunarUtils"
```

---

## Task 14: Holidays screen, route, and Add-Event prefill hook

**Files:**
- Create: `lib/ui/screens/holidays/holiday_screen.dart`
- Test: `test/ui/screens/holidays/holiday_screen_test.dart`
- Modify: `lib/core/router/app_router.dart:119-131` (the `create` sub-route of `/events`)
- Modify: `lib/ui/screens/events/event_form_screen.dart:10-22` (constructor) and its `initState` (around line 91-100)

**Interfaces:**
- Consumes: `resolveVnHolidays`, `ResolvedVnHoliday`, `VnHolidayKind` (Task 13); `CardRow`, `SquareIconBadge` (Task 5); `SegmentedPillTabs` (Task 6); `showBottomOptionSheet`, `NinoOption` (Task 9); `AppColors.holidayHeroGradient` (Task 1).
- Produces: route `/events/holidays`; `EventFormScreen(prefillTitle:, prefillDate:)` optional constructor params, consumed (and must be preserved) by Task 22's full Add Event redesign.
- No entry-point link exists yet from the Sự kiện list into this screen — Task 21 adds it. This screen is independently testable via its widget test and by deep-linking to `/events/holidays`.

- [ ] **Step 1: Add prefill fields to `EventFormScreen`**

In `lib/ui/screens/events/event_form_screen.dart`, change the constructor (currently lines 10-22):

```dart
class EventFormScreen extends StatefulWidget {
  final bool isRelativeEvent;
  final int? eventId;
  final String? prefillTitle;
  final DateTime? prefillDate;

  const EventFormScreen({
    super.key,
    this.isRelativeEvent = true,
    this.eventId,
    this.prefillTitle,
    this.prefillDate,
  });

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}
```

Then in `_EventFormScreenState.initState()` (currently lines 91-100), add the prefill application as the first statement, before the existing `WidgetsBinding` callback:

```dart
  @override
  void initState() {
    super.initState();
    if (widget.eventId == null && widget.prefillTitle != null) {
      _titleController.text = widget.prefillTitle!;
      if (widget.prefillDate != null) _selectedDate = widget.prefillDate!;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RelativeProvider>().loadRelatives();
      if (widget.eventId != null) {
        _loadExistingEvent();
      }
    });
  }
```

- [ ] **Step 2: Wire the prefill through the router**

In `lib/core/router/app_router.dart`, replace the `create` route (currently lines 123-131):

```dart
                    GoRoute(
                      path: 'create',
                      builder: (context, state) {
                        final type = state.uri.queryParameters['type'];
                        final extra = state.extra as Map<String, dynamic>?;
                        return EventFormScreen(
                          isRelativeEvent: type != 'self',
                          prefillTitle: extra?['title'] as String?,
                          prefillDate: extra?['date'] as DateTime?,
                        );
                      },
                    ),
```

(Verify the exact current line range with `Grep -n "path: 'create'" lib/core/router/app_router.dart` before editing — it drifts slightly as unrelated commits land; at plan-writing time it was lines 122-129 inside the `/events` branch.)

Add the Holidays route as a new sibling right after it (still inside the `/events` branch's `routes:` list, alongside `'create'` and `':id'`):

```dart
                    GoRoute(
                      path: 'holidays',
                      builder: (context, state) => const HolidayScreen(),
                    ),
```

Add the import near the other screen imports at the top of the file:

```dart
import '../../ui/screens/holidays/holiday_screen.dart';
```

- [ ] **Step 3: Create `lib/ui/screens/holidays/holiday_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/vn_holidays.dart';
import '../../widgets/nino/card_row.dart';
import '../../widgets/nino/pill_tabs.dart';
import '../../widgets/nino/bottom_option_sheet.dart';

class HolidayScreen extends StatefulWidget {
  const HolidayScreen({super.key});

  @override
  State<HolidayScreen> createState() => _HolidayScreenState();
}

class _HolidayScreenState extends State<HolidayScreen> {
  static const _prefsKey = 'holiday_reminders';

  late int _year;
  String _filter = 'Tất cả';
  String? _selectedName;
  Set<String> _reminded = {};

  @override
  void initState() {
    super.initState();
    _year = DateTime.now().year;
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_prefsKey) ?? [];
    if (mounted) setState(() => _reminded = saved.toSet());
  }

  Future<void> _toggleReminder(String name) async {
    setState(() {
      if (_reminded.contains(name)) {
        _reminded.remove(name);
      } else {
        _reminded.add(name);
      }
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, _reminded.toList());
  }

  void _createEventFrom(ResolvedVnHoliday h) {
    setState(() => _selectedName = null);
    context.push('/events/create', extra: {'title': h.def.name, 'date': h.solarDate});
  }

  String _fmt(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _daysAway(DateTime target, DateTime today) {
    final t0 = DateTime(today.year, today.month, today.day);
    final diff = DateTime(target.year, target.month, target.day).difference(t0).inDays;
    if (diff < 0) return 'Đã qua';
    if (diff == 0) return 'Hôm nay';
    return '$diff ngày';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final txt = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mut = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final fnt = isDark ? AppColors.textFaintDark : AppColors.textFaintLight;
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final line = isDark ? AppColors.lineDark : AppColors.lineLight;
    final pri = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final priSoft = isDark ? AppColors.primarySoftDark : AppColors.primarySoftLight;
    final mint = isDark ? AppColors.secondaryDark : AppColors.secondaryLight;
    final mintSoft = isDark ? AppColors.secondarySoftDark : AppColors.secondarySoftLight;
    final amber = isDark ? AppColors.amberDark : AppColors.amberLight;
    final amberSoft = isDark ? AppColors.amberSoftDark : AppColors.amberSoftLight;

    final all = resolveVnHolidays(_year);
    final today = DateTime.now();
    final upcoming =
        all.where((h) => !h.solarDate.isBefore(DateTime(today.year, today.month, today.day))).toList();
    final next = upcoming.isNotEmpty ? upcoming.first : null;

    final filtered = _filter == 'Dương lịch'
        ? all.where((h) => h.def.kind == VnHolidayKind.solar).toList()
        : _filter == 'Âm lịch'
            ? all.where((h) => h.def.kind == VnHolidayKind.lunar).toList()
            : all;

    final officialCount = all.where((h) => h.def.official).length;
    final offDays = all.where((h) => h.def.official).fold<int>(0, (n, h) => n + h.def.officialDaysOff);

    ResolvedVnHoliday? selected;
    try {
      selected = _selectedName == null ? null : all.firstWhere((h) => h.def.name == _selectedName);
    } catch (_) {
      selected = null;
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 2, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left_rounded, color: txt),
                    onPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: Text('Lịch nghỉ lễ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: txt)),
                  ),
                  GestureDetector(
                    onTap: () => showBottomOptionSheet(
                      context: context,
                      title: 'Chọn năm',
                      options: [_year - 1, _year, _year + 1].map((y) {
                        return NinoOption(
                          label: '$y',
                          icon: '📅',
                          selected: y == _year,
                          onTap: () {
                            Navigator.of(context).pop();
                            setState(() {
                              _year = y;
                              _selectedName = null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: line),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('$_year', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: txt)),
                          const SizedBox(width: 5),
                          Icon(Icons.expand_more_rounded, size: 16, color: mut),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                    decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(18)),
                    child: Row(
                      children: [
                        SquareIconBadge(icon: Icons.flag_rounded, color: pri, background: priSoft, size: 36),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Lịch nghỉ lễ Việt Nam', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: txt)),
                              const SizedBox(height: 2),
                              Text(
                                '$officialCount dịp lễ chính · $offDays ngày nghỉ theo quy định $_year',
                                style: TextStyle(fontSize: 12, color: mut),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 11),
                  SegmentedPillTabs(
                    labels: const ['Tất cả', 'Dương lịch', 'Âm lịch'],
                    selected: _filter,
                    onChanged: (v) => setState(() => _filter = v),
                  ),
                  if (next != null) ...[
                    const SizedBox(height: 15),
                    Text('NGÀY LỄ SẮP TỚI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.9, color: fnt)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => setState(() => _selectedName = next.def.name),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(gradient: AppColors.holidayHeroGradient, borderRadius: BorderRadius.circular(18)),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.24), borderRadius: BorderRadius.circular(13)),
                              alignment: Alignment.center,
                              child: Text(next.def.icon, style: const TextStyle(fontSize: 18)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(next.def.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${_fmt(next.solarDate)} · ${next.lunarText}',
                                    style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.88)),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(999)),
                              child: Text(
                                _daysAway(next.solarDate, today),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 15),
                  Text(
                    _filter == 'Tất cả' ? 'Ngày lễ trong năm $_year' : '$_filter · $_year',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.9, color: fnt),
                  ),
                  const SizedBox(height: 9),
                  ...filtered.map((h) {
                    final isOn = _reminded.contains(h.def.name);
                    final isSelected = _selectedName == h.def.name;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: CardRow(
                        borderColor: isSelected ? pri : (isDark ? AppColors.lineDark : AppColors.lineLight),
                        onTap: () => setState(() => _selectedName = isSelected ? null : h.def.name),
                        leading: SquareIconBadge(
                          icon: Icons.celebration_rounded,
                          color: h.def.official ? pri : amber,
                          background: h.def.official ? priSoft : amberSoft,
                          size: 40,
                        ),
                        title: h.def.name,
                        meta: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_fmt(h.solarDate), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: txt)),
                            Text(h.lunarText, style: TextStyle(fontSize: 12, color: mut)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: h.def.official ? priSoft : amberSoft,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                h.def.official ? 'Ngày nghỉ chính thức' : 'Lễ truyền thống',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: h.def.official ? pri : amber),
                              ),
                            ),
                          ],
                        ),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(_daysAway(h.solarDate, today), style: TextStyle(fontSize: 12, color: mut)),
                            const SizedBox(height: 7),
                            GestureDetector(
                              onTap: () => _toggleReminder(h.def.name),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isOn ? mintSoft : Colors.transparent,
                                  border: Border.all(color: isOn ? Colors.transparent : (isDark ? AppColors.line2Dark : AppColors.line2Light)),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  isOn ? '🔔 Đã bật' : '🔔 Nhắc tôi',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isOn ? mint : mut),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 6),
                  Text(
                    'Ngày nghỉ thực tế có thể khác do trùng cuối tuần hoặc ngày nghỉ bù — theo thông báo chính thức hằng năm.',
                    style: TextStyle(fontSize: 12, color: fnt, height: 1.5),
                  ),
                ],
              ),
            ),
            if (selected != null)
              Container(
                padding: EdgeInsets.fromLTRB(16, 11, 16, 11 + MediaQuery.of(context).padding.bottom),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.navBarDark : AppColors.navBarLight,
                  border: Border(top: BorderSide(color: line)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(selected.def.icon, style: const TextStyle(fontSize: 15)),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            '${selected.def.name} · ${_fmt(selected.solarDate)}',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: txt),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(() => _selectedName = null),
                          child: Text('Bỏ chọn', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: mut)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () => _toggleReminder(selected!.def.name),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                            side: BorderSide(color: isDark ? AppColors.line2Dark : AppColors.line2Light),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('🔔', style: TextStyle(fontSize: 14)),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _createEventFrom(selected!),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: pri,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text('+ Tạo sự kiện', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Write the widget test**

Create `test/ui/screens/holidays/holiday_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:event_app/ui/screens/holidays/holiday_screen.dart';

void main() {
  testWidgets('HolidayScreen renders the current-year summary without throwing', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: HolidayScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Lịch nghỉ lễ'), findsOneWidget);
    expect(find.text('Tết Nguyên Đán'), findsOneWidget);
  });
}
```

- [ ] **Step 5: Run the test**

Run: `C:\flutter\bin\flutter.bat test test/ui/screens/holidays/holiday_screen_test.dart`
Expected: `All tests passed!`

- [ ] **Step 6: Run analyzer on every touched file**

Run: `C:\flutter\bin\flutter.bat analyze lib/ui/screens/holidays/holiday_screen.dart lib/core/router/app_router.dart lib/ui/screens/events/event_form_screen.dart`
Expected: `No issues found!`

- [ ] **Step 7: Commit**

```bash
git add lib/ui/screens/holidays/holiday_screen.dart test/ui/screens/holidays/holiday_screen_test.dart lib/core/router/app_router.dart lib/ui/screens/events/event_form_screen.dart
git commit -m "feat(nino): add Holidays screen, route, and Add Event prefill hook"
```

---

## Task 15: Redesign Welcome/Login screen

**Files:**
- Modify: `lib/ui/screens/auth/login_screen.dart` (full rewrite)

**Interfaces:**
- Consumes: `NinoLogo` (Task 3), `AppColors.*` (Task 1). Keeps `AuthProvider.login`/`loginWithGoogle` calls and `/register` navigation unchanged.

Note: the current screen has an email/password form; the design's Welcome screen is Google-only (2 buttons: "Tiếp tục với Google" and "Tạo tài khoản mới"), matching `RegisterScreen`'s existing Google-only flow. Email/password `login()` on `AuthProvider` is dropped from the UI here — do not delete `AuthProvider.login` itself (out of scope), just stop calling it from this screen, matching the design exactly.

- [ ] **Step 1: Replace the full content of `login_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/nino/nino_logo.dart';
import '../../widgets/nino/nino_toast.dart';
import '../../widgets/google_signin_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isGoogleLoading = false;

  Future<void> _loginWithGoogle() async {
    setState(() => _isGoogleLoading = true);
    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.loginWithGoogle();
      if (!mounted) return;
      if (success) {
        context.go('/home');
      } else if (authProvider.error != null) {
        showNinoToast(context, authProvider.error ?? 'Đăng nhập Google thất bại');
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  static const _features = [
    (icon: '🔔', title: 'Nhắc nhở thông minh', sub: 'Không bỏ lỡ ngày quan trọng'),
    (icon: '👨‍👩‍👧', title: 'Quản lý người thân', sub: 'Sinh nhật & kỷ niệm mọi người'),
    (icon: '📅', title: 'Lịch sự kiện', sub: 'Dương lịch & âm lịch trong một chỗ'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final txt = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mut = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final line = isDark ? AppColors.lineDark : AppColors.lineLight;
    final pri = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final priSoft = isDark ? AppColors.primarySoftDark : AppColors.primarySoftLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => context.read<ThemeProvider>().toggleTheme(),
                  icon: Icon(isDark ? Icons.wb_sunny_rounded : Icons.dark_mode_rounded, color: txt),
                  style: IconButton.styleFrom(
                    backgroundColor: card,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999), side: BorderSide(color: line)),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Column(
                  children: [
                    const NinoLogo(size: 84),
                    const SizedBox(height: 16),
                    Text('nino', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, letterSpacing: -1.2, color: txt)),
                    const SizedBox(height: 2),
                    Text(
                      'NEVER IGNORE NEAR ONES',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 2.6, color: mut),
                    ),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        'Đồng hành ngày & đêm — không bao giờ để lỡ những khoảnh khắc bên người thân.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: mut, height: 1.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ..._features.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: card,
                        border: Border.all(color: line),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [BoxShadow(color: isDark ? AppColors.shadowDark : AppColors.shadowLight, blurRadius: 10, offset: const Offset(0, 2))],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(color: priSoft, borderRadius: BorderRadius.circular(13)),
                            alignment: Alignment.center,
                            child: Text(f.icon, style: const TextStyle(fontSize: 18)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(f.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: txt)),
                                const SizedBox(height: 2),
                                Text(f.sub, style: TextStyle(fontSize: 12, color: mut)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: 24),
              GoogleSignInButton(isLoading: _isGoogleLoading, onPressed: _loginWithGoogle),
              const SizedBox(height: 11),
              Row(
                children: [
                  Expanded(child: Divider(color: line)),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 11), child: Text('hoặc', style: TextStyle(fontSize: 12, color: mut))),
                  Expanded(child: Divider(color: line)),
                ],
              ),
              const SizedBox(height: 11),
              OutlinedButton(
                onPressed: () => context.go('/register'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: priSoft,
                  side: BorderSide(color: pri, width: 1.5, style: BorderStyle.solid),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Tạo tài khoản mới →', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: pri)),
              ),
              const SizedBox(height: 11),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'Bằng cách tiếp tục, bạn đồng ý với Điều khoản dịch vụ và Chính sách bảo mật.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: mut, height: 1.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Run analyzer**

Run: `C:\flutter\bin\flutter.bat analyze lib/ui/screens/auth/login_screen.dart`
Expected: `No issues found!` (if `AppTextStyles` import removal leaves other unused imports, remove them).

- [ ] **Step 3: Commit**

```bash
git add lib/ui/screens/auth/login_screen.dart
git commit -m "feat(nino): redesign Welcome/Login screen"
```

---

## Task 16: Redesign Sign-up screen

**Files:**
- Modify: `lib/ui/screens/auth/register_screen.dart` (full rewrite)

**Interfaces:**
- Consumes: `NinoLogo` (Task 3), `AppColors.signupGradient` (Task 1). Keeps `AuthProvider.loginWithGoogle`, `ThemeProvider.toggleTheme`/`isDarkMode`, and `/login` navigation unchanged.

- [ ] **Step 1: Replace the full content of `register_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/nino/nino_logo.dart';
import '../../widgets/nino/nino_toast.dart';
import '../../widgets/google_logo.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _selectedMeaningIndex = 0;
  bool _isGoogleLoading = false;

  static const _meanings = [
    (sub: 'Never Ignore Near Ones'),
    (sub: 'Notes In Near Order'),
    (sub: 'Night & Noon — mọi lúc bên bạn'),
  ];

  static const _perks = [
    (icon: '🎂', label: 'Nhắc sinh nhật & kỷ niệm tự động'),
    (icon: '🔔', label: 'Thông báo trước 1–7 ngày tuỳ chỉnh'),
    (icon: '🌕', label: 'Lịch âm: ngày giỗ, rằm, mùng một'),
    (icon: '🎁', label: 'Gợi ý quà tặng theo từng dịp'),
  ];

  Future<void> _registerWithGoogle() async {
    setState(() => _isGoogleLoading = true);
    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.loginWithGoogle();
      if (!mounted) return;
      if (success) {
        context.go('/home');
      } else if (authProvider.error != null) {
        showNinoToast(context, authProvider.error ?? 'Đăng ký bằng Google thất bại');
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final txt = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mut = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final line = isDark ? AppColors.lineDark : AppColors.lineLight;
    final pri = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final priSoft = isDark ? AppColors.primarySoftDark : AppColors.primarySoftLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => context.canPop() ? context.pop() : context.go('/login'),
                    icon: Icon(Icons.chevron_left_rounded, color: txt),
                    style: IconButton.styleFrom(backgroundColor: card, shape: CircleBorder(side: BorderSide(color: line))),
                  ),
                  IconButton(
                    onPressed: () => context.read<ThemeProvider>().toggleTheme(),
                    icon: Icon(isDark ? Icons.wb_sunny_rounded : Icons.dark_mode_rounded, color: txt),
                    style: IconButton.styleFrom(backgroundColor: card, shape: CircleBorder(side: BorderSide(color: line))),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const NinoLogo(size: 52),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('TẠO TÀI KHOẢN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.6, color: mut)),
                              const SizedBox(height: 3),
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.4, color: txt),
                                  children: [
                                    const TextSpan(text: 'Bắt đầu với '),
                                    TextSpan(text: 'NINO', style: TextStyle(color: pri)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: line),
                        boxShadow: [BoxShadow(color: isDark ? AppColors.shadowDark : AppColors.shadowLight, blurRadius: 10, offset: const Offset(0, 2))],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15, 13, 15, 11),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: mut),
                                  children: [const TextSpan(text: 'Ý nghĩa của '), TextSpan(text: 'NINO', style: TextStyle(color: pri))],
                                ),
                              ),
                            ),
                          ),
                          ...List.generate(_meanings.length, (i) {
                            final isSelected = _selectedMeaningIndex == i;
                            return InkWell(
                              onTap: () => setState(() => _selectedMeaningIndex = i),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                                decoration: BoxDecoration(border: Border(top: BorderSide(color: line))),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 19,
                                      height: 19,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: isSelected ? pri : line, width: isSelected ? 2 : 2),
                                        color: isSelected ? priSoft : Colors.transparent,
                                      ),
                                      child: isSelected ? Center(child: Container(width: 9, height: 9, decoration: BoxDecoration(color: pri, shape: BoxShape.circle))) : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('N·I·N·O', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: isSelected ? pri : txt)),
                                          const SizedBox(height: 2),
                                          Text(_meanings[i].sub, style: TextStyle(fontSize: 12, color: mut)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    ..._perks.map((p) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(color: priSoft, borderRadius: BorderRadius.circular(11)),
                                alignment: Alignment.center,
                                child: Text(p.icon, style: const TextStyle(fontSize: 15)),
                              ),
                              const SizedBox(width: 11),
                              Expanded(child: Text(p.label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: txt))),
                              Icon(Icons.check_rounded, size: 17, color: pri),
                            ],
                          ),
                        )),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: card,
                  border: Border.all(color: line),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: isDark ? AppColors.shadowDark : AppColors.shadowLight, blurRadius: 10, offset: const Offset(0, 2))],
                ),
                child: Column(
                  children: [
                    Text(
                      'Đăng ký miễn phí bằng tài khoản Google — nhanh & bảo mật',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: mut, height: 1.55),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(gradient: AppColors.signupGradient, borderRadius: BorderRadius.circular(15)),
                      child: ElevatedButton(
                        onPressed: _isGoogleLoading ? null : _registerWithGoogle,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                        child: _isGoogleLoading
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4))
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                    child: const Padding(padding: EdgeInsets.all(2), child: GoogleLogo(size: 16)),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text('Đăng ký với Google', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 12, color: mut),
                          children: [const TextSpan(text: 'Đã có tài khoản? '), TextSpan(text: 'Đăng nhập ngay', style: TextStyle(fontWeight: FontWeight.w700, color: txt))],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
              child: Text(
                'Bằng cách đăng ký, bạn đồng ý với Điều khoản và Chính sách bảo mật.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: mut, height: 1.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Run analyzer**

Run: `C:\flutter\bin\flutter.bat analyze lib/ui/screens/auth/register_screen.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/ui/screens/auth/register_screen.dart
git commit -m "feat(nino): redesign Sign-up screen"
```

---

## Task 17: Redesign Home screen

**Files:**
- Modify: `lib/ui/screens/home/home_screen.dart` (full rewrite)

**Interfaces:**
- Consumes: `NinoLogo`, `InitialsAvatar`, `CardRow`, `SquareIconBadge`, `PillTabs`, `AppColors.groupType{Colors,ColorsDark,SoftColors,SoftColorsDark}` (Tasks 1, 3-6). Keeps `HomeProvider.refresh`/`homeData`/`myEvents`, `AuthProvider.user`, `NotificationProvider.unreadCount`, and all existing `go_router` paths unchanged. Adds a theme-toggle button (`ThemeProvider.toggleTheme`) to the header, matching the design (not present in the old Home screen).

- [ ] **Step 1: Replace the full content of `home_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../providers/home_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../models/event.dart';
import '../../../models/relative.dart';
import '../../widgets/nino/nino_logo.dart';
import '../../widgets/nino/initials_avatar.dart';
import '../../widgets/nino/card_row.dart';
import '../../widgets/nino/pill_tabs.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;

  static const List<List<Color>> _upcomingGradients = [
    [Color(0xFFFF8080), Color(0xFFFF5A5F)],
    [Color(0xFFFFD558), Color(0xFFFFB627)],
    [Color(0xFFBBA5FB), Color(0xFF9C81F0)],
    [Color(0xFF66DCD3), Color(0xFF3EC0B7)],
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final user = context.watch<AuthProvider>().user;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final homeData = homeProvider.homeData;
    final userName = homeData?.userName ?? user?.fullName ?? 'Khách';
    final avatarUrl = homeData?.avatarUrl ?? user?.avatarUrl;
    final unreadCount = context.watch<NotificationProvider>().unreadCount;

    final txt = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mut = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final line = isDark ? AppColors.lineDark : AppColors.lineLight;
    final pri = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final priSoft = isDark ? AppColors.primarySoftDark : AppColors.primarySoftLight;
    final mint = isDark ? AppColors.secondaryDark : AppColors.secondaryLight;
    final mintSoft = isDark ? AppColors.secondarySoftDark : AppColors.secondarySoftLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<HomeProvider>().refresh(),
          child: homeProvider.isLoading && homeData == null
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeader(context, userName, avatarUrl, isDark, unreadCount, txt, mut, card, line)),
                    if (homeData != null && homeData.upcomingEvents.isNotEmpty)
                      SliverToBoxAdapter(child: _buildUpcomingEventsSection(context, homeData.upcomingEvents, txt, mut, pri)),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: PillTabs(
                          labels: const ['Người thân', 'Sự kiện của tôi'],
                          selectedIndex: _selectedTab,
                          onChanged: (i) => setState(() => _selectedTab = i),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 13)),
                    SliverToBoxAdapter(
                      child: _selectedTab == 0
                          ? _buildRelativesTab(context, homeData?.relatives ?? [], isDark, mut, pri, priSoft)
                          : _buildMyEventsTab(context, homeProvider.myEvents, isDark, mut, mint, mintSoft),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 40)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String userName, String? avatarUrl, bool isDark, int unreadCount,
      Color txt, Color mut, Color card, Color line) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => context.go('/profile'),
              child: Row(
                children: [
                  InitialsAvatar(
                    name: userName,
                    color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                    softColor: isDark ? AppColors.primarySoftDark : AppColors.primarySoftLight,
                    radius: 21,
                    avatarUrl: avatarUrl,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const NinoLogo(size: 17, showBadge: false),
                            const SizedBox(width: 6),
                            Text('Xin chào 👋', style: TextStyle(fontSize: 12, color: mut, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const SizedBox(height: 1),
                        Text('Hi, $userName',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: txt),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => context.read<ThemeProvider>().toggleTheme(),
                icon: Icon(isDark ? Icons.wb_sunny_rounded : Icons.dark_mode_rounded, color: txt, size: 19),
                style: IconButton.styleFrom(backgroundColor: card, shape: CircleBorder(side: BorderSide(color: line))),
              ),
              const SizedBox(width: 8),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: () => context.push('/profile/notifications'),
                    icon: Icon(Icons.notifications_none_rounded, color: mut, size: 21),
                    style: IconButton.styleFrom(backgroundColor: card, shape: CircleBorder(side: BorderSide(color: line))),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      top: -1,
                      right: -1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                          border: Border.all(color: isDark ? AppColors.bgDark : AppColors.bgLight, width: 2),
                        ),
                        alignment: Alignment.center,
                        child: Text('$unreadCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEventsSection(BuildContext context, List<EventModel> events, Color txt, Color mut, Color pri) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sự kiện sắp tới', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: txt)),
              GestureDetector(
                onTap: () => context.push('/events'),
                child: Text('Xem tất cả →', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: pri)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 152,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(18, 2, 6, 6),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              final days = event.daysUntil ?? 0;
              final big = days == 0 ? 'Hôm nay' : '$days';
              final gradient = _upcomingGradients[index % _upcomingGradients.length];
              return GestureDetector(
                onTap: () => context.push('/events/${event.id}'),
                child: Container(
                  width: 142,
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.26), borderRadius: BorderRadius.circular(10)),
                        alignment: Alignment.center,
                        child: Icon(event.eventTypeIcon, color: Colors.white, size: 15),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(big, style: TextStyle(fontSize: days == 0 ? 22 : 36, fontWeight: FontWeight.w700, color: Colors.white, height: 1.05)),
                          const SizedBox(height: 6),
                          Text(event.title,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text(
                            event.relativeName ?? event.eventTypeDisplay,
                            style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.85)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRelativesTab(BuildContext context, List<RelativeModel> relatives, bool isDark, Color mut, Color pri, Color priSoft) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: [
          if (relatives.isEmpty)
            Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Text('Chưa có người thân nào', style: TextStyle(color: mut)))
          else
            ...relatives.map((rel) {
              final color = isDark
                  ? (AppColors.groupTypeColorsDark[rel.groupType] ?? AppColors.primaryDark)
                  : (AppColors.groupTypeColors[rel.groupType] ?? AppColors.primaryLight);
              final softColor = isDark
                  ? (AppColors.groupTypeSoftColorsDark[rel.groupType] ?? AppColors.primarySoftDark)
                  : (AppColors.groupTypeSoftColors[rel.groupType] ?? AppColors.primarySoftLight);
              return Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: CardRow(
                  onTap: () => context.push('/relatives/${rel.id}'),
                  leading: InitialsAvatar(name: rel.displayName, color: color, softColor: softColor, radius: 21, avatarUrl: rel.avatarUrl),
                  title: rel.displayName,
                  meta: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: softColor, borderRadius: BorderRadius.circular(6)),
                    child: Text(rel.groupTypeDisplay, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
                  ),
                  trailing: rel.daysUntilBirthday != null
                      ? Container(
                          width: 42,
                          height: 40,
                          decoration: BoxDecoration(color: softColor, borderRadius: BorderRadius.circular(13)),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${rel.daysUntilBirthday}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color, height: 1)),
                              Text('ngày', style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.8))),
                            ],
                          ),
                        )
                      : null,
                ),
              );
            }),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => context.push('/relatives/create'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: priSoft, borderRadius: BorderRadius.circular(18), border: Border.all(color: pri.withValues(alpha: 0.4))),
              alignment: Alignment.center,
              child: Text('+ Thêm người thân', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: pri)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyEventsTab(BuildContext context, List<EventModel> events, bool isDark, Color mut, Color mint, Color mintSoft) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: [
          if (events.isEmpty)
            Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Text('Chưa có sự kiện nào', style: TextStyle(color: mut)))
          else
            ...events.map((event) {
              final typeColor = event.categoryColorValue;
              final isNegative = event.daysUntil != null && event.daysUntil! < 0;
              final countColor = isNegative ? AppColors.error : mint;
              return Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: CardRow(
                  onTap: () => context.push('/events/${event.id}'),
                  leading: SquareIconBadge(icon: event.eventTypeIcon, color: typeColor, background: typeColor.withValues(alpha: 0.15)),
                  title: event.title,
                  meta: Row(
                    children: [
                      Text(_formatDate(event.eventDate), style: TextStyle(fontSize: 12, color: mut)),
                      if (event.isRecurring) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.neutralSoftDark : AppColors.neutralSoftLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('↻', style: TextStyle(fontSize: 11, color: mut)),
                        ),
                      ],
                    ],
                  ),
                  trailing: event.daysUntil != null
                      ? Text(event.daysUntilText, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: countColor))
                      : null,
                ),
              );
            }),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => context.push('/events/new'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: mintSoft, borderRadius: BorderRadius.circular(18), border: Border.all(color: mint.withValues(alpha: 0.4))),
              alignment: Alignment.center,
              child: Text('+ Thêm sự kiện của tôi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: mint)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
```

- [ ] **Step 2: Run analyzer**

Run: `C:\flutter\bin\flutter.bat analyze lib/ui/screens/home/home_screen.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/ui/screens/home/home_screen.dart
git commit -m "feat(nino): redesign Home screen"
```

---

## Task 18: Redesign Relative list screen

**Files:**
- Modify: `lib/ui/screens/relatives/relative_list_screen.dart` (full rewrite)

**Interfaces:**
- Consumes: `InitialsAvatar`, `CardRow`, `FilterChipsRow`, `AppColors.groupType{Colors,ColorsDark,SoftColors,SoftColorsDark}` (Tasks 1, 4-6). Keeps `RelativeProvider.{loadRelatives,loadGroupSummary,setGroupFilter,relatives,groupSummary,filterGroupType,isLoading}` unchanged.

Note: the design's "Người thân" mock has no group-type filter (it's a flat list). The current app has a working group-filter (4 group types, via `RelativeProvider.setGroupFilter`) that the design doesn't show — this is real functionality, not a mockup gap, so it is kept but reskinned as a `FilterChipsRow` instead of the old 2×2 gradient-header grid. The search box (`TextField` + `RelativeProvider.setSearchQuery`) from the old screen is dropped: it has no equivalent in the new design and duplicates the filter chips' purpose for this list size — do not port it.

- [ ] **Step 1: Replace the full content of `relative_list_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/relative_provider.dart';
import '../../widgets/nino/initials_avatar.dart';
import '../../widgets/nino/card_row.dart';
import '../../widgets/nino/pill_tabs.dart';

class RelativeListScreen extends StatefulWidget {
  const RelativeListScreen({super.key});

  @override
  State<RelativeListScreen> createState() => _RelativeListScreenState();
}

class _RelativeListScreenState extends State<RelativeListScreen> {
  static const _groupLabels = {
    'GIA_DINH': 'Gia đình',
    'VO_CHONG': 'Vợ/Chồng',
    'CON_CAI': 'Con cái',
    'BAN_BE': 'Bạn bè',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<RelativeProvider>();
      provider.loadRelatives();
      provider.loadGroupSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RelativeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final txt = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mut = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final fnt = isDark ? AppColors.textFaintDark : AppColors.textFaintLight;
    final pri = isDark ? AppColors.primaryDark : AppColors.primaryLight;

    final total = provider.groupSummary.fold<int>(0, (sum, s) => sum + s.count);
    final filterLabels = ['Tất cả', ..._groupLabels.values];
    final selectedLabel = provider.filterGroupType == null ? 'Tất cả' : (_groupLabels[provider.filterGroupType] ?? 'Tất cả');

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Người thân', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.6, color: txt)),
                  GestureDetector(
                    onTap: () => context.push('/relatives/create'),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: pri,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: pri.withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 6))],
                      ),
                      child: const Icon(Icons.add_rounded, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
              child: Align(alignment: Alignment.centerLeft, child: Text('$total người', style: TextStyle(fontSize: 12, color: mut))),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: FilterChipsRow(
                labels: filterLabels,
                selected: selectedLabel,
                onChanged: (label) {
                  final key = label == 'Tất cả' ? null : _groupLabels.entries.firstWhere((e) => e.value == label).key;
                  context.read<RelativeProvider>().setGroupFilter(key);
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.relatives.isEmpty
                      ? Center(child: Text('Chưa có người thân nào', style: TextStyle(color: mut)))
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                          itemCount: provider.relatives.length,
                          itemBuilder: (context, index) {
                            final rel = provider.relatives[index];
                            final color = isDark
                                ? (AppColors.groupTypeColorsDark[rel.groupType] ?? AppColors.primaryDark)
                                : (AppColors.groupTypeColors[rel.groupType] ?? AppColors.primaryLight);
                            final softColor = isDark
                                ? (AppColors.groupTypeSoftColorsDark[rel.groupType] ?? AppColors.primarySoftDark)
                                : (AppColors.groupTypeSoftColors[rel.groupType] ?? AppColors.primarySoftLight);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 9),
                              child: CardRow(
                                onTap: () => context.push('/relatives/${rel.id}'),
                                leading: InitialsAvatar(name: rel.displayName, color: color, softColor: softColor, radius: 23, avatarUrl: rel.avatarUrl),
                                title: rel.displayName,
                                meta: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${rel.genderDisplay} · ${rel.groupTypeDisplay}', style: TextStyle(fontSize: 12, color: fnt)),
                                    if (rel.daysUntilBirthday != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 3),
                                        child: Text('🎂 Sinh nhật còn ${rel.daysUntilBirthday} ngày',
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
                                      ),
                                  ],
                                ),
                                trailing: Icon(Icons.chevron_right_rounded, color: fnt),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Run analyzer**

Run: `C:\flutter\bin\flutter.bat analyze lib/ui/screens/relatives/relative_list_screen.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/ui/screens/relatives/relative_list_screen.dart
git commit -m "feat(nino): redesign Relative list screen"
```

---

## Task 19: Redesign Relative detail screen

**Files:**
- Modify: `lib/ui/screens/relatives/relative_detail_screen.dart` (full rewrite)

**Interfaces:**
- Consumes: `InitialsAvatar` (Task 4), `CardRow`/`SquareIconBadge` (Task 5), `showDeleteConfirmSheet` (Task 10), `showNinoToast` (Task 8). Keeps `RelativeProvider.{loadRelativeDetail,selectedRelative,deleteRelative,isLoading}` and the `/relatives/:id/edit`, `/events/create?type=relative` routes unchanged.

- [ ] **Step 1: Replace the full content of `relative_detail_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/relative_provider.dart';
import '../../../models/relative.dart';
import '../../widgets/nino/initials_avatar.dart';
import '../../widgets/nino/card_row.dart';
import '../../widgets/nino/sticky_action_bars.dart';
import '../../widgets/nino/nino_toast.dart';

String _formatSpecs(RelativeDetailModel r) {
  final parts = <String>[
    if (r.heightCm != null) '${r.heightCm} cm',
    if (r.weightKg != null) '${r.weightKg} kg',
  ];
  return parts.isEmpty ? '—' : parts.join(' · ');
}

class RelativeDetailScreen extends StatefulWidget {
  final int id;
  const RelativeDetailScreen({super.key, required this.id});

  @override
  State<RelativeDetailScreen> createState() => _RelativeDetailScreenState();
}

class _RelativeDetailScreenState extends State<RelativeDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RelativeProvider>().loadRelativeDetail(widget.id);
    });
  }

  Future<void> _confirmDelete(String name) async {
    final confirmed = await showDeleteConfirmSheet(
      context: context,
      title: 'Xoá $name?',
      message: 'Toàn bộ sự kiện và lời nhắc của người này sẽ bị xoá.',
    );
    if (!confirmed || !mounted) return;
    final success = await context.read<RelativeProvider>().deleteRelative(widget.id);
    if (mounted && success) {
      showNinoToast(context, 'Đã xoá người thân');
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RelativeProvider>();
    final relative = provider.selectedRelative;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final txt = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mut = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final fnt = isDark ? AppColors.textFaintDark : AppColors.textFaintLight;
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final line = isDark ? AppColors.lineDark : AppColors.lineLight;
    final pri = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final priSoft = isDark ? AppColors.primarySoftDark : AppColors.primarySoftLight;
    final mint = isDark ? AppColors.secondaryDark : AppColors.secondaryLight;
    final mintSoft = isDark ? AppColors.secondarySoftDark : AppColors.secondarySoftLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: provider.isLoading || relative == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 26),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: Icon(Icons.chevron_left_rounded, color: txt),
                          style: IconButton.styleFrom(backgroundColor: card, shape: CircleBorder(side: BorderSide(color: line))),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => _confirmDelete(relative.displayName),
                              icon: Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                            ),
                            GestureDetector(
                              onTap: () => context.push('/relatives/${widget.id}/edit'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
                                decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(999), border: Border.all(color: line)),
                                child: Text('Sửa', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: txt)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    InitialsAvatar(name: relative.displayName, color: pri, softColor: priSoft, radius: 40, avatarUrl: relative.avatarUrl),
                    const SizedBox(height: 11),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(relative.displayName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.4, color: txt)),
                        const SizedBox(width: 8),
                        Text('· ${relative.age ?? '?'} tuổi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: mut)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: priSoft, borderRadius: BorderRadius.circular(7)),
                      child: Text(relative.groupTypeDisplay, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: pri)),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(18), border: Border.all(color: line)),
                      child: Column(
                        children: [
                          _infoRow('Giới tính', relative.genderDisplay, mut, txt, line),
                          _infoRow('Ngày sinh', relative.dateOfBirth != null ? DateFormat('dd/MM/yyyy').format(relative.dateOfBirth!) : '—', mut, txt, line),
                          _infoRow('Nơi ở', relative.location ?? '—', mut, txt, line),
                          _infoRow('Thông số', _formatSpecs(relative), mut, txt, line, isLast: relative.hobbies == null || relative.hobbies!.isEmpty),
                          if (relative.hobbies != null && relative.hobbies!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: relative.hobbies!
                                      .map((h) => Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                                            decoration: BoxDecoration(color: mintSoft, borderRadius: BorderRadius.circular(999)),
                                            child: Text(h, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: mint)),
                                          ))
                                      .toList(),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Sự kiện của ${relative.displayName}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: txt)),
                        Text('${relative.relatedEvents.length} sự kiện', style: TextStyle(fontSize: 12, color: fnt)),
                      ],
                    ),
                    const SizedBox(height: 11),
                    if (relative.relatedEvents.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(18), border: Border.all(color: line)),
                        alignment: Alignment.center,
                        child: Text('Chưa có sự kiện nào cho ${relative.displayName}', textAlign: TextAlign.center, style: TextStyle(color: mut)),
                      )
                    else
                      ...relative.relatedEvents.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 9),
                            child: CardRow(
                              leading: SquareIconBadge(icon: e.eventTypeIcon, color: e.categoryColorValue, background: e.categoryColorValue.withValues(alpha: 0.15)),
                              title: e.title,
                              meta: Text(DateFormat('dd/MM/yyyy').format(e.eventDate), style: TextStyle(fontSize: 12, color: mut)),
                              trailing: e.daysUntil != null ? Text(e.daysUntilText, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: mint)) : null,
                            ),
                          )),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => context.push('/events/create?type=relative'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(color: priSoft, borderRadius: BorderRadius.circular(999)),
                          child: Text('＋ Thêm sự kiện', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: pri)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _infoRow(String label, String value, Color mut, Color txt, Color line, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(border: isLast ? null : Border(bottom: BorderSide(color: line))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: mut)),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: txt)),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Run analyzer**

Run: `C:\flutter\bin\flutter.bat analyze lib/ui/screens/relatives/relative_detail_screen.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/ui/screens/relatives/relative_detail_screen.dart
git commit -m "feat(nino): redesign Relative detail screen"
```

---

## Task 20: Redesign Add/Edit Relative form screen

**Files:**
- Modify: `lib/ui/screens/relatives/relative_form_screen.dart` (full rewrite)

**Interfaces:**
- Consumes: `showBottomOptionSheet`/`NinoOption` (Task 9), `showNinoToast` (Task 8). Keeps `RelativeProvider.{selectedRelative,createRelative,updateRelative,isLoading}` and the submitted `data` map's keys unchanged (backend contract untouched).

Note: name is now locked (read-only, taps show a toast) whenever `widget.relativeId != null` — matching the design ("Tên đã lưu không sửa được"). This is new behavior versus the old screen, which allowed editing the name; it is required by spec §C row 6-7 and does not require a backend change (the field is simply not sent as editable in the UI). Date of birth changes from a single `showDatePicker` to three tap-to-pick fields (Ngày/Tháng/Năm), each opening a `showBottomOptionSheet`.

- [ ] **Step 1: Replace the full content of `relative_form_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/relative_provider.dart';
import '../../widgets/nino/bottom_option_sheet.dart';
import '../../widgets/nino/nino_toast.dart';

class RelativeFormScreen extends StatefulWidget {
  final int? relativeId;
  const RelativeFormScreen({super.key, this.relativeId});

  @override
  State<RelativeFormScreen> createState() => _RelativeFormScreenState();
}

class _RelativeFormScreenState extends State<RelativeFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _locationController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _hobbyController = TextEditingController();

  String _groupType = 'GIA_DINH';
  String _gender = 'MALE';
  int? _dobDay;
  int? _dobMonth;
  int? _dobYear;
  List<String> _hobbies = [];
  bool _isInit = false;
  bool _touched = false;

  static const Map<String, (String, String)> _groupTypes = {
    'GIA_DINH': ('Gia đình', '👨‍👩‍👧'),
    'VO_CHONG': ('Vợ/Chồng', '💍'),
    'CON_CAI': ('Con cái', '👶'),
    'BAN_BE': ('Bạn bè', '👤'),
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit && widget.relativeId != null) {
      _loadRelativeData();
      _isInit = true;
    }
  }

  void _loadRelativeData() {
    final relative = context.read<RelativeProvider>().selectedRelative;
    if (relative != null && relative.id == widget.relativeId) {
      _nameController.text = relative.name;
      _nicknameController.text = relative.nickname ?? '';
      _groupType = relative.groupType;
      _gender = relative.gender ?? 'MALE';
      _dobDay = relative.dateOfBirth?.day;
      _dobMonth = relative.dateOfBirth?.month;
      _dobYear = relative.dateOfBirth?.year;
      _locationController.text = relative.location ?? '';
      _heightController.text = relative.heightCm?.toString() ?? '';
      _weightController.text = relative.weightKg?.toString() ?? '';
      _hobbies = List.from(relative.hobbies ?? []);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _locationController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _hobbyController.dispose();
    super.dispose();
  }

  void _addHobby() {
    final text = _hobbyController.text.trim();
    if (text.isNotEmpty && !_hobbies.contains(text)) {
      setState(() {
        _hobbies.add(text);
        _hobbyController.clear();
      });
    }
  }

  void _removeHobby(String hobby) => setState(() => _hobbies.remove(hobby));

  Future<void> _pickDatePart(String part) async {
    final now = DateTime.now();
    late final List<int> range;
    late final String title;
    late final int? current;
    if (part == 'day') {
      range = List.generate(31, (i) => i + 1);
      title = 'Chọn ngày sinh';
      current = _dobDay;
    } else if (part == 'month') {
      range = List.generate(12, (i) => i + 1);
      title = 'Chọn tháng sinh';
      current = _dobMonth;
    } else {
      range = List.generate(90, (i) => now.year - i);
      title = 'Chọn năm sinh';
      current = _dobYear;
    }
    await showBottomOptionSheet(
      context: context,
      title: title,
      options: range
          .map((v) => NinoOption(
                label: '$v',
                icon: '',
                selected: v == current,
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() {
                    if (part == 'day') _dobDay = v;
                    if (part == 'month') _dobMonth = v;
                    if (part == 'year') _dobYear = v;
                  });
                },
              ))
          .toList(),
    );
  }

  Future<void> _submit() async {
    setState(() => _touched = true);
    if (!_formKey.currentState!.validate() || _dobDay == null || _dobMonth == null || _dobYear == null) {
      showNinoToast(context, 'Còn thông tin bắt buộc chưa nhập');
      return;
    }
    FocusScope.of(context).unfocus();

    final data = {
      'name': _nameController.text.trim(),
      'nickname': _nicknameController.text.trim().isEmpty ? null : _nicknameController.text.trim(),
      'groupType': _groupType,
      'gender': _gender,
      'dateOfBirth': DateTime(_dobYear!, _dobMonth!, _dobDay!).toIso8601String().split('T').first,
      'location': _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
      'heightCm': _heightController.text.trim().isEmpty ? null : double.tryParse(_heightController.text.trim()),
      'weightKg': _weightController.text.trim().isEmpty ? null : double.tryParse(_weightController.text.trim()),
      'hobbies': _hobbies,
    };

    final provider = context.read<RelativeProvider>();
    final success = widget.relativeId == null
        ? await provider.createRelative(data)
        : await provider.updateRelative(widget.relativeId!, data);

    if (success && mounted) {
      showNinoToast(context, widget.relativeId == null ? 'Đã thêm người thân' : 'Đã lưu thay đổi');
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.relativeId != null;
    final isLoading = context.watch<RelativeProvider>().isLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final txt = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mut = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final fnt = isDark ? AppColors.textFaintDark : AppColors.textFaintLight;
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final line = isDark ? AppColors.lineDark : AppColors.lineLight;
    final line2 = isDark ? AppColors.line2Dark : AppColors.line2Light;
    final pri = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final priSoft = isDark ? AppColors.primarySoftDark : AppColors.primarySoftLight;
    final danger = isDark ? AppColors.errorDark : AppColors.error;
    final nameError = _touched && _nameController.text.trim().isEmpty;
    final dobError = _touched && (_dobDay == null || _dobMonth == null || _dobYear == null);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 4, 14, 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(onPressed: () => context.pop(), icon: Icon(Icons.chevron_left_rounded, color: txt)),
                      Text(isEditing ? 'Sửa người thân' : 'Thêm người thân', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: txt)),
                      TextButton(
                        onPressed: isLoading ? null : _submit,
                        child: Text('Lưu', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: pri)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(18, 6, 18, 32),
                      children: [
                        Center(
                          child: CircleAvatar(
                            radius: 41,
                            backgroundColor: priSoft,
                            child: Text(
                              _nameController.text.trim().isNotEmpty ? _nameController.text.trim()[0].toUpperCase() : '?',
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: pri),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text('Họ và tên *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: mut)),
                        const SizedBox(height: 7),
                        if (isEditing)
                          GestureDetector(
                            onTap: () => showNinoToast(context, 'Tên đã lưu không sửa được'),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.neutralSoftDark : AppColors.neutralSoftLight,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: line),
                              ),
                              child: Row(
                                children: [
                                  Expanded(child: Text(_nameController.text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: txt))),
                                  Icon(Icons.lock_outline_rounded, size: 15, color: fnt),
                                ],
                              ),
                            ),
                          )
                        else
                          TextFormField(
                            controller: _nameController,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Nguyễn Thị Lan',
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: pri, width: 1.5)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: nameError ? danger : line2)),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập họ và tên' : null,
                          ),
                        if (nameError)
                          Padding(
                            padding: const EdgeInsets.only(top: 7),
                            child: Text('⚠ Vui lòng nhập họ và tên', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: danger)),
                          ),
                        const SizedBox(height: 18),
                        Text('Quan hệ *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: mut)),
                        const SizedBox(height: 7),
                        GestureDetector(
                          onTap: () => showBottomOptionSheet(
                            context: context,
                            title: 'Quan hệ',
                            options: _groupTypes.entries
                                .map((e) => NinoOption(
                                      label: e.value.$1,
                                      icon: e.value.$2,
                                      selected: _groupType == e.key,
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        setState(() => _groupType = e.key);
                                      },
                                    ))
                                .toList(),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                            decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(15), border: Border.all(color: line2)),
                            child: Row(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(color: priSoft, borderRadius: BorderRadius.circular(10)),
                                  alignment: Alignment.center,
                                  child: Text(_groupTypes[_groupType]!.$2, style: const TextStyle(fontSize: 15)),
                                ),
                                const SizedBox(width: 11),
                                Expanded(child: Text(_groupTypes[_groupType]!.$1, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: txt))),
                                Icon(Icons.chevron_right_rounded, color: fnt),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text('Giới tính', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: mut)),
                        const SizedBox(height: 7),
                        Row(
                          children: [
                            _genderChip('MALE', 'Nam', mut, pri, priSoft, line2),
                            const SizedBox(width: 8),
                            _genderChip('FEMALE', 'Nữ', mut, pri, priSoft, line2),
                            const SizedBox(width: 8),
                            _genderChip('OTHER', 'Khác', mut, pri, priSoft, line2),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text('Ngày sinh *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: mut)),
                        const SizedBox(height: 7),
                        Row(
                          children: [
                            Expanded(child: _dobPart('Ngày', _dobDay, () => _pickDatePart('day'), txt, mut, card, dobError ? danger : line2)),
                            const SizedBox(width: 8),
                            Expanded(child: _dobPart('Tháng', _dobMonth, () => _pickDatePart('month'), txt, mut, card, dobError ? danger : line2)),
                            const SizedBox(width: 8),
                            Expanded(child: _dobPart('Năm', _dobYear, () => _pickDatePart('year'), txt, mut, card, dobError ? danger : line2)),
                          ],
                        ),
                        if (dobError)
                          Padding(
                            padding: const EdgeInsets.only(top: 7),
                            child: Text('⚠ Chọn đầy đủ ngày / tháng / năm sinh', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: danger)),
                          ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Chiều cao (cm) · tuỳ chọn', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: mut)),
                                  const SizedBox(height: 7),
                                  TextFormField(controller: _heightController, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: '160')),
                                ],
                              ),
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Cân nặng (kg) · tuỳ chọn', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: mut)),
                                  const SizedBox(height: 7),
                                  TextFormField(controller: _weightController, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: '52')),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text('Địa chỉ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: mut)),
                        const SizedBox(height: 7),
                        TextFormField(controller: _locationController, decoration: const InputDecoration(hintText: 'Hà Nội')),
                        const SizedBox(height: 18),
                        Text('Sở thích', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: mut)),
                        const SizedBox(height: 7),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _hobbyController,
                                decoration: const InputDecoration(hintText: 'Thêm sở thích'),
                                onFieldSubmitted: (_) => _addHobby(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(onPressed: _addHobby, icon: Icon(Icons.add_circle_rounded, color: pri, size: 30)),
                          ],
                        ),
                        if (_hobbies.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _hobbies
                                  .map((h) => Chip(
                                        label: Text(h),
                                        onDeleted: () => _removeHobby(h),
                                        backgroundColor: priSoft,
                                        deleteIconColor: pri,
                                        labelStyle: TextStyle(color: pri, fontWeight: FontWeight.w600),
                                        side: BorderSide.none,
                                      ))
                                  .toList(),
                            ),
                          ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: pri,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Text(isEditing ? 'Lưu thay đổi' : 'Lưu người thân', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (isLoading) Container(color: Colors.black.withValues(alpha: 0.2), child: const Center(child: CircularProgressIndicator())),
          ],
        ),
      ),
    );
  }

  Widget _genderChip(String value, String label, Color mut, Color pri, Color priSoft, Color line2) {
    final isSelected = _gender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _gender = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? priSoft : Colors.transparent,
            border: Border.all(color: isSelected ? pri : line2, width: 1.5),
            borderRadius: BorderRadius.circular(15),
          ),
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isSelected ? pri : mut)),
        ),
      ),
    );
  }

  Widget _dobPart(String label, int? value, VoidCallback onTap, Color txt, Color mut, Color card, Color border) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(15), border: Border.all(color: border, width: 1.5)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: mut)),
                const SizedBox(height: 1),
                Text(value?.toString() ?? '—', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: txt)),
              ],
            ),
            Icon(Icons.expand_more_rounded, size: 14, color: mut),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Run analyzer**

Run: `C:\flutter\bin\flutter.bat analyze lib/ui/screens/relatives/relative_form_screen.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/ui/screens/relatives/relative_form_screen.dart
git commit -m "feat(nino): redesign Add/Edit Relative form screen"
```

---

## Task 21: Redesign Event list screen

**Files:**
- Modify: `lib/ui/screens/events/event_list_screen.dart` (full rewrite)

**Interfaces:**
- Consumes: `CardRow`/`SquareIconBadge` (Task 5), `FilterChipsRow` (Task 6), `showDeleteConfirmSheet` (Task 10), `showNinoToast` (Task 8), `resolveVnHolidays` (Task 13). Keeps `EventProvider.{loadEvents,setFilter,deleteEvent,events,isLoading}` and the `/events/holidays` route (Task 14), `/events/new`, `/events/:id`, `/events/:id/edit` unchanged.

Note: the design's Sự kiện screen groups events by semantic buckets ("Tuần này", "Âm lịch sắp tới"...) and filters by Tất cả/Sắp tới/Định kỳ/Âm lịch — `EventProvider` only supports `setFilter(month:)`. Rather than inventing new provider filtering not backed by real data, this task keeps the existing month-based grouping/filtering, restyled with the new card language, and adds the Holidays entry-point card the design calls for.

- [ ] **Step 1: Replace the full content of `event_list_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/vn_holidays.dart';
import '../../../core/utils/date_utils.dart';
import '../../../providers/event_provider.dart';
import '../../../models/event.dart';
import '../../widgets/nino/card_row.dart';
import '../../widgets/nino/pill_tabs.dart';
import '../../widgets/nino/sticky_action_bars.dart';
import '../../widgets/nino/nino_toast.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  int? _selectedMonth;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().loadEvents();
    });
  }

  void _onMonthSelected(int? month) {
    setState(() => _selectedMonth = month);
    context.read<EventProvider>().setFilter(month: month);
  }

  Future<void> _deleteEvent(BuildContext context, int eventId) async {
    final confirmed = await showDeleteConfirmSheet(
      context: context,
      title: 'Xoá sự kiện này?',
      message: 'Bạn có chắc chắn muốn xoá sự kiện này không?',
    );
    if (confirmed && context.mounted) {
      context.read<EventProvider>().deleteEvent(eventId);
      showNinoToast(context, 'Đã xoá sự kiện');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EventProvider>();
    final allEvents = provider.events;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final txt = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mut = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final fnt = isDark ? AppColors.textFaintDark : AppColors.textFaintLight;
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final line = isDark ? AppColors.lineDark : AppColors.lineLight;
    final pri = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final priSoft = isDark ? AppColors.primarySoftDark : AppColors.primarySoftLight;

    final availableMonths = allEvents.map((e) => e.eventDate.month).toSet().toList()..sort();
    final groupedEvents = <String, List<EventModel>>{};
    for (final event in allEvents) {
      final key = 'Tháng ${event.eventDate.month}, ${event.eventDate.year}';
      groupedEvents.putIfAbsent(key, () => []).add(event);
    }

    final year = DateTime.now().year;
    final holidays = resolveVnHolidays(year);
    final officialCount = holidays.where((h) => h.def.official).length;
    final offDays = holidays.where((h) => h.def.official).fold<int>(0, (n, h) => n + h.def.officialDaysOff);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Sự kiện', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.6, color: txt)),
                  GestureDetector(
                    onTap: () => context.push('/events/new'),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: pri,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: pri.withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 6))],
                      ),
                      child: const Icon(Icons.add_rounded, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Dương lịch & âm lịch trong một dòng thời gian', style: TextStyle(fontSize: 12, color: mut)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: GestureDetector(
                onTap: () => context.push('/events/holidays'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(18), border: Border.all(color: line)),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(color: priSoft, borderRadius: BorderRadius.circular(12)),
                        alignment: Alignment.center,
                        child: const Text('🇻🇳', style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Lịch nghỉ lễ Việt Nam', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: txt)),
                            const SizedBox(height: 2),
                            Text('$officialCount dịp lễ chính · $offDays ngày nghỉ theo quy định $year', style: TextStyle(fontSize: 12, color: mut)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: fnt),
                    ],
                  ),
                ),
              ),
            ),
            if (availableMonths.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: FilterChipsRow(
                  labels: ['Tất cả', ...availableMonths.map((m) => 'Tháng $m')],
                  selected: _selectedMonth == null ? 'Tất cả' : 'Tháng $_selectedMonth',
                  onChanged: (label) => _onMonthSelected(label == 'Tất cả' ? null : int.parse(label.replaceFirst('Tháng ', ''))),
                ),
              ),
            const SizedBox(height: 12),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : allEvents.isEmpty
                      ? Center(child: Text('Không có sự kiện nào', style: TextStyle(color: mut)))
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                          itemCount: groupedEvents.keys.length,
                          itemBuilder: (context, index) {
                            final key = groupedEvents.keys.elementAt(index);
                            final monthEvents = groupedEvents[key]!;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Text(key.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.8, color: fnt)),
                                ),
                                ...monthEvents.map((event) => Padding(
                                      padding: const EdgeInsets.only(bottom: 9),
                                      child: CardRow(
                                        onTap: () => context.push('/events/${event.id}'),
                                        leading: SquareIconBadge(icon: event.eventTypeIcon, color: event.categoryColorValue, background: event.categoryColorValue.withValues(alpha: 0.15)),
                                        title: event.title,
                                        meta: Row(
                                          children: [
                                            Flexible(child: Text(AppDateUtils.formatDate(event.eventDate), style: TextStyle(fontSize: 12, color: mut), overflow: TextOverflow.ellipsis)),
                                            if (event.eventTime != null && event.eventTime!.isNotEmpty) ...[
                                              const SizedBox(width: 8),
                                              Text('· ${AppDateUtils.formatTime(event.eventTime)}', style: TextStyle(fontSize: 12, color: mut)),
                                            ],
                                          ],
                                        ),
                                        trailing: PopupMenuButton<String>(
                                          icon: Icon(Icons.more_vert_rounded, color: fnt, size: 20),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                          color: card,
                                          onSelected: (v) {
                                            if (v == 'edit') context.push('/events/${event.id}/edit');
                                            if (v == 'delete') _deleteEvent(context, event.id);
                                          },
                                          itemBuilder: (context) => [
                                            PopupMenuItem(
                                              value: 'edit',
                                              child: Row(children: [const Icon(Icons.edit_rounded, size: 18), const SizedBox(width: 10), Text('Chỉnh sửa', style: TextStyle(color: txt))]),
                                            ),
                                            PopupMenuItem(
                                              value: 'delete',
                                              child: Row(children: [const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error), const SizedBox(width: 10), const Text('Xoá', style: TextStyle(color: AppColors.error))]),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )),
                              ],
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Run analyzer**

Run: `C:\flutter\bin\flutter.bat analyze lib/ui/screens/events/event_list_screen.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/ui/screens/events/event_list_screen.dart
git commit -m "feat(nino): redesign Event list screen"
```

---

## Task 22: Redesign Event type selection screen

**Files:**
- Modify: `lib/ui/screens/events/event_type_selection_screen.dart` (full rewrite)

**Interfaces:**
- Consumes: `AppColors.*` (Task 1). Keeps the `/events/create?type=relative` / `/events/create?type=self` navigation unchanged.

- [ ] **Step 1: Replace the full content of `event_type_selection_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_provider.dart';

class EventTypeSelectionScreen extends StatelessWidget {
  const EventTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final txt = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mut = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final fnt = isDark ? AppColors.textFaintDark : AppColors.textFaintLight;
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final line = isDark ? AppColors.lineDark : AppColors.lineLight;
    final priSoft = isDark ? AppColors.primarySoftDark : AppColors.primarySoftLight;
    final mintSoft = isDark ? AppColors.secondarySoftDark : AppColors.secondarySoftLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 4, 18, 0),
              child: Row(
                children: [
                  IconButton(onPressed: () => context.pop(), icon: Icon(Icons.chevron_left_rounded, color: txt)),
                  Text('Tạo sự kiện mới', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: txt)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 34, 24, 26),
              child: Column(
                children: [
                  Text('Chọn loại sự kiện', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.5, color: txt)),
                  const SizedBox(height: 7),
                  Text('Sự kiện này dành cho ai?', style: TextStyle(fontSize: 14, color: mut)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                children: [
                  _typeCard(
                    context,
                    icon: '👨‍👩‍👧',
                    bg: priSoft,
                    title: 'Liên kết với Người thân',
                    sub: 'Sinh nhật, kỷ niệm, ngày giỗ…',
                    txt: txt,
                    mut: mut,
                    card: card,
                    line: line,
                    onTap: () => context.push('/events/create?type=relative'),
                  ),
                  const SizedBox(height: 13),
                  _typeCard(
                    context,
                    icon: '📅',
                    bg: mintSoft,
                    title: 'Sự kiện cho Bản thân',
                    sub: 'Đóng tiền, thi cử, lịch học, cúng rằm…',
                    txt: txt,
                    mut: mut,
                    card: card,
                    line: line,
                    onTap: () => context.push('/events/create?type=self'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 18),
              child: Text(
                'Sự kiện của người thân sẽ tự gắn vào hồ sơ người đó và nhắc theo lịch của họ.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: fnt, height: 1.55),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeCard(
    BuildContext context, {
    required String icon,
    required Color bg,
    required String title,
    required String sub,
    required Color txt,
    required Color mut,
    required Color card,
    required Color line,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: line),
          boxShadow: [BoxShadow(color: isDark ? AppColors.shadowDark : AppColors.shadowLight, blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Container(width: 62, height: 62, decoration: BoxDecoration(color: bg, shape: BoxShape.circle), alignment: Alignment.center, child: Text(icon, style: const TextStyle(fontSize: 24))),
            const SizedBox(height: 13),
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.3, color: txt)),
            const SizedBox(height: 5),
            Text(sub, style: TextStyle(fontSize: 12, color: mut), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Run analyzer**

Run: `C:\flutter\bin\flutter.bat analyze lib/ui/screens/events/event_type_selection_screen.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/ui/screens/events/event_type_selection_screen.dart
git commit -m "feat(nino): redesign Event type selection screen"
```

---

## Task 23: Redesign Add Event form screen

**Files:**
- Modify: `lib/ui/screens/events/event_form_screen.dart` (full rewrite)

**Interfaces:**
- Consumes: `showBottomOptionSheet`/`NinoOption` (Task 9), `SoftToggle` (Task 7), `StickySaveBar` (Task 10), `showNinoToast` (Task 8). **Must preserve** `prefillTitle`/`prefillDate` constructor params and their `initState` handling added in Task 14 — this rewrite supersedes that file's content, so copy that logic in verbatim (reproduced in Step 1 below). Keeps every `EventProvider`/`RelativeProvider` call, the `_saveEvent` payload shape, and all category/repeat/reminder business logic byte-for-byte — only presentation changes.

Note: the design's category list has 14 entries including lunar-specific ones ("Ngày giỗ", "Lễ Tết âm lịch"...) that do not exist in this app's real category set (7 categories, DB-seeded, `categoryId` 1-7 — see `_categories` below). Do not invent new category IDs; keep the existing 7. The design's "Theo lịch âm" toggle is likewise not ported as a separate control — lunar-ness is already expressed by the existing `recurrenceType == 'LUNAR_YEARLY'` (with `lunarDay`/`lunarMonth` fields), which this task keeps as-is, just reskinned.

Note: the current `event_form_screen.dart` on this branch supports `recurrenceType` values `NONE`/`DAILY`/`WEEKLY`/`MONTHLY`/`YEARLY`/`LUNAR_YEARLY`/`CUSTOM`, but `CUSTOM` has no interval-value/unit UI yet (no `customIntervalValue`/`customIntervalUnit` fields, no `HOURLY` option) — that UI was mid-flight on a different, unmerged branch and is **not** part of this redesign's scope. Reskin exactly what exists today: keep `CUSTOM` selectable in the Lặp lại sheet (it just won't show extra fields, same as today), do not add `_customIntervalValue`/`_customIntervalUnit`/`_CustomUnitOption`/`HOURLY` — they are not in the `_repeatOptions`/state below.

- [ ] **Step 1: Replace the full content of `event_form_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/event_provider.dart';
import '../../../providers/relative_provider.dart';
import '../../widgets/nino/bottom_option_sheet.dart';
import '../../widgets/nino/soft_toggle.dart';
import '../../widgets/nino/sticky_action_bars.dart';
import '../../widgets/nino/nino_toast.dart';

class EventFormScreen extends StatefulWidget {
  final bool isRelativeEvent;
  final int? eventId;
  final String? prefillTitle;
  final DateTime? prefillDate;

  const EventFormScreen({
    super.key,
    this.isRelativeEvent = true,
    this.eventId,
    this.prefillTitle,
    this.prefillDate,
  });

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  int? _selectedRelativeId;
  String? _selectedRelativeName;
  int _selectedCategoryId = 1;
  String _selectedCategory = 'Sinh nhật';
  String _selectedCategoryKey = 'SINH_NHAT';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _selectedTime = const TimeOfDay(hour: 14, minute: 0);
  bool _isAllDay = false;
  String _repeatMode = 'Không lặp';
  String _repeatKey = 'NONE';

  int _lunarDay = 1;
  int _lunarMonth = 1;

  final List<_ReminderItem> _reminders = [
    _ReminderItem(label: '7 ngày trước', daysBefore: 7),
    _ReminderItem(label: '3 ngày trước', daysBefore: 3),
    _ReminderItem(label: '1 ngày trước', daysBefore: 1),
    _ReminderItem(label: '1 giờ trước', hoursBefore: 1),
  ];

  static const List<_CategoryItem> _categories = [
    _CategoryItem(id: 1, key: 'SINH_NHAT', label: 'Sinh nhật', icon: Icons.cake, color: Color(0xFFFF5A5F)),
    _CategoryItem(id: 2, key: 'KY_NIEM', label: 'Kỷ niệm', icon: Icons.favorite, color: Color(0xFF8B6BE0)),
    _CategoryItem(id: 3, key: 'LE', label: 'Lễ/Tết', icon: Icons.card_giftcard, color: Color(0xFFD69C13)),
    _CategoryItem(id: 4, key: 'NHA_O', label: 'Nhà ở', icon: Icons.home, color: Color(0xFF2F9E97)),
    _CategoryItem(id: 5, key: 'HOA_DON', label: 'Hóa đơn', icon: Icons.bolt, color: Color(0xFFD69C13)),
    _CategoryItem(id: 6, key: 'MUA_SAM', label: 'Mua sắm', icon: Icons.shopping_bag, color: Color(0xFF2F9E97)),
    _CategoryItem(id: 7, key: 'KHAC', label: 'Khác', icon: Icons.more_horiz, color: Color(0xFF8A94A6)),
  ];

  static const List<_RepeatOption> _repeatOptions = [
    _RepeatOption(key: 'NONE', label: 'Không lặp', icon: '🚫'),
    _RepeatOption(key: 'DAILY', label: 'Hàng ngày', icon: '🔁'),
    _RepeatOption(key: 'WEEKLY', label: 'Hàng tuần', icon: '🔁'),
    _RepeatOption(key: 'MONTHLY', label: 'Hàng tháng', icon: '🔁'),
    _RepeatOption(key: 'YEARLY', label: 'Hàng năm', icon: '🔁'),
    _RepeatOption(key: 'LUNAR_YEARLY', label: 'Hàng năm (Âm lịch)', icon: '🧧'),
    _RepeatOption(key: 'CUSTOM', label: 'Tùy chỉnh', icon: '⚙️'),
  ];

  static const List<_ReminderOption> _reminderOptions = [
    _ReminderOption(label: '7 ngày trước', daysBefore: 7),
    _ReminderOption(label: '3 ngày trước', daysBefore: 3),
    _ReminderOption(label: '1 ngày trước', daysBefore: 1),
    _ReminderOption(label: '1 giờ trước', hoursBefore: 1),
    _ReminderOption(label: '30 phút trước', hoursBefore: 0, minutesBefore: 30),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.eventId == null && widget.prefillTitle != null) {
      _titleController.text = widget.prefillTitle!;
      if (widget.prefillDate != null) _selectedDate = widget.prefillDate!;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RelativeProvider>().loadRelatives();
      if (widget.eventId != null) {
        _loadExistingEvent();
      }
    });
  }

  Future<void> _loadExistingEvent() async {
    final provider = context.read<EventProvider>();
    await provider.loadEventById(widget.eventId!);
    final event = provider.selectedEvent;
    if (event == null) return;
    setState(() {
      _titleController.text = event.title;
      _selectedRelativeId = event.relativeId;
      _selectedDate = event.eventDate;
      if (event.eventTime != null && event.eventTime!.isNotEmpty) {
        final parts = event.eventTime!.split(':');
        _selectedTime = TimeOfDay(hour: int.tryParse(parts[0]) ?? 0, minute: int.tryParse(parts[1]) ?? 0);
      }
      if (event.isRecurring) {
        _repeatMode = 'Hàng năm';
        _repeatKey = 'YEARLY';
      }
      try {
        final cat = _categories.firstWhere((c) => c.id == event.categoryId);
        _selectedCategoryId = cat.id;
        _selectedCategory = cat.label;
        _selectedCategoryKey = cat.key;
      } catch (_) {}

      _reminders.clear();
      for (final r in event.reminders) {
        if (r.remindDaysBefore == 7 && r.isEnabled) _reminders.add(_ReminderItem(label: '7 ngày trước', daysBefore: 7));
        if (r.remindDaysBefore == 3 && r.isEnabled) _reminders.add(_ReminderItem(label: '3 ngày trước', daysBefore: 3));
        if (r.remindDaysBefore == 1 && r.isEnabled) _reminders.add(_ReminderItem(label: '1 ngày trước', daysBefore: 1));
        if (r.remindHoursBefore == 1 && r.isEnabled) _reminders.add(_ReminderItem(label: '1 giờ trước', hoursBefore: 1));
      }
      _notesController.text = event.notes ?? '';
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2000), lastDate: DateTime(2101));
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(context: context, initialTime: _selectedTime ?? TimeOfDay.now());
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _showRepeatSheet() {
    showBottomOptionSheet(
      context: context,
      title: 'Lặp lại',
      options: _repeatOptions
          .map((o) => NinoOption(
                label: o.label,
                icon: o.icon,
                selected: _repeatKey == o.key,
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _repeatKey = o.key;
                    _repeatMode = o.label;
                  });
                },
              ))
          .toList(),
    );
  }

  void _showRelativePicker() {
    final relatives = context.read<RelativeProvider>().relatives;
    if (relatives.isEmpty) {
      showNinoToast(context, 'Chưa có người thân nào. Hãy thêm người thân trước.');
      return;
    }
    showBottomOptionSheet(
      context: context,
      title: 'Chọn người thân',
      options: relatives
          .map((r) => NinoOption(
                label: r.displayName,
                icon: '👤',
                selected: _selectedRelativeId == r.id,
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _selectedRelativeId = r.id;
                    _selectedRelativeName = r.displayName;
                  });
                },
              ))
          .toList(),
    );
  }

  void _showCategoryPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (ctx) {
        final txt = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.74),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
                  child: Align(alignment: Alignment.centerLeft, child: Text('Danh mục', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: txt))),
                ),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 22),
                    itemCount: _categories.length,
                    itemBuilder: (context, i) {
                      final cat = _categories[i];
                      final isSelected = cat.key == _selectedCategoryKey;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Material(
                          color: isSelected ? cat.color.withValues(alpha: 0.12) : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              setState(() {
                                _selectedCategoryId = cat.id;
                                _selectedCategory = cat.label;
                                _selectedCategoryKey = cat.key;
                              });
                              Navigator.of(context).pop();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
                              child: Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(color: cat.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                                    child: Icon(cat.icon, color: cat.color, size: 19),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      cat.label,
                                      style: TextStyle(fontSize: 15, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? cat.color : txt),
                                    ),
                                  ),
                                  if (isSelected) Icon(Icons.check_rounded, size: 18, color: cat.color),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddReminderSheet() {
    final existingLabels = _reminders.map((r) => r.label).toSet();
    final available = _reminderOptions.where((o) => !existingLabels.contains(o.label)).toList();
    if (available.isEmpty) {
      showNinoToast(context, 'Đã thêm tất cả nhắc nhở');
      return;
    }
    showBottomOptionSheet(
      context: context,
      title: 'Thêm nhắc nhở',
      options: available
          .map((o) => NinoOption(
                label: o.label,
                icon: '⏰',
                selected: false,
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() => _reminders.add(_ReminderItem(label: o.label, daysBefore: o.daysBefore, hoursBefore: o.hoursBefore)));
                },
              ))
          .toList(),
    );
  }

  void _saveEvent() {
    if (_titleController.text.trim().isEmpty) {
      showNinoToast(context, 'Vui lòng nhập tên sự kiện');
      return;
    }
    final reminders = <Map<String, dynamic>>[];
    for (final r in _reminders) {
      if (r.daysBefore != null && r.daysBefore! > 0) reminders.add({'remindDaysBefore': r.daysBefore, 'isEnabled': true});
      if (r.hoursBefore != null && r.hoursBefore! > 0) reminders.add({'remindHoursBefore': r.hoursBefore, 'isEnabled': true});
    }
    final data = {
      'title': _titleController.text.trim(),
      'categoryId': _selectedCategoryId,
      'eventDate': _selectedDate.toIso8601String().split('T').first,
      'eventTime': (!_isAllDay && _selectedTime != null)
          ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
          : null,
      'isRecurring': _repeatKey != 'NONE',
      if (_repeatKey != 'NONE') 'recurrenceType': _repeatKey,
      if (_repeatKey == 'LUNAR_YEARLY') 'lunarDay': _lunarDay,
      if (_repeatKey == 'LUNAR_YEARLY') 'lunarMonth': _lunarMonth,
      'notes': _notesController.text.trim(),
      'relativeId': _selectedRelativeId,
      'reminders': reminders,
    };
    final provider = context.read<EventProvider>();
    final future = widget.eventId != null ? provider.updateEvent(widget.eventId!, data) : provider.createEvent(data);
    future.then((success) {
      if (success && mounted) context.pop();
    });
  }

  String _formatDate(DateTime d) {
    const months = ['', 'tháng 1', 'tháng 2', 'tháng 3', 'tháng 4', 'tháng 5', 'tháng 6', 'tháng 7', 'tháng 8', 'tháng 9', 'tháng 10', 'tháng 11', 'tháng 12'];
    return '${d.day} ${months[d.month]}, ${d.year}';
  }

  String _formatTime(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final txt = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mut = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final fnt = isDark ? AppColors.textFaintDark : AppColors.textFaintLight;
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final line = isDark ? AppColors.lineDark : AppColors.lineLight;
    final line2 = isDark ? AppColors.line2Dark : AppColors.line2Light;
    final pri = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final priSoft = isDark ? AppColors.primarySoftDark : AppColors.primarySoftLight;
    final mintSoft = isDark ? AppColors.secondarySoftDark : AppColors.secondarySoftLight;
    final amberSoft = isDark ? AppColors.amberSoftDark : AppColors.amberSoftLight;
    final violetSoft = isDark ? AppColors.accentSoftDark : AppColors.accentSoftLight;
    final isLoading = context.watch<EventProvider>().isLoading;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 4, 18, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(onPressed: () => context.pop(), icon: Icon(Icons.chevron_left_rounded, color: txt)),
                  Text('Thêm sự kiện', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: txt)),
                  TextButton(onPressed: isLoading ? null : _saveEvent, child: Text('Lưu', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: pri))),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleController,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: txt),
                      decoration: InputDecoration(
                        hintText: 'Tên sự kiện *',
                        filled: true,
                        fillColor: card,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: line2)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: line2)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: pri, width: 1.5)),
                      ),
                    ),
                    const SizedBox(height: 11),
                    Container(
                      decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(18), border: Border.all(color: line2)),
                      child: Column(
                        children: [
                          _pickerRow(
                            icon: '👤',
                            iconBg: priSoft,
                            label: 'Người thân',
                            value: _selectedRelativeName ?? 'Không có',
                            valueColor: _selectedRelativeName != null ? txt : mut,
                            onTap: _showRelativePicker,
                            border: Border(bottom: BorderSide(color: line)),
                            txt: txt,
                          ),
                          _pickerRow(
                            icon: '🏷',
                            iconBg: mintSoft,
                            label: 'Danh mục',
                            value: _selectedCategory,
                            valueColor: pri,
                            onTap: _showCategoryPicker,
                            border: const Border(),
                            txt: txt,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 11),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
                      decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(18), border: Border.all(color: line2)),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: _selectDate,
                                  child: _dateTimeTile(icon: Icons.calendar_today_rounded, iconBg: mintSoft, label: 'Ngày', value: _formatDate(_selectedDate), txt: txt, mut: mut),
                                ),
                              ),
                              if (!_isAllDay)
                                Expanded(
                                  child: GestureDetector(
                                    onTap: _selectTime,
                                    child: _dateTimeTile(icon: Icons.access_time_rounded, iconBg: priSoft, label: 'Giờ', value: _selectedTime != null ? _formatTime(_selectedTime!) : '--:--', txt: txt, mut: mut),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 9),
                          Divider(height: 1, color: line),
                          const SizedBox(height: 9),
                          Row(
                            children: [
                              const Text('🌤', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 11),
                              Expanded(child: Text('Cả ngày', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: txt))),
                              SoftToggle(value: _isAllDay, onChanged: (v) => setState(() => _isAllDay = v)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 11),
                    Container(
                      decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(18), border: Border.all(color: line2)),
                      child: Column(
                        children: [
                          _pickerRow(
                            icon: '🔁',
                            iconBg: violetSoft,
                            label: 'Lặp lại',
                            value: _repeatMode,
                            valueColor: _repeatKey != 'NONE' ? txt : mut,
                            onTap: _showRepeatSheet,
                            border: const Border(),
                            txt: txt,
                          ),
                          if (_repeatKey == 'LUNAR_YEARLY')
                            Padding(
                              padding: const EdgeInsets.fromLTRB(15, 0, 15, 14),
                              child: Row(
                                children: [
                                  Expanded(child: _numberDropdown('Ngày âm', _lunarDay, 30, (v) => setState(() => _lunarDay = v), card, line2, txt, mut)),
                                  const SizedBox(width: 12),
                                  Expanded(child: _numberDropdown('Tháng âm', _lunarMonth, 12, (v) => setState(() => _lunarMonth = v), card, line2, txt, mut)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 11),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(18), border: Border.all(color: line2)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(width: 30, height: 30, decoration: BoxDecoration(color: amberSoft, borderRadius: BorderRadius.circular(10)), alignment: Alignment.center, child: const Text('⏰', style: TextStyle(fontSize: 14))),
                              const SizedBox(width: 11),
                              Text('Nhắc nhở *', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: txt)),
                            ],
                          ),
                          const SizedBox(height: 11),
                          Wrap(
                            spacing: 7,
                            runSpacing: 7,
                            children: [
                              ..._reminders.asMap().entries.map((e) => Container(
                                    padding: const EdgeInsets.only(left: 12, right: 8, top: 7, bottom: 7),
                                    decoration: BoxDecoration(color: priSoft, borderRadius: BorderRadius.circular(999)),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(e.value.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: pri)),
                                        const SizedBox(width: 6),
                                        GestureDetector(onTap: () => setState(() => _reminders.removeAt(e.key)), child: Icon(Icons.close_rounded, size: 14, color: pri)),
                                      ],
                                    ),
                                  )),
                              GestureDetector(
                                onTap: _showAddReminderSheet,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), border: Border.all(color: line2)),
                                  child: Text('＋ Thêm nhắc nhở', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: mut)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 11),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(15, 14, 15, 11),
                      decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(18), border: Border.all(color: line2)),
                      child: TextFormField(
                        controller: _notesController,
                        maxLines: 2,
                        style: TextStyle(fontSize: 14, color: txt),
                        decoration: InputDecoration(hintText: 'Thêm ghi chú (không bắt buộc)', hintStyle: TextStyle(color: fnt), border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            StickySaveBar(label: 'Lưu sự kiện', onPressed: isLoading ? null : _saveEvent, loading: isLoading),
          ],
        ),
      ),
    );
  }

  Widget _pickerRow({
    required String icon,
    required Color iconBg,
    required String label,
    required String value,
    required Color valueColor,
    required VoidCallback onTap,
    required Border border,
    required Color txt,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        decoration: BoxDecoration(border: border),
        child: Row(
          children: [
            Container(width: 30, height: 30, decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)), alignment: Alignment.center, child: Text(icon, style: const TextStyle(fontSize: 14))),
            const SizedBox(width: 11),
            Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: txt)),
            const Spacer(),
            Flexible(child: Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: valueColor), textAlign: TextAlign.right, overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, size: 18, color: valueColor),
          ],
        ),
      ),
    );
  }

  Widget _dateTimeTile({required IconData icon, required Color iconBg, required String label, required String value, required Color txt, required Color mut}) {
    return Row(
      children: [
        Container(width: 28, height: 28, decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)), alignment: Alignment.center, child: Icon(icon, size: 15, color: txt)),
        const SizedBox(width: 9),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: mut)),
            Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: txt)),
          ],
        ),
      ],
    );
  }

  Widget _numberDropdown(String label, int value, int max, ValueChanged<int> onChanged, Color card, Color line2, Color txt, Color mut) {
    return GestureDetector(
      onTap: () => showBottomOptionSheet(
        context: context,
        title: label,
        options: List.generate(max, (i) => i + 1)
            .map((v) => NinoOption(label: '$v', icon: '', selected: v == value, onTap: () { Navigator.of(context).pop(); onChanged(v); }))
            .toList(),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(12), border: Border.all(color: line2)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(label, style: TextStyle(fontSize: 11, color: mut)), Text('$value', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: txt))],
            ),
            Icon(Icons.expand_more_rounded, size: 14, color: mut),
          ],
        ),
      ),
    );
  }
}

class _CategoryItem {
  final int id;
  final String key;
  final String label;
  final IconData icon;
  final Color color;
  const _CategoryItem({required this.id, required this.key, required this.label, required this.icon, required this.color});
}

class _RepeatOption {
  final String key;
  final String label;
  final String icon;
  const _RepeatOption({required this.key, required this.label, required this.icon});
}

class _ReminderOption {
  final String label;
  final int daysBefore;
  final int hoursBefore;
  final int minutesBefore;
  const _ReminderOption({required this.label, this.daysBefore = 0, this.hoursBefore = 0, this.minutesBefore = 0});
}

class _ReminderItem {
  final String label;
  final int? daysBefore;
  final int? hoursBefore;
  _ReminderItem({required this.label, this.daysBefore, this.hoursBefore});
}
```

- [ ] **Step 2: Run analyzer**

Run: `C:\flutter\bin\flutter.bat analyze lib/ui/screens/events/event_form_screen.dart`
Expected: `No issues found!`

- [ ] **Step 3: Manually verify the prefill hook still works**

Run the app, open Lịch nghỉ lễ (via Sự kiện → the Holidays card from Task 21), tap a holiday, tap "+ Tạo sự kiện" — confirm the title field is pre-filled with the holiday's name and the date matches. This exercises the Task 14 wiring end-to-end now that the screen has been fully rewritten.

- [ ] **Step 4: Commit**

```bash
git add lib/ui/screens/events/event_form_screen.dart
git commit -m "feat(nino): redesign Add Event form screen"
```

---

## Task 24: Redesign Profile ("Tôi") screen

**Files:**
- Modify: `lib/ui/screens/profile/profile_screen.dart` (full rewrite)

**Interfaces:**
- Consumes: `InitialsAvatar`, `NinoLogo` (Tasks 3-4), `SoftToggle` (Task 7). Keeps `AuthProvider.{user,loadProfile,logout}`, `ThemeProvider.{isDarkMode,toggleTheme}`, `NotificationProvider.unreadCount`, and `/profile/settings`, `/profile/notifications`, `/profile/login-history` routes unchanged.

Note: the design mock shows a "Google Calendar" sync toggle — this app has no Google Calendar integration (no provider, no backend endpoint), so it is **not** ported; adding a toggle with no real effect would be a broken/misleading control. This is a deliberate omission, not a missed requirement.

- [ ] **Step 1: Replace the full content of `profile_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../widgets/nino/initials_avatar.dart';
import '../../widgets/nino/nino_logo.dart';
import '../../widgets/nino/soft_toggle.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.user == null) authProvider.loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final unreadCount = context.watch<NotificationProvider>().unreadCount;
    final days = user?.createdAt != null ? DateTime.now().difference(user!.createdAt!).inDays : 0;

    final txt = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mut = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final fnt = isDark ? AppColors.textFaintDark : AppColors.textFaintLight;
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final line = isDark ? AppColors.lineDark : AppColors.lineLight;
    final pri = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final priSoft = isDark ? AppColors.primarySoftDark : AppColors.primarySoftLight;
    final mint = isDark ? AppColors.secondaryDark : AppColors.secondaryLight;
    final amber = isDark ? AppColors.amberDark : AppColors.amberLight;
    final danger = isDark ? AppColors.errorDark : AppColors.error;
    final dangerSoft = isDark ? AppColors.errorSoftDark : AppColors.errorSoftLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          child: Column(
            children: [
              InitialsAvatar(name: user?.fullName ?? 'Người dùng', color: pri, softColor: priSoft, radius: 40, avatarUrl: user?.avatarUrl),
              const SizedBox(height: 12),
              Text(user?.fullName ?? 'Người dùng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.3, color: txt)),
              const SizedBox(height: 4),
              Text(user?.email ?? 'email@example.com', style: TextStyle(fontSize: 12, color: mut)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(18), border: Border.all(color: line)),
                child: Row(
                  children: [
                    Expanded(child: _stat('${user?.totalRelatives ?? 0}', 'Người thân', pri, mut)),
                    Container(width: 1, height: 30, color: line),
                    Expanded(child: _stat('${user?.totalEvents ?? 0}', 'Sự kiện', mint, mut)),
                    Container(width: 1, height: 30, color: line),
                    Expanded(child: _stat('$days', 'Ngày HL', amber, mut)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(18), border: Border.all(color: line)),
                child: Column(
                  children: [
                    _menuRow(
                      icon: Icons.dark_mode_outlined,
                      iconBg: priSoft,
                      iconColor: pri,
                      title: 'Chế độ tối',
                      txt: txt,
                      mut: mut,
                      trailing: SoftToggle(value: isDark, onChanged: (_) => context.read<ThemeProvider>().toggleTheme()),
                      onTap: () => context.read<ThemeProvider>().toggleTheme(),
                      border: Border(bottom: BorderSide(color: line)),
                    ),
                    _menuRow(
                      icon: Icons.person_outline_rounded,
                      iconBg: priSoft,
                      iconColor: pri,
                      title: 'Thông tin cá nhân',
                      txt: txt,
                      mut: mut,
                      onTap: () => context.push('/profile/settings'),
                      border: Border(bottom: BorderSide(color: line)),
                    ),
                    _menuRow(
                      icon: Icons.notifications_none_rounded,
                      iconBg: priSoft,
                      iconColor: pri,
                      title: 'Thông báo',
                      txt: txt,
                      mut: mut,
                      badgeCount: unreadCount,
                      onTap: () => context.push('/profile/notifications'),
                      border: Border(bottom: BorderSide(color: line)),
                    ),
                    _menuRow(
                      icon: Icons.security_rounded,
                      iconBg: priSoft,
                      iconColor: pri,
                      title: 'Bảo mật',
                      txt: txt,
                      mut: mut,
                      onTap: () => context.push('/profile/login-history'),
                      border: Border(bottom: BorderSide(color: line)),
                    ),
                    _menuRow(
                      icon: Icons.language_rounded,
                      iconBg: priSoft,
                      iconColor: pri,
                      title: 'Ngôn ngữ',
                      txt: txt,
                      mut: mut,
                      trailingText: 'Tiếng Việt',
                      onTap: () {},
                      border: Border(bottom: BorderSide(color: line)),
                    ),
                    _menuRow(
                      icon: Icons.help_outline_rounded,
                      iconBg: priSoft,
                      iconColor: pri,
                      title: 'Trợ giúp',
                      txt: txt,
                      mut: mut,
                      onTap: () => showAboutDialog(context: context, applicationName: 'NINO', applicationVersion: '1.0.0'),
                      border: const Border(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    await context.read<AuthProvider>().logout();
                    if (context.mounted) context.go('/splash');
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: dangerSoft,
                    side: BorderSide(color: dangerSoft),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('Đăng xuất', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: danger)),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const NinoLogo(size: 20, showBadge: false),
                  const SizedBox(width: 7),
                  Text('nino · 1.0.0', style: TextStyle(fontSize: 12, color: fnt)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(String value, String label, Color color, Color mut) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 12, color: mut)),
      ],
    );
  }

  Widget _menuRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required Color txt,
    required Color mut,
    required VoidCallback onTap,
    required Border border,
    String? trailingText,
    Widget? trailing,
    int badgeCount = 0,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(border: border),
        child: Row(
          children: [
            Container(width: 34, height: 34, decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(11)), alignment: Alignment.center, child: Icon(icon, color: iconColor, size: 17)),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: txt))),
            if (badgeCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                constraints: const BoxConstraints(minWidth: 18),
                alignment: Alignment.center,
                child: Text('$badgeCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
              ),
            if (trailingText != null) Padding(padding: const EdgeInsets.only(left: 8), child: Text(trailingText, style: TextStyle(fontSize: 12, color: mut))),
            if (trailing != null)
              Padding(padding: const EdgeInsets.only(left: 8), child: trailing)
            else
              Padding(padding: const EdgeInsets.only(left: 8), child: Icon(Icons.chevron_right_rounded, color: mut, size: 18)),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Run analyzer**

Run: `C:\flutter\bin\flutter.bat analyze lib/ui/screens/profile/profile_screen.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/ui/screens/profile/profile_screen.dart
git commit -m "feat(nino): redesign Profile (Tôi) screen"
```

---

## Task 25: Redesign Notifications screen

**Files:**
- Modify: `lib/ui/screens/notifications/notification_screen.dart` (full rewrite)

**Interfaces:**
- Consumes: `CardRow` (Task 5). Keeps `NotificationProvider.{loadNotifications,loadUnreadCount,loadMore,markAllAsRead,markAsRead,notifications,unreadCount,isLoading,hasMore}` unchanged.

Note: the old screen showed a `Shimmer` skeleton during the initial load; this rewrite uses a plain `CircularProgressIndicator` instead, consistent with every other redesigned screen's loading state (Home, Relative list/detail, Event list). This drops the `shimmer` package usage here but does not remove the dependency (verify with a repo-wide search whether `shimmer` is still used elsewhere before considering removing it from `pubspec.yaml` — out of scope for this task either way).

- [ ] **Step 1: Replace the full content of `notification_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../providers/notification_provider.dart';
import '../../widgets/nino/card_row.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications(refresh: true);
      context.read<NotificationProvider>().loadUnreadCount();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<NotificationProvider>();
      if (!provider.isLoading && provider.hasMore) provider.loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final txt = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mut = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final fnt = isDark ? AppColors.textFaintDark : AppColors.textFaintLight;
    final pri = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final priSoft = isDark ? AppColors.primarySoftDark : AppColors.primarySoftLight;
    final mint = isDark ? AppColors.secondaryDark : AppColors.secondaryLight;
    final neutralSoft = isDark ? AppColors.neutralSoftDark : AppColors.neutralSoftLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        title: Text('Thông báo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: txt)),
        actions: [
          if (provider.unreadCount > 0)
            TextButton(onPressed: () => provider.markAllAsRead(), child: Text('Đọc hết', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: mint))),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await provider.loadNotifications(refresh: true);
          await provider.loadUnreadCount();
        },
        child: _buildBody(provider, txt, mut, fnt, pri, priSoft, neutralSoft),
      ),
    );
  }

  Widget _buildBody(NotificationProvider provider, Color txt, Color mut, Color fnt, Color pri, Color priSoft, Color neutralSoft) {
    if (provider.isLoading && provider.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.notifications.isEmpty) {
      return ListView(
        padding: const EdgeInsets.only(top: 90),
        children: [
          Center(
            child: Column(
              children: [
                Container(width: 104, height: 104, decoration: BoxDecoration(color: priSoft, borderRadius: BorderRadius.circular(34)), alignment: Alignment.center, child: Icon(Icons.notifications_none_rounded, size: 42, color: pri)),
                const SizedBox(height: 20),
                Text('Chưa có thông báo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: txt)),
                const SizedBox(height: 7),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text('Khi có sinh nhật, ngày giỗ hay hoá đơn tới hạn, NINO sẽ nhắc bạn ở đây.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: mut, height: 1.55)),
                ),
              ],
            ),
          ),
        ],
      );
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      itemCount: provider.notifications.length + (provider.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == provider.notifications.length) {
          return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
        }
        final n = provider.notifications[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: Opacity(
            opacity: n.isRead ? 0.68 : 1,
            child: CardRow(
              borderColor: n.isRead ? null : priSoft,
              onTap: () {
                if (!n.isRead) context.read<NotificationProvider>().markAsRead(n.id);
              },
              leading: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: n.isRead ? neutralSoft : priSoft, borderRadius: BorderRadius.circular(12)),
                alignment: Alignment.center,
                child: Icon(n.isRead ? Icons.notifications_rounded : Icons.notifications_active_rounded, color: n.isRead ? mut : pri, size: 18),
              ),
              title: n.title,
              meta: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(n.body, style: TextStyle(fontSize: 12, color: mut, height: 1.45), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(AppDateUtils.timeAgo(n.sentAt), style: TextStyle(fontSize: 11, color: fnt)),
                  ],
                ),
              ),
              trailing: !n.isRead ? Container(width: 8, height: 8, margin: const EdgeInsets.only(top: 4), decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle)) : null,
            ),
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 2: Run analyzer**

Run: `C:\flutter\bin\flutter.bat analyze lib/ui/screens/notifications/notification_screen.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/ui/screens/notifications/notification_screen.dart
git commit -m "feat(nino): redesign Notifications screen"
```

---

## Task 26: Full-project verification pass

**Files:** none (verification only — touches no source files).

**Interfaces:** none.

- [ ] **Step 1: Run the full analyzer**

Run: `C:\flutter\bin\flutter.bat analyze`

Baseline (recorded before Task 1 ran, on this same branch point): **47 pre-existing issues**, all `info`-level lints or 2 pre-existing `warning`s (`unused_field` in `auth_provider.dart`, `unnecessary_null_comparison` in `event_form_screen.dart`) — none touched by this plan, not this task's job to fix. Expected after this task: the same ~47 baseline issues, **plus zero new ones** — specifically, no `error`-level output (a compile error), and no lint on any file Tasks 1-25 created or modified. If analyze reports a new issue on a file this plan touched, it is very likely a leftover old `AppColors` token — `primaryGradient`, `headerGradient`, `tealGradient`, `accentGradient`, `surfaceLight`/`cardLight` used as a scaffold background — referenced somewhere Tasks 15-25 didn't touch (e.g. `splash_screen.dart`, `login_history_screen.dart`, `settings_screen.dart`, `google_signin_button.dart`, `google_logo.dart`). Update each remaining call site to the nearest Task 1 token (`coralGradient` for old brand gradients, `bgLight`/`bgDark` for scaffold backgrounds) and re-run until only the pre-existing baseline issues remain.

- [ ] **Step 2: Run the full test suite**

Run: `C:\flutter\bin\flutter.bat test`
Expected: `All tests passed!`

- [ ] **Step 3: Run the app on the emulator and compare against the design exports**

Run: `C:\flutter\bin\flutter.bat run -d emulator-5554` (an Android emulator; see Global Constraints — one is already configured as `Pixel_8` if none is running: `flutter emulators --launch Pixel_8`).

Walk every screen and compare against the corresponding export in the Claude Design project (`exports/01-chao-mung.png` through `18-them-su-kien-android-16-9.png`), in both light and dark (toggle via the header/Tôi switch): Chào mừng, Đăng ký, Home, Người thân (list/chi tiết/thêm/sửa), Sự kiện (list/loại/thêm), Lịch nghỉ lễ, Tôi, Thông báo. Note any visually broken layout (overflow, clipped text, wrong color) and fix inline before considering the redesign done.

- [ ] **Step 4: Commit any fixes from Steps 1-3**

```bash
git add -A
git commit -m "fix(nino): resolve analyzer/test/visual issues from full verification pass"
```

(Skip this step if Steps 1-3 found nothing to fix.)

---

## Notes / explicitly out of scope

- **Entrance animations**: the old screens used `flutter_animate` (`.animate().fadeIn().slideY()`, per-item staggered) extensively; the design source also has a lightweight `.anim` fade+slide per screen. This plan's rewrites drop per-item stagger animation for simplicity and consistency across 13 screens written in one pass. Restoring a single screen-level fade-in (wrapping each screen's root scrollable, ~250ms, matching the design's `.anim` class) is a reasonable follow-up but was intentionally left out here to keep every task's diff focused on layout/color — raise it as a small separate follow-up spec if wanted.
- **App icon / native launcher icon**: not touched by this plan (Flutter code only). Regenerating `android/`/`ios/` icon assets from the `NinoLogo` 1a design is a separate, native-build-affecting change — do it only if explicitly requested, via `flutter_launcher_icons` or manual asset export.
- **Holiday push notifications**: Task 14's "🔔 Nhắc tôi" only persists an on/off flag locally (`SharedPreferences`); it does not schedule a real local/push notification. Wiring that into `flutter_local_notifications`/Firebase is a separate feature.

