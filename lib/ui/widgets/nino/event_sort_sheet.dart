import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/event_list_sort.dart';

/// Nút tròn "⇅" mở bottom sheet chọn kiểu sắp xếp — đặt cạnh
/// [FilterChipsRow] ở màn Sự kiện, khớp
/// exports/Screenshot 2026-09-03 120905.png.
class EventSortButton extends StatelessWidget {
  final VoidCallback onTap;

  const EventSortButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final line2 = isDark ? AppColors.line2Dark : AppColors.line2Light;
    final txt = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(color: card, shape: BoxShape.circle, border: Border.all(color: line2)),
        alignment: Alignment.center,
        child: Icon(Icons.swap_vert_rounded, size: 18, color: txt),
      ),
    );
  }
}

/// Bottom sheet 4 lựa chọn sắp xếp — Gần nhất/Xa nhất/Theo tên A-Z/Theo
/// người thân. Trả về mode mới được chọn, hoặc null nếu người dùng đóng
/// sheet mà không chọn gì.
Future<EventSortMode?> showEventSortSheet({
  required BuildContext context,
  required EventSortMode current,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return showModalBottomSheet<EventSortMode>(
    context: context,
    backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
    builder: (ctx) {
      final txt = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
      final pri = isDark ? AppColors.primaryDark : AppColors.primaryLight;
      final line = isDark ? AppColors.lineDark : AppColors.lineLight;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sắp xếp theo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: txt)),
              const SizedBox(height: 14),
              ...EventSortMode.values.map((mode) {
                final selected = mode == current;
                return InkWell(
                  onTap: () => Navigator.of(ctx).pop(mode),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: line))),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            eventSortModeLabels[mode]!,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                              color: selected ? pri : txt,
                            ),
                          ),
                        ),
                        if (selected) Icon(Icons.check_rounded, color: pri, size: 20),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      );
    },
  );
}
