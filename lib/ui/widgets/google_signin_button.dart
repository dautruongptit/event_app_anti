import 'package:flutter/material.dart';
import '../../core/constants/app_text_styles.dart';

/// Nút "Đăng nhập bằng Google" dùng chung cho Login & Register screen.
/// Icon G dùng Icons.g_mobiledata_rounded làm placeholder (chưa có asset G
/// đa sắc chính thức trong dự án) — có thể thay bằng ảnh SVG sau này.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
  });

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(color: Colors.grey.withValues(alpha: 0.4)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.g_mobiledata_rounded,
                    size: 28,
                    color: Color(0xFF4285F4),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Đăng nhập với Google',
                    style: AppTextStyles.button.copyWith(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Divider "hoặc" giữa form email/password và nút Google.
class OrDivider extends StatelessWidget {
  const OrDivider({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: color.withValues(alpha: 0.4))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('hoặc', style: TextStyle(color: color)),
        ),
        Expanded(child: Divider(color: color.withValues(alpha: 0.4))),
      ],
    );
  }
}
