import '../../models/event.dart';

/// 4 chip trạng thái ở đầu màn Sự kiện — khớp thiết kế
/// exports/Screenshot 2026-09-03 120905.png. Thay thế bộ lọc theo tháng cũ.
enum EventStatusFilter { all, upcoming, lunar, past }

const Map<EventStatusFilter, String> eventStatusFilterLabels = {
  EventStatusFilter.all: 'Tất cả',
  EventStatusFilter.upcoming: 'Sắp tới',
  EventStatusFilter.lunar: 'Âm lịch',
  EventStatusFilter.past: 'Đã qua',
};

/// 4 lựa chọn ở bottom sheet nút sắp xếp (⇅).
enum EventSortMode { nearest, farthest, nameAsc, byRelative }

const Map<EventSortMode, String> eventSortModeLabels = {
  EventSortMode.nearest: 'Gần nhất',
  EventSortMode.farthest: 'Xa nhất',
  EventSortMode.nameAsc: 'Theo tên A-Z',
  EventSortMode.byRelative: 'Theo người thân',
};

/// 1 nhóm sự kiện để hiển thị trong ListView — [header] null nghĩa là
/// không hiện tiêu đề nhóm (chế độ sort theo tên/người thân: danh sách
/// phẳng, xem [EventListSort.buildGroups]).
class EventGroup {
  final String? header;
  final List<EventModel> events;
  const EventGroup({this.header, required this.events});
}

