import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Popup (khác với [showNinoToast] — toast tự biến mất sau ~1.9s, dễ bị bỏ
/// lỡ) báo lỗi khi gọi backend thất bại vì mất mạng/timeout/server không
/// phản hồi. Chặn thao tác cho tới khi người dùng bấm "Đóng" hoặc "Thử lại"
/// — dùng cho lỗi nghiêm trọng (không tải được dữ liệu), không dùng cho lỗi
/// validate/nghiệp vụ thông thường (vẫn nên dùng showNinoToast).
///
/// [onRetry] null thì chỉ hiện nút "Đóng".
Future<void> showConnectionErrorDialog(
  BuildContext context, {
  String message = 'Không có kết nối mạng hoặc máy chủ không phản hồi.',
  VoidCallback? onRetry,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final card = isDark ? AppColors.cardDark : AppColors.cardLight;
  final txt = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
  final mut = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
  final line2 = isDark ? AppColors.line2Dark : AppColors.line2Light;
  final pri = isDark ? AppColors.primaryDark : AppColors.primaryLight;
  final errorSoft = isDark ? AppColors.errorSoftDark : AppColors.errorSoftLight;
  final error = isDark ? AppColors.errorDark : AppColors.error;

  return showDialog<void>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(color: errorSoft, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Icon(Icons.cloud_off_rounded, color: error, size: 26),
            ),
            const SizedBox(height: 16),
            Text('Không thể kết nối máy chủ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: txt)),
            const SizedBox(height: 7),
            Text(message, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: mut, height: 1.55)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: line2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text('Đóng', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: txt)),
                  ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(width: 9),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        onRetry();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: pri,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Thử lại', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
