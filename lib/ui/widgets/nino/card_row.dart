import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Standard list row: a leading icon/avatar, a title + optional meta
/// line, and an optional trailing widget — used for people, events,
/// notifications and holidays lists.
class CardRow extends StatelessWidget {
  final Widget leading;
  final String title;
  final Widget? meta;
  final Widget? trailing;
  /// Widget nhỏ hiện ngay bên phải [title] (cùng hàng, khác với [trailing]
  /// nằm ở rìa phải cả row) — VD chip chủ sở hữu ở màn Sự kiện.
  final Widget? titleTrailing;
  /// Widget nhỏ hiện NGAY SÁT sau [title] (cùng hàng, đứng liền — khác với
  /// [titleTrailing] bị đẩy ra tận rìa phải row) — VD chip quan hệ "Chị gái"
  /// ngay sau tên ở danh sách Người thân màn Home.
  final Widget? titleSuffix;
  /// Widget nhỏ hiện ngay bên phải [meta] (cùng hàng thứ 2, dưới
  /// [title]/[titleTrailing]) — VD nhãn số ngày còn lại ở màn Sự kiện, để
  /// nó thẳng hàng với ngày/giờ thay vì trôi nổi ngay dưới [titleTrailing].
  final Widget? metaTrailing;
  /// Căn GIỮA dọc thay vì mặc định căn trên (start) — dùng khi số dòng nội
  /// dung luôn cố định (không đổi giữa các thẻ) và thiết kế yêu cầu leading/
  /// trailing thẳng tâm với khối text, VD danh sách Người thân màn Home.
  final bool centerContent;
  final VoidCallback? onTap;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;

  const CardRow({
    super.key,
    required this.leading,
    required this.title,
    this.meta,
    this.trailing,
    this.titleTrailing,
    this.titleSuffix,
    this.metaTrailing,
    this.centerContent = false,
    this.onTap,
    this.borderColor,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor ?? (isDark ? AppColors.lineDark : AppColors.lineLight)),
          boxShadow: [
            BoxShadow(
              color: isDark ? AppColors.shadowDark : AppColors.shadowLight,
              blurRadius: isDark ? 12 : 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          // Căn trên theo mặc định — leading/title luôn bắt đầu cùng 1 vị
          // trí bất kể chiều cao cột bên phải (VD: meta 1 dòng vs
          // titleTrailing 2 dòng khi có thêm nhãn "Còn N ngày") thay đổi
          // theo từng thẻ, tránh các thẻ bị lệch hàng với nhau. Chỉ căn
          // giữa khi [centerContent] bật (số dòng cố định, thiết kế yêu
          // cầu thẳng tâm).
          crossAxisAlignment: centerContent ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // titleTrailing (VD chip chủ sở hữu ở màn Sự kiện) cần
                      // luôn sát mép phải, kể cả khi title ngắn — dùng
                      // Expanded (tight fit) để nó CHIẾM HẾT khoảng trống
                      // còn lại, khớp cách metaTrailing dùng Expanded(meta)
                      // ở hàng dưới, để 2 hàng thẳng mép với nhau. Khi chỉ
                      // có titleSuffix (chip sát tên, không cần đẩy ra mép)
                      // thì vẫn dùng Flexible để title co theo nội dung.
                      titleTrailing != null
                          ? Expanded(
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          : Flexible(
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                      if (titleSuffix != null) ...[
                        const SizedBox(width: 6),
                        titleSuffix!,
                      ],
                      if (titleTrailing != null) ...[
                        const SizedBox(width: 6),
                        titleTrailing!,
                      ],
                    ],
                  ),
                  if (meta != null) ...[
                    const SizedBox(height: 3),
                    metaTrailing == null
                        ? meta!
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(child: meta!),
                              const SizedBox(width: 6),
                              metaTrailing!,
                            ],
                          ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

/// The colored square icon badge used as [CardRow.leading] throughout the
/// app (events, notifications, holidays).
class SquareIconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final double size;

  const SquareIconBadge({
    super.key,
    required this.icon,
    required this.color,
    required this.background,
    this.size = 42,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(size * 0.33)),
      child: Icon(icon, color: color, size: size * 0.45),
    );
  }
}
