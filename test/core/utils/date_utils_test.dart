import 'package:flutter_test/flutter_test.dart';
import 'package:event_app/core/utils/date_utils.dart';

void main() {
  group('AppDateUtils.pastRelativeLabel', () {
    final now = DateTime(2026, 9, 8);

    test('dưới 1 tháng -> "N ngày trước"', () {
      final date = now.subtract(const Duration(days: 5));
      expect(AppDateUtils.pastRelativeLabel(date, now: now), '5 ngày trước');
    });

    test('từ 1 đến dưới 12 tháng -> "N tháng trước"', () {
      final date = DateTime(2026, 7, 28); // ~1 tháng trước 08/09/2026
      expect(AppDateUtils.pastRelativeLabel(date, now: now), '1 tháng trước');
    });

    test('đúng 1 năm trước (cùng ngày/tháng, khác năm) -> "1 năm trước"', () {
      final date = DateTime(2025, 9, 5);
      expect(AppDateUtils.pastRelativeLabel(date, now: now), '1 năm trước');
    });

    test('hôm nay hoặc tương lai -> "Hôm nay" (không dùng cho sự kiện chưa qua)', () {
      expect(AppDateUtils.pastRelativeLabel(now, now: now), 'Hôm nay');
    });
  });
}
