# Zalo-blue Redesign (Phase 1) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reskin the NINO Flutter app to a Zalo-inspired blue color palette (flat, high-contrast, familiar to Vietnamese users) by rewriting the central `AppColors` token file, then verify the change on the Home screen (light + dark) and do a light regression pass over the other 13 screens.

**Architecture:** Every screen in this app reads colors through `lib/core/constants/app_colors.dart` (`AppColors`), and `lib/core/theme/app_theme.dart` (`AppTheme`) wires those same tokens into the global `ThemeData` (buttons, cards, inputs, bottom nav, chips, dialogs, snackbars). Several decorative gradient tokens (`headerGradient`, `primaryGradient`, `tealGradient`, `accentGradient`) are shared across Home, Profile, Login, Event List, Event Detail, Event Form, and Relative List. Because of this, editing the token *values* in one file cascades the new palette across almost the whole app without touching per-screen widget code. This plan changes only `app_colors.dart` (data), adds a regression test locking in the new values, and then spends the remaining tasks on visual verification — no other source file is expected to change.

**Tech Stack:** Flutter 3.x / Dart, `flutter_test` for unit tests, Android emulator (`emulator-5554`) + `adb` for visual verification (no Flutter widget-test infra exists in this repo beyond a placeholder — see spec).

**Spec:** `docs/superpowers/specs/2026-08-26-zalo-blue-redesign-design.md`

## Global Constraints

