import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../models/event.dart';

/// Chip nhỏ cho biết 1 sự kiện là của ai — "🔔 Tôi" (relativeId null, sự
/// kiện cho bản thân) hoặc icon quan hệ + TÊN QUAN HỆ (VD "Vợ (Chồng)",
/// "Mẹ" — không phải tên riêng của người thân), nền theo đúng màu của quan
/// hệ đó (khớp màu avatar ở màn Người thân/Home để nhận diện nhất quán).
/// Dùng chung ở màn Sự kiện (titleTrailing) và Chi tiết sự kiện (header) —
/// tách khỏi `EventListScreen` để 2 màn không lặp lại cùng 1 logic.
Widget ownerChip(EventModel event, bool isDark) {
  final isSelf = event.relativeId == null;
  final label = isSelf ? 'Tôi' : (event.relativeGroupTypeDisplay ?? 'Người thân');
  final emoji = isSelf ? '🔔' : (event.relativeGroupTypeEmoji ?? '👤');
  final color = isDark
      ? (AppColors.groupTypeColorsDark[event.relativeGroupType] ?? AppColors.primaryDark)
      : (AppColors.groupTypeColors[event.relativeGroupType] ?? AppColors.primaryLight);
  final softColor = isDark
      ? (AppColors.groupTypeSoftColorsDark[event.relativeGroupType] ?? AppColors.primarySoftDark)
      : (AppColors.groupTypeSoftColors[event.relativeGroupType] ?? AppColors.primarySoftLight);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: softColor, borderRadius: BorderRadius.circular(999)),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 11)),
        const SizedBox(width: 3),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 84),
          child: Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

/// Nhãn số ngày tới sự kiện — "Hôm nay" (đỏ) hoặc "N ngày" (cam) cho sự
/// kiện sắp tới, "N ngày/tháng/năm trước" (xám) cho sự kiện đã qua. Dùng
/// chung ở màn Sự kiện (meta) và Chi tiết sự kiện (header).
Widget? eventDaysLabel(EventModel event, bool isDark) {
  final daysUntil = event.daysUntil;
  if (daysUntil == null) return null;
  if (daysUntil < 0) {
    final mut = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    return Text(
      AppDateUtils.pastRelativeLabel(event.eventDate),
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: mut),
    );
  }
  final String daysLabel = daysUntil == 0 ? 'Hôm nay' : '$daysUntil ngày';
  final daysColor = daysUntil == 0
      ? (isDark ? AppColors.errorDark : AppColors.error)
      : (isDark ? AppColors.amberDark : AppColors.amberLight);
  return Text(daysLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: daysColor));
}