/// Lọc + sắp xếp + gom nhóm danh sách sự kiện cho màn Sự kiện — tách thành
/// hàm thuần (không phụ thuộc BuildContext/Provider) để test được độc lập.
/// Toàn bộ tính toán chạy phía client trên danh sách đã tải (API
/// GET /events không phân trang), không cần đổi backend.
class EventListSort {
  /// Sự kiện được coi là "đã qua" khi backend đã tính sẵn (daysUntil < 0);
  /// nếu thiếu daysUntil thì so ngày (không giờ) với hôm nay. daysUntil == 0
  /// (hôm nay) KHÔNG tính là đã qua — vẫn thuộc nhóm sắp tới/tuần này.
  static bool _isPast(EventModel e, DateTime today) {
    if (e.daysUntil != null) return e.daysUntil! < 0;
    final d = _dateOnly(e.eventDate);
    return d.isBefore(today);
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static List<EventModel> filterByStatus(
    List<EventModel> events,
    EventStatusFilter filter, {
    DateTime? now,
  }) {
    final today = _dateOnly(now ?? DateTime.now());
    switch (filter) {
      case EventStatusFilter.all:
        return events;
      case EventStatusFilter.upcoming:
        return events.where((e) => !_isPast(e, today)).toList();
      case EventStatusFilter.past:
        return events.where((e) => _isPast(e, today)).toList();
      case EventStatusFilter.lunar:
        return events.where((e) => e.recurrenceType == 'LUNAR_YEARLY').toList();
    }
  }

  static int _byDateAsc(EventModel a, EventModel b) => a.eventDate.compareTo(b.eventDate);

  /// Bỏ dấu tiếng Việt trước khi so sánh cho "Theo tên A-Z"/"Theo người
  /// thân" — so sánh Unicode thô (`"đ"` = U+0111, sau cả `z` = U+007A) sẽ
  /// đẩy mọi tên có dấu (VD "Đóng tiền điện") xuống cuối danh sách một
  /// cách vô lý thay vì xếp cạnh "D" như người dùng mong đợi.
  static final Map<String, String> _vnDiacriticMap = {
    for (final ch in 'àáạảãâầấậẩẫăằắặẳẵ'.split('')) ch: 'a',
    for (final ch in 'èéẹẻẽêềếệểễ'.split('')) ch: 'e',
    for (final ch in 'ìíịỉĩ'.split('')) ch: 'i',
    for (final ch in 'òóọỏõôồốộổỗơờớợởỡ'.split('')) ch: 'o',
    for (final ch in 'ùúụủũưừứựửữ'.split('')) ch: 'u',
    for (final ch in 'ỳýỵỷỹ'.split('')) ch: 'y',
    'đ': 'd',
  };

  static String _foldVietnamese(String input) {
    final buffer = StringBuffer();
    for (final rune in input.toLowerCase().runes) {
      final ch = String.fromCharCode(rune);
      buffer.write(_vnDiacriticMap[ch] ?? ch);
    }
    return buffer.toString();
  }

  static int _byNameAsc(EventModel a, EventModel b) =>
      _foldVietnamese(a.title).compareTo(_foldVietnamese(b.title));

  static String _relativeLabel(EventModel e) => e.relativeName ?? 'Tôi';

  static int _byRelativeAsc(EventModel a, EventModel b) {
    final c = _foldVietnamese(_relativeLabel(a)).compareTo(_foldVietnamese(_relativeLabel(b)));
    return c != 0 ? c : _byNameAsc(a, b);
  }

  /// Nhãn nhóm theo mốc thời gian tương đối — khớp
  /// exports/Screenshot 2026-09-03 120905.png ("TUẦN NÀY") và
  /// exports/Screenshot 2026-09-03 121127.png ("ĐÃ QUA"). Tuần tính
  /// Thứ 2 -> Chủ nhật.
  static String _upcomingBucketLabel(DateTime date, DateTime today) {
    final weekday = today.weekday; // 1 = Thứ 2 ... 7 = Chủ nhật
    final thisWeekStart = today.subtract(Duration(days: weekday - 1));
    final thisWeekEnd = thisWeekStart.add(const Duration(days: 6));
    final nextWeekStart = thisWeekEnd.add(const Duration(days: 1));
    final nextWeekEnd = nextWeekStart.add(const Duration(days: 6));
    final nextMonthRef = DateTime(today.year, today.month + 1, 1);

    bool inRange(DateTime d, DateTime start, DateTime end) =>
        !d.isBefore(start) && !d.isAfter(end);

    if (inRange(date, thisWeekStart, thisWeekEnd)) return 'TUẦN NÀY';
    if (inRange(date, nextWeekStart, nextWeekEnd)) return 'TUẦN SAU';
    if (date.year == today.year && date.month == today.month) return 'THÁNG NÀY';
    if (date.year == nextMonthRef.year && date.month == nextMonthRef.month) return 'THÁNG SAU';
    return 'Tháng ${date.month}, ${date.year}';
  }

  /// Gom [events] (đã lọc theo status ở màn hình, hoặc toàn bộ) thành các
  /// [EventGroup] để hiển thị, theo [mode] chọn ở bottom sheet sắp xếp.
  ///
  /// - Gần nhất/Xa nhất: gom theo mốc thời gian (Tuần này/Tuần sau/Tháng
  ///   này/Tháng sau/Tháng xa hơn), nhóm ĐÃ QUA luôn ở CUỐI bất kể mode.
  /// - Tên A-Z/Người thân: danh sách phẳng (không header), sự kiện đã qua
  ///   vẫn bị đẩy xuống cuối — theo đúng yêu cầu "Sự kiện đã qua hiển thị
  ///   ở dưới cùng" áp dụng cho mọi kiểu sắp xếp.
  static List<EventGroup> buildGroups(
    List<EventModel> events,
    EventSortMode mode, {
    DateTime? now,
  }) {
    final today = _dateOnly(now ?? DateTime.now());
    final upcoming = events.where((e) => !_isPast(e, today)).toList();
    final past = events.where((e) => _isPast(e, today)).toList();

    if (mode == EventSortMode.nameAsc || mode == EventSortMode.byRelative) {
      final cmp = mode == EventSortMode.nameAsc ? _byNameAsc : _byRelativeAsc;
      upcoming.sort(cmp);
      past.sort(cmp);
      final groups = <EventGroup>[];
      if (upcoming.isNotEmpty) groups.add(EventGroup(events: upcoming));
      if (past.isNotEmpty) groups.add(EventGroup(events: past));
      return groups;
    }

    final ascending = mode == EventSortMode.nearest;

    // Bucket luôn được tính trên thứ tự thời gian TĂNG DẦN (để nhãn nhóm
    // được gán nhất quán bất kể mode), sau đó đảo cả thứ tự bucket lẫn thứ
    // tự trong từng bucket khi Xa nhất.
    final ascUpcoming = List<EventModel>.from(upcoming)..sort(_byDateAsc);
    final buckets = <String, List<EventModel>>{};
    for (final e in ascUpcoming) {
      final label = _upcomingBucketLabel(_dateOnly(e.eventDate), today);
      buckets.putIfAbsent(label, () => []).add(e);
    }
    var groups = buckets.entries.map((en) => EventGroup(header: en.key, events: en.value)).toList();
    if (!ascending) {
      groups = groups.reversed
          .map((g) => EventGroup(header: g.header, events: g.events.reversed.toList()))
          .toList();
    }

    // ĐÃ QUA: gần nhất trước (mới qua gần đây) khi Gần nhất, xa nhất trước
    // (qua đã lâu) khi Xa nhất — luôn là nhóm cuối cùng.
    past.sort((a, b) => ascending ? _byDateAsc(b, a) : _byDateAsc(a, b));
    if (past.isNotEmpty) groups.add(EventGroup(header: 'ĐÃ QUA', events: past));

    return groups;
  }
}
