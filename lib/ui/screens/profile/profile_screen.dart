import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:event_app/core/constants/app_colors.dart';
import 'package:event_app/core/constants/app_text_styles.dart';
import 'package:event_app/providers/auth_provider.dart';
import 'package:event_app/providers/notification_provider.dart';
import 'package:event_app/core/theme/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().loadProfile();
      context.read<NotificationProvider>().loadUnreadCount();
    });
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Đăng xuất', style: AppTextStyles.heading3),
        content: Text('Bạn có chắc muốn đăng xuất khỏi tài khoản?', style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Huỷ',
              style: AppTextStyles.button.copyWith(color: AppColors.textSecondaryLight),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: Text(
              'Đăng xuất',
              style: AppTextStyles.button.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final unreadCount = context.watch<NotificationProvider>().unreadCount;
    final user = authProvider.user;
    final isDark = themeProvider.isDarkMode;

    int daysActive = 0;
    if (user?.createdAt != null) {
      daysActive = DateTime.now().difference(user!.createdAt!).inDays;
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<AuthProvider>().loadProfile();
          if (context.mounted) {
            await context.read<NotificationProvider>().loadUnreadCount();
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Segment
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 60),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 80, bottom: 40),
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.elliptical(MediaQuery.of(context).size.width, 50),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                              backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
                              child: user?.avatarUrl == null
                                  ? Text(
                                      (user?.fullName.isNotEmpty == true) ? user!.fullName[0].toUpperCase() : '?',
                                      style: AppTextStyles.heading1.copyWith(color: Colors.white),
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user?.fullName ?? 'Đang tải...',
                            style: AppTextStyles.heading2.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? '',
                            style: AppTextStyles.body.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Overlapping Stats
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatCircle('Sự kiện', '${user?.totalEvents ?? 0}', AppColors.tealGradient, isDark),
                        _buildStatCircle('Người thân', '${user?.totalRelatives ?? 0}', AppColors.tealGradient, isDark),
                        _buildStatCircle('Ngày HL', '$daysActive', AppColors.tealGradient, isDark),
                      ],
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1),

              const SizedBox(height: 32),
              
              // Google Calendar Card
              _buildGoogleCalendarCard(context, isDark).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

              const SizedBox(height: 24),
              
              // Tài Khoản Section
              _buildSectionTitle('TÀI KHOẢN', isDark).animate().fadeIn(delay: 300.ms),
              _buildAccountMenu(context, isDark, unreadCount).animate().fadeIn(delay: 350.ms).slideY(begin: 0.1),

              const SizedBox(height: 24),

              // Cài Đặt Section
              _buildSectionTitle('CÀI ĐẶT', isDark).animate().fadeIn(delay: 400.ms),
              _buildSettingsMenu(context, isDark).animate().fadeIn(delay: 450.ms).slideY(begin: 0.1),

              const SizedBox(height: 32),

              // Logout Button
              Center(
                child: TextButton(
                  onPressed: () => _confirmLogout(context),
                  child: Text(
                    'Đăng xuất',
                    style: AppTextStyles.button.copyWith(color: AppColors.error),
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCircle(String label, String value, LinearGradient gradient, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: gradient,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            value,
            style: AppTextStyles.heading3.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleCalendarCard(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Tính năng đang phát triển', style: AppTextStyles.heading3),
            content: Text('Tính năng kết nối Google Calendar sẽ sớm ra mắt.', style: AppTextStyles.body),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('Đóng', style: AppTextStyles.button.copyWith(color: AppColors.primaryLight)),
              ),
            ],
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.transparent : Colors.grey.withValues(alpha: 0.15)),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.calendar_month_rounded, color: Colors.blue, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Google Calendar',
                    style: AppTextStyles.subtitle.copyWith(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Chưa kết nối',
                          style: AppTextStyles.caption.copyWith(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        title,
        style: AppTextStyles.label.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
      ),
    );
  }

  Widget _buildMenuCard({required List<Widget> children, required bool isDark}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.transparent : Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    required bool isDark,
  }) {
    return ListTile(
      leading: Icon(icon, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
      title: Text(
        title,
        style: AppTextStyles.body.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing ??
          Icon(Icons.chevron_right, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
      onTap: onTap,
    );
  }

  Widget _buildAccountMenu(BuildContext context, bool isDark, int unreadCount) {
    return _buildMenuCard(
      isDark: isDark,
      children: [
        _buildMenuItem(
          icon: Icons.person_outline,
          title: 'Thông tin cá nhân',
          isDark: isDark,
          onTap: () => context.push('/profile/settings'),
        ),
        const Divider(height: 1, indent: 56),
        _buildMenuItem(
          icon: Icons.notifications_none,
          title: 'Thông báo',
          isDark: isDark,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (unreadCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                  child: Text('$unreadCount', style: AppTextStyles.caption.copyWith(color: Colors.white)),
                ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            ],
          ),
          onTap: () => context.push('/profile/notifications'),
        ),
        const Divider(height: 1, indent: 56),
        _buildMenuItem(
          icon: Icons.language,
          title: 'Ngôn ngữ',
          isDark: isDark,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tiếng Việt',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            ],
          ),
          onTap: () => context.push('/profile/settings'),
        ),
      ],
    );
  }

  Widget _buildSettingsMenu(BuildContext context, bool isDark) {
    return _buildMenuCard(
      isDark: isDark,
      children: [
        _buildMenuItem(
          icon: Icons.dark_mode_outlined,
          title: 'Chế độ tối',
          isDark: isDark,
          trailing: Switch(
            value: isDark,
            onChanged: (_) => context.read<ThemeProvider>().toggleTheme(),
            activeColor: AppColors.primaryLight,
          ),
        ),
        const Divider(height: 1, indent: 56),
        _buildMenuItem(
          icon: Icons.lock_outline,
          title: 'Bảo mật & Quyền riêng tư',
          isDark: isDark,
          onTap: () => context.push('/profile/login-history'),
        ),
        const Divider(height: 1, indent: 56),
        _buildMenuItem(
          icon: Icons.help_outline,
          title: 'Trợ giúp & Hỗ trợ',
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
    );
  }
}
