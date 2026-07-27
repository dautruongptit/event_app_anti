import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:event_app/core/constants/app_colors.dart';
import 'package:event_app/core/constants/app_text_styles.dart';
import 'package:event_app/providers/auth_provider.dart';

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
    });
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => authProvider.loadProfile(),
        child: CustomScrollView(
          slivers: [
            // Gradient Header
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    // Avatar
                    GestureDetector(
                      onTap: () => context.push('/profile/settings'),
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            child: user?.avatarUrl != null
                                ? ClipOval(
                                    child: Image.network(
                                      user!.avatarUrl!,
                                      width: 96,
                                      height: 96,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => _buildInitials(user.fullName),
                                    ),
                                  )
                                : _buildInitials(user?.fullName ?? '?'),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.accentLight,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.edit_rounded, size: 14, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                    const SizedBox(height: 16),
                    Text(
                      user?.fullName ?? 'Đang tải...',
                      style: AppTextStyles.heading2.copyWith(color: Colors.white),
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                    ).animate().fadeIn(delay: 300.ms),
                  ],
                ),
              ),
            ),

            // Stats
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    _buildStatCard(
                      icon: Icons.calendar_today_rounded,
                      value: '${user?.totalEvents ?? 0}',
                      label: 'Sự kiện',
                      color: AppColors.primaryLight,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      icon: Icons.people_rounded,
                      value: '${user?.totalRelatives ?? 0}',
                      label: 'Người thân',
                      color: AppColors.secondaryLight,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      icon: Icons.timer_rounded,
                      value: user?.daysUntilNextEvent != null
                          ? '${user!.daysUntilNextEvent}'
                          : '-',
                      label: 'Ngày tới SK',
                      color: AppColors.accentLight,
                      isDark: isDark,
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
              ),
            ),

            // Menu
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildMenuItem(
                    icon: Icons.settings_rounded,
                    title: 'Cài đặt',
                    subtitle: 'Giao diện, ngôn ngữ, ảnh đại diện',
                    onTap: () => context.push('/profile/settings'),
                    isDark: isDark,
                  ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.05),
                  const SizedBox(height: 12),
                  _buildMenuItem(
                    icon: Icons.logout_rounded,
                    title: 'Đăng xuất',
                    subtitle: 'Thoát khỏi tài khoản',
                    onTap: _confirmLogout,
                    isDark: isDark,
                    isDestructive: true,
                  ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.05),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitials(String name) {
    return Text(
      name.isNotEmpty ? name[0].toUpperCase() : '?',
      style: AppTextStyles.heading1.copyWith(color: Colors.white),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: color.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: AppTextStyles.heading2.copyWith(color: color)),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppColors.error : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDestructive
              ? AppColors.error.withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.15),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (isDestructive ? AppColors.error : AppColors.primaryLight).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: isDestructive ? AppColors.error : AppColors.primaryLight),
        ),
        title: Text(title, style: AppTextStyles.subtitle.copyWith(color: color)),
        subtitle: Text(subtitle, style: AppTextStyles.bodySmall.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        )),
        trailing: Icon(Icons.chevron_right_rounded, color: color),
        onTap: onTap,
      ),
    );
  }
}
