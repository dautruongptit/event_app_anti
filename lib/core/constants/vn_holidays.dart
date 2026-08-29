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
