import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Sticky bottom bar with a single full-width CTA button — used on the
/// Add Event screen ("Lưu sự kiện").
class StickySaveBar extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  const StickySaveBar({super.key, required this.label, required this.onPressed, this.loading = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pri = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: isDark ? AppColors.navBarDark : AppColors.navBarLight,
        border: Border(top: BorderSide(color: isDark ? AppColors.lineDark : AppColors.lineLight)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: pri,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4),
                )
              : Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      ),
    );
  }
}

/// Confirm-delete bottom sheet — "Xoá {label} này?". Returns `true` if the
/// user tapped the destructive action, `false`/`null` (never — always
/// resolves to a bool) otherwise.
Future<bool> showDeleteConfirmSheet({
  required BuildContext context,
  required String title,
  required String message,
}) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final result = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
    builder: (ctx) {
      final txt = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
      final mut = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
      final line2 = isDark ? AppColors.line2Dark : AppColors.line2Light;
      final danger = isDark ? AppColors.errorDark : AppColors.error;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: txt)),
              const SizedBox(height: 7),
              Text(message, style: TextStyle(fontSize: 12, color: mut, height: 1.55)),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        side: BorderSide(color: line2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text('Giữ lại', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: txt)),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: danger,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Xoá', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
  return result ?? false;
}
