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
