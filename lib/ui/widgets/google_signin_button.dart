import 'package:flutter/material.dart';
import '../../core/constants/app_text_styles.dart';
import 'google_logo.dart';

/// Nút "Đăng nhập bằng Google" dùng chung cho Login & Register screen.
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
                  const GoogleLogo(size: 22),
                  const SizedBox(width: 10),
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
