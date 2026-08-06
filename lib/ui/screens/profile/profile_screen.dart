import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:event_app/core/constants/app_colors.dart';
import 'package:event_app/core/constants/app_text_styles.dart';
import 'package:event_app/providers/auth_provider.dart';
import 'package:event_app/providers/notification_provider.dart';
import 'package:event_app/core/theme/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    
    final days = user?.createdAt != null 
        ? DateTime.now().difference(user!.createdAt!).inDays 
        : 0;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              height: 220,
              decoration: const BoxDecoration(
                gradient: AppColors.headerGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_none,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.fullName ?? 'Người dùng',
                      style: AppTextStyles.heading2.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? 'email@example.com',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Stats Row
            Transform.translate(
              offset: const Offset(0, -24),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.cardLight,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          '${user?.totalEvents ?? 0}', 
                          'Sự kiện', 
                          isDark,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: isDark ? Colors.white24 : Colors.black12,
                      ),
                      Expanded(
                        child: _buildStatItem(
                          '${user?.totalRelatives ?? 0}', 
                          'Người thân', 
                          isDark,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: isDark ? Colors.white24 : Colors.black12,
                      ),
                      Expanded(
                        child: _buildStatItem(
                          '$days', 
                          'Ngày', 
                          isDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tài khoản',
                    style: AppTextStyles.subtitle.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.cardLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.white12 : Colors.black12,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildSettingsRow(
                          icon: Icons.person_outline,
                          iconBg: AppColors.iconBgPink,
                          iconColor: AppColors.primaryLight,
                          title: 'Thông tin cá nhân',
                          isDark: isDark,
                          onTap: () => context.push('/profile/settings'),
                        ),
                        Divider(height: 1, color: isDark ? Colors.white12 : Colors.black12),
                        Consumer<NotificationProvider>(
                          builder: (context, notificationProvider, child) {
                            return _buildSettingsRow(
                              icon: Icons.notifications_none,
                              iconBg: AppColors.iconBgPink,
                              iconColor: AppColors.primaryLight,
                              title: 'Thông báo',
                              isDark: isDark,
                              badgeCount: notificationProvider.unreadCount,
                              onTap: () => context.push('/profile/notifications'),
                            );
                          }
                        ),
                        Divider(height: 1, color: isDark ? Colors.white12 : Colors.black12),
                        _buildSettingsRow(
                          icon: Icons.language,
                          iconBg: AppColors.iconBgPink,
                          iconColor: AppColors.primaryLight,
                          title: 'Ngôn ngữ',
                          trailingText: 'Tiếng Việt',
                          isDark: isDark,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Text(
                    'Cài đặt',
                    style: AppTextStyles.subtitle.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.cardLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.white12 : Colors.black12,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildSettingsRow(
                          icon: Icons.dark_mode_outlined,
                          iconBg: const Color(0xFFE3F2FD),
                          iconColor: Colors.blue,
                          title: 'Chế độ tối',
                          isDark: isDark,
                          trailingWidget: Switch(
                            value: isDark,
                            onChanged: (_) => context.read<ThemeProvider>().toggleTheme(),
                            activeColor: AppColors.primaryLight,
                          ),
                          onTap: () => context.read<ThemeProvider>().toggleTheme(),
                        ),
                        Divider(height: 1, color: isDark ? Colors.white12 : Colors.black12),
                        _buildSettingsRow(
                          icon: Icons.security,
                          iconBg: AppColors.iconBgPink,
                          iconColor: AppColors.primaryLight,
                          title: 'Bảo mật',
                          isDark: isDark,
                          onTap: () => context.push('/profile/login-history'),
                        ),
                        Divider(height: 1, color: isDark ? Colors.white12 : Colors.black12),
                        _buildSettingsRow(
                          icon: Icons.help_outline,
                          iconBg: AppColors.iconBgPink,
                          iconColor: AppColors.primaryLight,
                          title: 'Trợ giúp',
                          isDark: isDark,
                          onTap: () {
                            showAboutDialog(
                              context: context,
                              applicationName: 'Event App',
                              applicationVersion: '1.0.0',
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await context.read<AuthProvider>().logout();
                        if (context.mounted) {
                          context.go('/splash');
                        }
                      },
                      icon: const Icon(Icons.logout, color: AppColors.primaryLight),
                      label: Text(
                        'Đăng xuất',
                        style: AppTextStyles.button.copyWith(color: AppColors.primaryLight),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(
                          color: AppColors.primaryLight,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.heading2.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required bool isDark,
    String? trailingText,
    Widget? trailingWidget,
    int badgeCount = 0,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.body.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (badgeCount > 0)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badgeCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (trailingText != null) ...[
              const SizedBox(width: 8),
              Text(
                trailingText,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
            if (trailingWidget != null) ...[
              const SizedBox(width: 8),
              trailingWidget,
            ] else ...[
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
