import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/theme/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../widgets/google_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isGoogleLoading = false;

  Future<void> _loginWithGoogle() async {
    setState(() => _isGoogleLoading = true);
    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.loginWithGoogle();

      if (!mounted) return;

      if (success) {
        context.go('/home');
      } else if (authProvider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Đăng nhập bằng Google thất bại'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Theme Toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? AppColors.textSecondaryDark.withValues(alpha: 0.3)
                            : AppColors.textSecondaryLight.withValues(alpha: 0.2),
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.primaryLight,
                      ),
                      onPressed: () => context.read<ThemeProvider>().toggleTheme(),
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // NINO Logo Container
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF87171), Color(0xFF4DB6AC)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryLight.withValues(alpha: 0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.person_rounded, size: 38, color: Colors.white),
                              SizedBox(width: 2),
                              Icon(Icons.person_rounded, size: 38, color: Colors.white),
                            ],
                          ),
                          Positioned(
                            top: 48,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.favorite_rounded,
                                size: 14,
                                color: Color(0xFFF87171),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),

                    const SizedBox(height: 16),

                    // N I N O Title
                    RichText(
                      text: TextSpan(
                        style: AppTextStyles.heading1.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4.0,
                        ),
                        children: const [
                          TextSpan(text: 'N', style: TextStyle(color: Color(0xFFF87171))),
                          TextSpan(text: ' I ', style: TextStyle(color: Color(0xFFF87171))),
                          TextSpan(text: 'N', style: TextStyle(color: Color(0xFF26A69A))),
                          TextSpan(text: 'O', style: TextStyle(color: Color(0xFF26A69A))),
                        ],
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                    const SizedBox(height: 4),

                    // Sub-tagline
                    Text(
                      'NEVER IGNORE NEAR ONES',
                      style: AppTextStyles.caption.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        fontSize: 10,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ).animate().fadeIn(delay: 250.ms),

                    const SizedBox(height: 16),

                    // Description text
                    Text(
                      'Đồng hành ngày & đêm — không bao giờ\nđể lỡ những khoảnh khắc bên\nngười thân',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : const Color(0xFF757575),
                        height: 1.4,
                      ),
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

                    const SizedBox(height: 32),

                    // 3 Feature Cards
                    _buildFeatureCard(
                      icon: Icons.notifications_none_rounded,
                      iconBg: const Color(0xFFFFEBEE),
                      iconColor: const Color(0xFFF87171),
                      title: 'Nhắc nhở thông minh',
                      subtitle: 'Không bỏ lỡ ngày quan trọng',
                      isDark: isDark,
                    ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1),

                    const SizedBox(height: 12),

                    _buildFeatureCard(
                      icon: Icons.people_outline_rounded,
                      iconBg: const Color(0xFFE0F2F1),
                      iconColor: const Color(0xFF26A69A),
                      title: 'Quản lý người thân',
                      subtitle: 'Sinh nhật & kỷ niệm mọi người',
                      isDark: isDark,
                    ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1),

                    const SizedBox(height: 12),

                    _buildFeatureCard(
                      icon: Icons.calendar_today_rounded,
                      iconBg: const Color(0xFFF3E5F5),
                      iconColor: const Color(0xFFAB47BC),
                      title: 'Lịch sự kiện',
                      subtitle: 'Tổng hợp mọi sự kiện cá nhân',
                      isDark: isDark,
                    ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.1),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Button: Tiếp tục với Google
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: _isGoogleLoading ? null : _loginWithGoogle,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isDark ? AppColors.cardDark : Colors.white,
                        side: BorderSide(
                          color: isDark
                              ? AppColors.textSecondaryDark.withValues(alpha: 0.2)
                              : const Color(0xFFE0E0E0),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _isGoogleLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.primaryLight,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildGoogleIcon(),
                                const SizedBox(width: 12),
                                Text(
                                  'Tiếp tục với Google',
                                  style: AppTextStyles.subtitle.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : const Color(0xFF212121),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  // Divider: hoặc
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: isDark
                                ? AppColors.textSecondaryDark.withValues(alpha: 0.2)
                                : const Color(0xFFEEEEEE),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'hoặc',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: isDark
                                ? AppColors.textSecondaryDark.withValues(alpha: 0.2)
                                : const Color(0xFFEEEEEE),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Button: Tạo tài khoản mới → (Dashed Border style)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: CustomPaint(
                      painter: DashedRectPainter(
                        color: const Color(0xFFF87171),
                        strokeWidth: 1.5,
                        gap: 4.0,
                        radius: 16,
                      ),
                      child: TextButton(
                        onPressed: () => context.go('/register'),
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Tạo tài khoản mới',
                              style: AppTextStyles.subtitle.copyWith(
                                color: const Color(0xFFF87171),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                              color: Color(0xFFF87171),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Footer terms text
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: AppTextStyles.caption.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        height: 1.4,
                      ),
                      children: const [
                        TextSpan(text: 'Bằng cách tiếp tục, bạn đồng ý với '),
                        TextSpan(
                          text: 'Điều khoản dịch vụ',
                          style: TextStyle(color: Color(0xFFF87171)),
                        ),
                        TextSpan(text: ' và '),
                        TextSpan(
                          text: 'Chính sách bảo mật',
                          style: TextStyle(color: Color(0xFFF87171)),
                        ),
                        TextSpan(text: '.'),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.textSecondaryDark.withValues(alpha: 0.1)
              : const Color(0xFFF0F0F0),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.subtitle.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isDark ? AppColors.textPrimaryDark : const Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : const Color(0xFF888888),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.auto_awesome_outlined,
            color: isDark ? Colors.white24 : const Color(0xFFD0D0D0),
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleIcon() {
    return const GoogleLogo(size: 22);
  }
}

// Custom Dashed Border Painter
class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double radius;

  DashedRectPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.gap = 4.0,
    this.radius = 16.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final Path path = Path()..addRRect(rrect);
    final Path dashPath = Path();

    for (final PathMetric pathMetric in path.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < pathMetric.length) {
        final double length = draw ? 6.0 : gap;
        if (draw) {
          dashPath.addPath(
            pathMetric.extractPath(distance, distance + length),
            Offset.zero,
          );
        }
        distance += length;
        draw = !draw;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant DashedRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.gap != gap ||
        oldDelegate.radius != radius;
  }
}
