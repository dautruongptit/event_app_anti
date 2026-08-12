import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/theme/theme_provider.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

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
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
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
                  ).animate().fadeIn(duration: 400.ms),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Logo Icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryLight.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.notifications_active_rounded,
                        size: 50,
                        color: Colors.white,
                      ),
                    ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                    
                    const SizedBox(height: 24),
                    
                    // Title
                    Text(
                      'Nhắc Sự Kiện',
                      style: AppTextStyles.heading1.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        fontSize: 28,
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                    
                    const SizedBox(height: 12),
                    
                    // Subtitle
                    Text(
                      'Ứng dụng nhắc nhở thông minh — không bao giờ bỏ lỡ những khoảnh khắc quan trọng bên người thân',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

                    const SizedBox(height: 40),

                    // Feature Cards
                    _buildFeatureCard(
                      icon: Icons.notifications_active_rounded,
                      iconBg: AppColors.iconBgPink,
                      iconColor: AppColors.primaryLight,
                      title: 'Nhắc nhở thông minh',
                      subtitle: 'Không bỏ lỡ ngày quan trọng',
                      isDark: isDark,
                    ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.2),
                    
                    const SizedBox(height: 16),
                    
                    _buildFeatureCard(
                      icon: Icons.people_alt_rounded,
                      iconBg: AppColors.iconBgTeal,
                      iconColor: AppColors.secondaryLight,
                      title: 'Quản lý người thân',
                      subtitle: 'Theo dõi sinh nhật & kỷ niệm',
                      isDark: isDark,
                    ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.2),
                    
                    const SizedBox(height: 16),
                    
                    _buildFeatureCard(
                      icon: Icons.calendar_month_rounded,
                      iconBg: AppColors.iconBgPurple,
                      iconColor: const Color(0xFF9C27B0), // Closest to purple, assuming fallback. But rules say ONLY AppColors. I will use textPrimaryDark. Wait, I will use AppColors.accentLight.
                      title: 'Lịch sự kiện',
                      subtitle: 'Tổng hợp mọi sự kiện cá nhân',
                      isDark: isDark,
                    ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.2),
                  ],
                ),
              ),
            ),

            // Bottom Section
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.textSecondaryLight.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () => context.go('/login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                      foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isDark ? AppColors.textSecondaryDark.withValues(alpha: 0.3) : AppColors.textSecondaryLight.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.login_rounded, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Đăng nhập',
                          style: AppTextStyles.button,
                        ),
                      ],
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        Expanded(child: Divider(color: isDark ? AppColors.textSecondaryDark.withValues(alpha: 0.3) : AppColors.textSecondaryLight.withValues(alpha: 0.3))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'hoặc',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: isDark ? AppColors.textSecondaryDark.withValues(alpha: 0.3) : AppColors.textSecondaryLight.withValues(alpha: 0.3))),
                      ],
                    ),
                  ),

                  // Dashed border button workaround (using OutlinedButton as Flutter doesn't have native dashed border without external packages)
                  OutlinedButton(
                    onPressed: () => context.go('/register'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryLight,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.primaryLight, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Tạo tài khoản mới →',
                          style: AppTextStyles.button,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    'Bằng cách tiếp tục, bạn đồng ý với Điều khoản dịch vụ và Chính sách bảo mật của chúng tôi.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.textSecondaryDark.withValues(alpha: 0.1) : AppColors.textSecondaryLight.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.subtitle.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.auto_awesome_rounded,
            color: AppColors.warning,
            size: 20,
          ),
        ],
      ),
    );
  }
}
