import 'package:flutter_test/flutter_test.dart';
import 'package:event_app/core/utils/event_list_sort.dart';
import 'package:event_app/models/event.dart';

/// Xây nhanh 1 EventModel cho test — chỉ set field cần thiết, còn lại theo
/// default. [daysUntil] nếu không truyền sẽ tự tính từ [eventDate] so với
/// [now] (giống cách backend trả về), để test khỏi phải tính tay.
EventModel _event({
  int id = 1,
  String title = 'Sự kiện',
  required DateTime eventDate,
  String? relativeName,
  String recurrenceType = 'YEARLY',
  int? daysUntil,
  DateTime? now,
}) {
  final today = _dateOnly(now ?? DateTime.now());
  final date = _dateOnly(eventDate);
  return EventModel(
    id: id,
    title: title,
    categoryId: 1,
    categoryCode: 'KHAC',
    categoryName: 'Khác',
    categoryIcon: '',
    categoryColor: '#FF5A5F',
    eventDate: eventDate,
    relativeName: relativeName,
    recurrenceType: recurrenceType,
    daysUntil: daysUntil ?? date.difference(today).inDays,
  );
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

void main() {
  // "Hôm nay" cố định trong mọi test để phép tính tuần này/tuần sau/tháng
  // sau không phụ thuộc ngày chạy test thực tế.
  final now = DateTime(2026, 9, 8);

  group('filterByStatus', () {
    final events = [
      _event(id: 1, title: 'Sắp tới', eventDate: now.add(const Duration(days: 3)), now: now),
      _event(id: 2, title: 'Đã qua', eventDate: now.subtract(const Duration(days: 3)), now: now),
      _event(id: 3, title: 'Âm lịch', eventDate: now.add(const Duration(days: 5)), recurrenceType: 'LUNAR_YEARLY', now: now),
      _event(id: 4, title: 'Hôm nay', eventDate: now, now: now),
    ];

    test('all trả về nguyên danh sách', () {
      final result = EventListSort.filterByStatus(events, EventStatusFilter.all, now: now);
      expect(result.length, 4);
    });

    test('upcoming chỉ lấy sự kiện có daysUntil >= 0 (kể cả hôm nay)', () {
      final result = EventListSort.filterByStatus(events, EventStatusFilter.upcoming, now: now);
      expect(result.map((e) => e.id), containsAll([1, 3, 4]));
      expect(result.map((e) => e.id), isNot(contains(2)));
    });

    test('past chỉ lấy sự kiện có daysUntil < 0', () {
      final result = EventListSort.filterByStatus(events, EventStatusFilter.past, now: now);
      expect(result.map((e) => e.id).toList(), [2]);
    });

    test('lunar chỉ lấy recurrenceType == LUNAR_YEARLY', () {
      final result = EventListSort.filterByStatus(events, EventStatusFilter.lunar, now: now);
      expect(result.map((e) => e.id).toList(), [3]);
    });
  });

  group('buildGroups — sort theo Gần nhất/Xa nhất (có header)', () {
    final thisWeek = _event(id: 1, title: 'Trong tuần', eventDate: now.add(const Duration(days: 1)), now: now);
    final nextWeek = _event(id: 2, title: 'Tuần sau', eventDate: now.add(const Duration(days: 10)), now: now);
    final thisMonth = _event(id: 3, title: 'Cuối tháng', eventDate: DateTime(now.year, now.month, 28), now: now);
    final nextMonth = _event(id: 4, title: 'Tháng sau', eventDate: DateTime(now.year, now.month + 1, 15), now: now);
    final farMonth = _event(id: 5, title: 'Xa hơn', eventDate: DateTime(now.year, now.month + 3, 1), now: now);
    final pastRecent = _event(id: 6, title: 'Qua gần đây', eventDate: now.subtract(const Duration(days: 5)), now: now);
    final pastOld = _event(id: 7, title: 'Qua đã lâu', eventDate: now.subtract(const Duration(days: 200)), now: now);

    final events = [farMonth, pastOld, nextMonth, thisWeek, pastRecent, thisMonth, nextWeek];

    test('Gần nhất: bucket theo thứ tự thời gian, ĐÃ QUA luôn ở cuối, gần nhất trước', () {
      final groups = EventListSort.buildGroups(events, EventSortMode.nearest, now: now);

      final headers = groups.map((g) => g.header).toList();
      expect(headers, ['TUẦN NÀY', 'TUẦN SAU', 'THÁNG NÀY', 'THÁNG SAU', 'Tháng ${farMonth.eventDate.month}, ${farMonth.eventDate.year}', 'ĐÃ QUA']);

      expect(groups.last.header, 'ĐÃ QUA');
      // Trong nhóm Đã qua: gần nhất (ít ngày trước nhất) đứng trước.
      expect(groups.last.events.map((e) => e.id).toList(), [6, 7]);
    });

    test('Xa nhất: đảo thứ tự bucket (xa nhất trước) và đảo thứ tự trong từng bucket, ĐÃ QUA vẫn luôn ở cuối', () {
      final groups = EventListSort.buildGroups(events, EventSortMode.farthest, now: now);

      expect(groups.last.header, 'ĐÃ QUA');
      // Xa nhất: sự kiện đã qua lâu nhất đứng trước trong nhóm Đã qua.
      expect(groups.last.events.map((e) => e.id).toList(), [7, 6]);
      // Bucket xa nhất (Tháng xa hơn) phải đứng TRƯỚC bucket Tuần này.
      final headers = groups.map((g) => g.header).toList();
      expect(headers.first, isNot('TUẦN NÀY'));
      expect(headers.indexOf('TUẦN NÀY'), headers.length - 2); // ngay trước ĐÃ QUA
    });
  });

  group('buildGroups — sort theo tên/người thân (flat, không header)', () {
    final events = [
      _event(id: 1, title: 'Bánh sinh nhật', eventDate: now.add(const Duration(days: 2)), relativeName: 'Mẹ', now: now),
      _event(id: 2, title: 'Ăn tân gia', eventDate: now.subtract(const Duration(days: 1)), relativeName: 'Bố', now: now),
      _event(id: 3, title: 'Cúng giỗ', eventDate: now.add(const Duration(days: 20)), relativeName: null, now: now),
    ];

    test('Theo tên A-Z: không có header, sự kiện đã qua bị đẩy xuống cuối', () {
      final groups = EventListSort.buildGroups(events, EventSortMode.nameAsc, now: now);
      expect(groups.every((g) => g.header == null), isTrue);

      final allIds = groups.expand((g) => g.events).map((e) => e.id).toList();
      // 2 (Ăn tân gia) đã qua -> phải nằm cuối, dù A-Z thì nó đứng đầu.
      expect(allIds.last, 2);
      // Trong phần chưa qua (1, 3), sắp theo tên A-Z: "Bánh..." trước "Cúng...".
      expect(allIds.sublist(0, allIds.length - 1), [1, 3]);
    });

    test('Theo người thân: nhóm theo tên người thân (Tôi nếu null), sự kiện đã qua vẫn ở cuối', () {
      final groups = EventListSort.buildGroups(events, EventSortMode.byRelative, now: now);
      expect(groups.every((g) => g.header == null), isTrue);

      final allIds = groups.expand((g) => g.events).map((e) => e.id).toList();
      expect(allIds.last, 2); // đã qua luôn cuối cùng
    });

    test('Theo tên A-Z: tên có dấu (Đ, ơ, ...) xếp lẫn theo vần, không bị đẩy xuống cuối vì Unicode thô', () {
      final withDiacritics = [
        _event(id: 10, title: 'Đóng tiền điện', eventDate: now.add(const Duration(days: 1)), now: now),
        _event(id: 11, title: 'Ăn tân gia', eventDate: now.add(const Duration(days: 1)), now: now),
        _event(id: 12, title: 'Sinh nhật', eventDate: now.add(const Duration(days: 1)), now: now),
      ];
      final groups = EventListSort.buildGroups(withDiacritics, EventSortMode.nameAsc, now: now);
      final ids = groups.expand((g) => g.events).map((e) => e.id).toList();
      // Vần: Ăn(A) -> Đóng(D) -> Sinh(S) — không phải Unicode thô (đ > z).
      expect(ids, [11, 10, 12]);
    });
  });
}