- Keep the NINO brand name and current screen structure/IA — this phase only changes colors, not layout, copy, font sizes, or navigation (per spec's "Bối cảnh" and "Ngoài phạm vi").
- `eventTypeColors` and `groupTypeColors` maps in `AppColors` must NOT change — they are functional category colors, not brand colors (spec: "Màu phân loại (event type / group type): giữ nguyên phần lớn").
- Gradient tokens (`primaryGradient`, `headerGradient`, `tealGradient`, `accentGradient`) must keep their existing `LinearGradient` shape (same `colors` list length, same `begin`/`end`) — only the color *values* change, to a flat single repeated color. This avoids touching the 8+ files that consume `gradient:` properties directly (spec: "Lý do dùng gradient 2 điểm dừng cùng màu").
- `darkGradient`, all text colors, `surfaceLight/Dark`, `cardLight/Dark`, `bgDark`, and the status colors (`error`/`success`/`warning`/`info`) are unchanged — only the tokens listed in the spec's color table change.
- Exact new hex values (from spec table): `primaryLight=#0068FF`, `primaryDark=#4C9AFF`, `secondaryLight=#00A3B8`, `secondaryDark=#26C6DA`, `accentLight=#0068FF`, `accentDark=#4C9AFF`, `bgLight=#F5F8FC`.

---

### Task 1: Rewrite `AppColors` tokens + regression test

**Files:**
- Create: `test/core/app_colors_test.dart`
- Modify: `lib/core/constants/app_colors.dart` (full rewrite of color values only — same class shape)

**Interfaces:**
- Consumes: nothing (this is the root token file).
- Produces: `AppColors.primaryLight/primaryDark/secondaryLight/secondaryDark/accentLight/accentDark/bgLight` (new `Color` values), `AppColors.primaryGradient/headerGradient/tealGradient/accentGradient` (same `LinearGradient` fields, new flat colors). Every other screen file (`home_screen.dart`, `profile_screen.dart`, `login_screen.dart`, `event_list_screen.dart`, `event_detail_screen.dart`, `event_form_screen.dart`, `relative_list_screen.dart`, `relative_detail_screen.dart`, `event_type_selection_screen.dart`) consumes these by name — Tasks 2–4 verify them visually, no code in those files changes in this plan.

- [ ] **Step 1: Write the failing test**

Create `test/core/app_colors_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:event_app/core/constants/app_colors.dart';

void main() {
  group('AppColors — Zalo-blue redesign tokens', () {
    test('primary is Zalo blue', () {
      expect(AppColors.primaryLight, const Color(0xFF0068FF));
      expect(AppColors.primaryDark, const Color(0xFF4C9AFF));
    });

    test('secondary is harmonized teal-cyan', () {
      expect(AppColors.secondaryLight, const Color(0xFF00A3B8));
      expect(AppColors.secondaryDark, const Color(0xFF26C6DA));
    });

    test('accent reuses primary (no third hue, stays flat)', () {
      expect(AppColors.accentLight, AppColors.primaryLight);
      expect(AppColors.accentDark, AppColors.primaryDark);
    });

    test('light background is soft blue-gray', () {
      expect(AppColors.bgLight, const Color(0xFFF5F8FC));
    });

    test('decorative gradients are flat (every stop the same color)', () {
      for (final gradient in [
        AppColors.primaryGradient,
        AppColors.headerGradient,
        AppColors.tealGradient,
        AppColors.accentGradient,
      ]) {
        expect(
          gradient.colors.toSet().length,
          1,
          reason: 'Gradient should be flat (all stops same color) per design spec',
        );
      }
    });

    test('event type and group type colors are unchanged (functional, not brand)', () {
      expect(AppColors.eventTypeColors['SINH_NHAT'], const Color(0xFFF87171));
      expect(AppColors.eventTypeColors['LE'], const Color(0xFFFDCB6E));
      expect(AppColors.groupTypeColors['GIA_DINH'], const Color(0xFFF87171));
    });

    test('unrelated tokens are unchanged', () {
      expect(AppColors.bgDark, const Color(0xFF0D1117));
      expect(AppColors.error, const Color(0xFFFF6B6B));
      expect(AppColors.textPrimaryLight, const Color(0xFF212121));
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/app_colors_test.dart`
Expected: FAIL — `primaryLight` still equals `Color(0xFFF87171)` (the old coral), not `Color(0xFF0068FF)`.

- [ ] **Step 3: Rewrite `lib/core/constants/app_colors.dart`**

Replace the entire file with:

```dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary palette — Zalo-blue
  static const Color primaryLight = Color(0xFF0068FF);
  static const Color primaryDark = Color(0xFF4C9AFF);

  // Secondary — Teal-cyan (hài hoà với xanh dương)
  static const Color secondaryLight = Color(0xFF00A3B8);
  static const Color secondaryDark = Color(0xFF26C6DA);

  // Accent — dùng lại primary để nhất quán/phẳng (bỏ hue thứ 3)
  static const Color accentLight = Color(0xFF0068FF);
  static const Color accentDark = Color(0xFF4C9AFF);

  // Backgrounds
  static const Color bgLight = Color(0xFFF5F8FC);
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

  // Gradients — phẳng (2 điểm dừng cùng màu) theo phong cách Zalo-blue.
  // Giữ nguyên shape LinearGradient (colors/begin/end) để không phải sửa
  // từng widget đang dùng `gradient:` — chỉ đổi giá trị màu.
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0068FF), Color(0xFF0068FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF0068FF), Color(0xFF0068FF)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient tealGradient = LinearGradient(
    colors: [Color(0xFF00A3B8), Color(0xFF00A3B8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF0068FF), Color(0xFF0068FF)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0D1117), Color(0xFF161B22)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Event type colors (from Figma) — giữ nguyên, màu chức năng phân loại,
  // không phải màu thương hiệu.
  static const Map<String, Color> eventTypeColors = {
    'SINH_NHAT': Color(0xFFF87171),
    'KY_NIEM': Color(0xFFF87171),
    'LE': Color(0xFFFDCB6E),
    'NHA_O': Color(0xFF26A69A),
    'HOA_DON': Color(0xFFFFC107),
    'MUA_SAM': Color(0xFF26A69A),
    'KHAC': Color(0xFF9E9E9E),
  };

  // Group type colors — giữ nguyên
  static const Map<String, Color> groupTypeColors = {
    'GIA_DINH': Color(0xFFF87171),
    'VO_CHONG': Color(0xFF26A69A),
    'CON_CAI': Color(0xFFCE93D8),
    'BAN_BE': Color(0xFFFFB74D),
  };
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/app_colors_test.dart`
Expected: PASS (all 7 tests green).

- [ ] **Step 5: Run static analysis on the whole project**

Run: `flutter analyze`
Expected: same baseline issues as before this change (pre-existing `deprecated_member_use`/`prefer_const_constructors` info/warnings only) — **no new errors**. If a new error appears, it means some file uses a removed/renamed field; re-check against the file above (the class shape must stay identical — only hex values changed).

Note on `lib/core/theme/app_theme.dart`: the spec allows for changes here "if needed". It is not needed — `AppTheme.lightTheme`/`darkTheme` reference `AppColors.primaryLight`, `AppColors.secondaryLight`, etc. **by name**, not by literal value, so the new hex values flow through automatically. A clean `flutter analyze` in this step is the confirmation that nothing there broke; leave `app_theme.dart` untouched.

- [ ] **Step 6: Commit**

```bash
cd "D:\My PC\even\mobile\event_app_anti"
git add lib/core/constants/app_colors.dart test/core/app_colors_test.dart
git commit -m "feat: đổi bảng màu sang Zalo-blue (Phase 1 redesign)

Đổi primary/secondary/accent/bgLight + làm phẳng các gradient trang trí
(headerGradient/primaryGradient/tealGradient/accentGradient) theo spec
docs/superpowers/specs/2026-08-26-zalo-blue-redesign-design.md. Giữ
nguyên eventTypeColors/groupTypeColors (màu chức năng). Vì AppColors
được dùng chung toàn app, thay đổi này lan ra hầu hết header/nút/thẻ mà
không cần sửa từng màn hình.

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>"
```

---

### Task 2: Verify Home screen — light mode

**Files:** none (verification only, no code changes expected).

**Interfaces:**
- Consumes: `AppColors` from Task 1 (already applied — this task only looks at the rendered result).
- Produces: a pass/fail visual confirmation that Task 3/4 depend on before continuing.

**Prerequisites:** the local dev backend must be running and the app must point at it (this repo's established pattern this session — see `lib/core/constants/api_constants.dart`; if `baseUrl` currently points at `https://event.thongtinchinhhieu.site` and that's unreachable, temporarily switch it to `http://10.0.2.2:8080` and start the backend with `./mvnw.cmd spring-boot:run` from `D:\My PC\even\event`, then revert `api_constants.dart` after this plan is done — that revert is NOT part of this plan's scope, just don't leave it committed).

- [ ] **Step 1: Build and run the app on the emulator**

```bash
export PATH="/c/flutter/bin:$PATH"
cd "/d/My PC/even/mobile/event_app_anti"
"/c/Users/PC/AppData/Local/Android/Sdk/platform-tools/adb.exe" devices
flutter run -d emulator-5554
```

Wait for `Installing build\app\outputs\flutter-apk\app-debug.apk...` to finish, then let the app finish loading (5-10s).

- [ ] **Step 2: Log in and land on Home**

If a previous session token exists, the app should route straight to `/home` (session-restore redirect fixed earlier this session in `app_router.dart`). If it lands on the splash/login screen instead, log in with the test account `claude.test.push@example.com` / `TestPush123` (created earlier this session) or the account currently available, via the email/password fields on `/login`.

- [ ] **Step 3: Screenshot Home in light mode**

Ensure dark mode is OFF (Profile → Cài đặt → Chế độ tối toggle). Then:

```bash
"/c/Users/PC/AppData/Local/Android/Sdk/platform-tools/adb.exe" exec-out screencap -p > "D:\My PC\even\mobile\event_app_anti\.superpowers\verify\home-light.png"
```

(create the `.superpowers/verify/` directory first if it doesn't exist — it's already covered by the `.superpowers/` gitignore rule added during brainstorming.)

- [ ] **Step 4: Visually check against this list**

Open `home-light.png` and confirm every item:
- Top header block (greeting + "Nhắc Sự Kiện" title) is filled with solid blue `#0068FF` (not the old coral-to-teal gradient), with rounded bottom corners.
- Page background behind the cards is a soft blue-gray (`#F5F8FC`), not the old pink-tinted white.
- The two "Sự kiện sắp tới" cards are blue-toned (one may use the teal-cyan secondary `#00A3B8` per `tealGradient`), not coral/mint.
- The active tab underline ("Người thân" / "Sự kiện của tôi") and active bottom-nav icon ("Home") are blue, not coral.
- Text is still fully legible (dark text on white cards, white text on blue header) — no low-contrast combinations.
- No layout shift, overflow, or clipped text compared to before this change (this phase only touches colors).

If anything fails this list, stop and diagnose (check whether some screen is using an old hard-coded `Color(0xFF...)` literal instead of `AppColors` — see spec's "Rủi ro" section for two known candidates in `home_screen.dart`) before moving to Task 3.

---

### Task 3: Verify Home screen — dark mode

**Files:** none (verification only).

**Interfaces:**
- Consumes: `AppColors.primaryDark`/`secondaryDark` from Task 1.
- Produces: pass/fail confirmation.

- [ ] **Step 1: Toggle dark mode**

In the running app: bottom nav → "Tôi" → "Cài đặt" section → "Chế độ tối" switch → turn ON.

- [ ] **Step 2: Navigate back to Home and screenshot**

```bash
"/c/Users/PC/AppData/Local/Android/Sdk/platform-tools/adb.exe" exec-out screencap -p > "D:\My PC\even\mobile\event_app_anti\.superpowers\verify\home-dark.png"
```

- [ ] **Step 3: Visually check against this list**

Open `home-dark.png` and confirm:
- Background is the existing dark neutral (`#0D1117`) — unchanged by this phase.
- Blue accents (active tab, active bottom-nav icon, any blue text/icons) use the lighter `#4C9AFF`, clearly visible against the dark background (not the same saturated `#0068FF` used in light mode, which would look muddy on dark).
- Card backgrounds (`#1C2333`) and text remain readable — no regression from before this change.

---

### Task 4: Light regression pass over the remaining screens

**Files:** none expected. If Step 2 finds a genuine hard-coded color bug (a screen showing leftover coral/pink that isn't an event-type badge), note it in the final report as a follow-up item for the next phase — do NOT fix it in this task (out of scope per spec: "không bắt buộc phải dọn hết trong đợt này"). Do NOT change layout, copy, or fix unrelated bugs noticed along the way.

**Interfaces:**
- Consumes: `AppColors` from Task 1.
- Produces: a written pass/fail list per screen (report to the user at the end), used to decide whether a Phase 2 "polish the rest" plan is needed.

- [ ] **Step 1: Get a UI dump helper ready**

Reuse this pattern (already proven this session) to find any element's tap coordinates when the ones below aren't enough:

```bash
ADB="/c/Users/PC/AppData/Local/Android/Sdk/platform-tools/adb.exe"
MSYS_NO_PATHCONV=1 "$ADB" shell uiautomator dump /sdcard/wd.xml
MSYS_NO_PATHCONV=1 "$ADB" pull /sdcard/wd.xml "D:\My PC\even\mobile\event_app_anti\wd.xml"
grep -o '<node[^>]*content-desc="EXACT_LABEL"[^>]*>' "D:\My PC\even\mobile\event_app_anti\wd.xml"
```
(replace `EXACT_LABEL` with the Vietnamese button/tab text you're looking for; the `bounds="[x1,y1][x2,y2]"` attribute gives you the tap center.)

Known-stable bottom-nav taps on this emulator (1080×2400, from this session): Home `(112, 2263)`, Người thân `(338, 2263)`, Sự kiện `(562, 2263)`, Tôi `(945, 2263)`.

- [ ] **Step 2: Walk through each screen and screenshot**

For each screen below, navigate to it, run:
```bash
"/c/Users/PC/AppData/Local/Android/Sdk/platform-tools/adb.exe" exec-out screencap -p > "D:\My PC\even\mobile\event_app_anti\.superpowers\verify\<screen-name>.png"
```
then check: header/primary buttons are blue (not coral), background isn't pink-tinted, text stays legible, no broken layout.

  - [ ] **Login** (`/login` — log out first via Tôi → Đăng xuất, or navigate to `/register` then tap "Đã có tài khoản? Đăng nhập ngay"): check the header gradient block and the primary "Đăng nhập" button are blue.
  - [ ] **Register** (tap "Tạo tài khoản mới" from the landing/splash screen): check the "Đăng ký với Google" card border/accents and any blue call-to-action.
  - [ ] **Sự kiện (Event List)** (bottom nav "Sự kiện"): check the header block and the "Tất cả"/filter chip active state are blue; confirm event category badges (đỏ=sinh nhật, vàng=lễ, xám=khác) are unchanged, not blue.
  - [ ] **Event Detail** (tap any event card from the list): check the hero header gradient is blue, the "lặp lại" badge (uses `secondaryLight`) is teal-cyan not the old teal-green, still readable.
  - [ ] **Event Form** ("Thêm sự kiện" button on Event List): check the submit button and any accent icons are blue.
  - [ ] **Relative List (Người thân)** (bottom nav "Người thân"): check header block is blue; group badges (Gia đình=đỏ, Vợ/Chồng=teal, Con cái=tím, Bạn bè=cam) unchanged.
  - [ ] **Relative Detail** (tap a relative from the list): check icons using `secondaryLight` (birthday cake icon, info icons) read as teal-cyan and are legible against their backgrounds.
  - [ ] **Notifications** (bell icon top-left on Home, or Tôi → Thông báo): check unread badge/background still reads clearly; this screen mostly uses text, so mainly confirm no leftover coral highlight.
  - [ ] **Profile (Tôi)**: already spot-checked in Task 2/3 setup — confirm the header block is blue and stats numbers/icons match the new palette.
  - [ ] **Settings** (Tôi → Cài đặt, or the dedicated settings screen if separate from the inline section): check toggle/accent colors.
  - [ ] **Login History (Bảo mật)** (Tôi → Bảo mật): check any highlighted "current session" row uses blue, not coral.
  - [ ] **Event Type Selection** (if reachable from the "Thêm sự kiện" flow): check `secondaryLight`-colored icons (per earlier grep) read as teal-cyan.

- [ ] **Step 3: Report findings**

Summarize, screen by screen, pass/fail against the checklist in Step 2. For any screen that still shows old coral/pink where it shouldn't (i.e., NOT an event-type or group-type badge, which are intentionally unchanged), list the exact file/line if you can find it via `grep -rn "0xFFF87171\|0xFFFD79A8\|0xFFE84393" lib/ui/screens/<file>` — but do not fix it in this task; hand it to the user as a candidate item for the Phase 2 "lan ra toàn app" follow-up.

---

## Self-Review Notes (for whoever executes this plan)

- Task 1 is the only task that changes code; Tasks 2–4 are verification and produce a report, not commits (unless Task 1's commit needs a follow-up fix, in which case treat that as a new Task 1b with its own test-fix-verify-commit cycle).
- If Task 2's checklist fails because of an old hard-coded color literal (not a full AppColors token), fix that literal in a small follow-up commit, re-run Task 1's test suite plus `flutter analyze`, and re-screenshot before moving on — don't silently patch and move on without re-verifying.
