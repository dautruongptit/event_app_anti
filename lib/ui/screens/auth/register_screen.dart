import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/theme_provider.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.textSecondaryDark.withValues(alpha: 0.3) : AppColors.textSecondaryLight.withValues(alpha: 0.3),
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/');
                        }
                      },
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.textSecondaryDark.withValues(alpha: 0.3) : AppColors.textSecondaryLight.withValues(alpha: 0.3),
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                      onPressed: () => context.read<ThemeProvider>().toggleTheme(),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // Small Logo & App Name
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: AppColors.accentGradient,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.notifications_active_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Tham gia ngay',
                          style: AppTextStyles.body.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Nhắc Sự Kiện',
                          style: AppTextStyles.subtitle.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2),

                    const SizedBox(height: 24),

                    // Headings
                    Text(
                      'Bắt đầu hành trình',
                      style: AppTextStyles.heading1.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        fontSize: 32,
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                    Text(
                      'lưu giữ kỷ niệm',
                      style: AppTextStyles.heading1.copyWith(
                        color: AppColors.primaryLight,
                        fontSize: 32,
                      ),
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

                    const SizedBox(height: 16),

                    Text(
                      'Tạo tài khoản miễn phí — chỉ cần tài khoản Google của bạn',
                      style: AppTextStyles.body.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        fontSize: 16,
                      ),
                    ).animate().fadeIn(delay: 400.ms),

                    const SizedBox(height: 32),

                    // Benefits
                    _buildBenefitRow(
                      icon: Icons.favorite_rounded,
                      iconBg: AppColors.iconBgPink,
                      iconColor: AppColors.primaryLight,
                      text: 'Nhắc nhở sinh nhật & kỷ niệm tự động',
                      isDark: isDark,
                    ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.2),
                    
                    const SizedBox(height: 16),
                    
                    _buildBenefitRow(
                      icon: Icons.notifications_active_rounded,
                      iconBg: AppColors.iconBgTeal,
                      iconColor: AppColors.secondaryLight,
                      text: 'Thông báo trước 1-7 ngày tuỳ chỉnh',
                      isDark: isDark,
                    ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.2),
                    
                    const SizedBox(height: 16),
                    
                    _buildBenefitRow(
                      icon: Icons.star_rounded,
                      iconBg: AppColors.iconBgYellow,
                      iconColor: AppColors.warning,
                      text: 'Lưu trữ kỷ niệm và ghi chú đặc biệt',
                      isDark: isDark,
                    ).animate().fadeIn(delay: 700.ms).slideX(begin: 0.2),
                    
                    const SizedBox(height: 16),
                    
                    _buildBenefitRow(
                      icon: Icons.card_giftcard_rounded,
                      iconBg: AppColors.iconBgPurple,
                      iconColor: AppColors.accentLight,
                      text: 'Gợi ý quà tặng theo từng dịp',
                      isDark: isDark,
                    ).animate().fadeIn(delay: 800.ms).slideX(begin: 0.2),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Bottom Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Đăng ký bằng tài khoản Google của bạn — nhanh chóng & bảo mật',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppColors.accentGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryLight.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tính năng đang phát triển')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.g_mobiledata_rounded, color: Colors.white, size: 32),
                          const SizedBox(width: 8),
                          Text(
                            'Đăng ký với Google',
                            style: AppTextStyles.button.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: RichText(
                      text: TextSpan(
                        style: AppTextStyles.body.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                        children: [
                          const TextSpan(text: 'Đã có tài khoản? '),
                          TextSpan(
                            text: 'Đăng nhập ngay',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.primaryLight,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.primaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().slideY(begin: 1, duration: 600.ms, curve: Curves.easeOutCubic),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String text,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Icon(
          Icons.check_circle_rounded,
          color: AppColors.primaryLight,
          size: 24,
        ),
      ],
    );
  }
}
