import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatDateShort(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM').format(date);
  }

  static String formatTime(String? time) {
    if (time == null || time.isEmpty) return '';
    try {
      final parts = time.split(':');
      return '${parts[0]}:${parts[1]}';
    } catch (_) {
      return time;
    }
  }

  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  static String timeAgo(DateTime? dateTime) {
    if (dateTime == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return formatDate(dateTime);
  }

  static String daysUntilText(int? days) {
    if (days == null || days < 0) return '';
    if (days == 0) return 'Hôm nay';
    if (days == 1) return 'Ngày mai';
    return 'Còn $days ngày';
  }

  /// Nhãn "N ngày/tháng/năm trước" cho sự kiện đã qua ở nhóm ĐÃ QUA màn Sự
  /// kiện — khớp exports/Screenshot 2026-09-03 121127.png. Tính theo lịch
  /// (năm/tháng/ngày) chứ không chia tròn số ngày, để "đúng 1 năm trước"
  /// luôn ra "1 năm trước" thay vì lệch do tháng thiếu/đủ ngày khác nhau.
  static String pastRelativeLabel(DateTime eventDate, {DateTime? now}) {
    final today = _dateOnly(now ?? DateTime.now());
    final date = _dateOnly(eventDate);
    if (!date.isBefore(today)) return 'Hôm nay';

    var years = today.year - date.year;
    var months = today.month - date.month;
    if (today.day < date.day) months -= 1;
    if (months < 0) {
      years -= 1;
      months += 12;
    }
    final totalMonths = years * 12 + months;

    if (totalMonths >= 12) return '${totalMonths ~/ 12} năm trước';
    if (totalMonths >= 1) return '$totalMonths tháng trước';
    return '${today.difference(date).inDays} ngày trước';
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static int? calculateAge(DateTime? dateOfBirth) {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }
}
