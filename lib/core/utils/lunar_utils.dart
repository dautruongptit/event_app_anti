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
