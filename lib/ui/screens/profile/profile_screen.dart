import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../widgets/nino/initials_avatar.dart';
import '../../widgets/nino/nino_logo.dart';
import '../../widgets/nino/soft_toggle.dart';

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
      final authProvider = context.read<AuthProvider>();
      if (authProvider.user == null) authProvider.loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final unreadCount = context.watch<NotificationProvider>().unreadCount;
    final days = user?.createdAt != null ? DateTime.now().difference(user!.createdAt!).inDays : 0;

    final txt = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mut = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final fnt = isDark ? AppColors.textFaintDark : AppColors.textFaintLight;
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final line = isDark ? AppColors.lineDark : AppColors.lineLight;
    final pri = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final priSoft = isDark ? AppColors.primarySoftDark : AppColors.primarySoftLight;
    final mint = isDark ? AppColors.secondaryDark : AppColors.secondaryLight;
    final amber = isDark ? AppColors.amberDark : AppColors.amberLight;
    final danger = isDark ? AppColors.errorDark : AppColors.error;
    final dangerSoft = isDark ? AppColors.errorSoftDark : AppColors.errorSoftLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          child: Column(
            children: [
              InitialsAvatar(name: user?.fullName ?? 'Người dùng', color: pri, softColor: priSoft, radius: 40, avatarUrl: user?.avatarUrl),
              const SizedBox(height: 12),
              Text(user?.fullName ?? 'Người dùng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.3, color: txt)),
              const SizedBox(height: 4),
              Text(user?.email ?? 'email@example.com', style: TextStyle(fontSize: 12, color: mut)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(18), border: Border.all(color: line)),
                child: Row(
                  children: [
                    Expanded(child: _stat('${user?.totalRelatives ?? 0}', 'Người thân', pri, mut)),
                    Container(width: 1, height: 30, color: line),
                    Expanded(child: _stat('${user?.totalEvents ?? 0}', 'Sự kiện', mint, mut)),
                    Container(width: 1, height: 30, color: line),
                    Expanded(child: _stat('$days', 'Ngày HL', amber, mut)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(18), border: Border.all(color: line)),
                child: Column(
                  children: [
                    _menuRow(
                      icon: Icons.dark_mode_outlined,
                      iconBg: priSoft,
                      iconColor: pri,
                      title: 'Chế độ tối',
                      txt: txt,
                      mut: mut,
                      trailing: SoftToggle(value: isDark, onChanged: (_) => context.read<ThemeProvider>().toggleTheme()),
                      onTap: () => context.read<ThemeProvider>().toggleTheme(),
                      border: Border(bottom: BorderSide(color: line)),
                    ),
                    _menuRow(
                      icon: Icons.person_outline_rounded,
                      iconBg: priSoft,
                      iconColor: pri,
                      title: 'Thông tin cá nhân',
                      txt: txt,
                      mut: mut,
                      onTap: () => context.push('/profile/settings'),
                      border: Border(bottom: BorderSide(color: line)),
                    ),
                    _menuRow(
                      icon: Icons.notifications_none_rounded,
                      iconBg: priSoft,
                      iconColor: pri,
                      title: 'Thông báo',
                      txt: txt,
                      mut: mut,
                      badgeCount: unreadCount,
                      onTap: () => context.push('/profile/notifications'),
                      border: Border(bottom: BorderSide(color: line)),
                    ),
                    _menuRow(
                      icon: Icons.security_rounded,
                      iconBg: priSoft,
                      iconColor: pri,
                      title: 'Bảo mật',
                      txt: txt,
                      mut: mut,
                      onTap: () => context.push('/profile/login-history'),
                      border: Border(bottom: BorderSide(color: line)),
                    ),
                    _menuRow(
                      icon: Icons.language_rounded,
                      iconBg: priSoft,
                      iconColor: pri,
                      title: 'Ngôn ngữ',
                      txt: txt,
                      mut: mut,
                      trailingText: 'Tiếng Việt',
                      onTap: () {},
                      border: Border(bottom: BorderSide(color: line)),
                    ),
                    _menuRow(
                      icon: Icons.help_outline_rounded,
                      iconBg: priSoft,
                      iconColor: pri,
                      title: 'Trợ giúp',
                      txt: txt,
                      mut: mut,
                      onTap: () => showAboutDialog(context: context, applicationName: 'NINO', applicationVersion: '1.0.0'),
                      border: const Border(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    await context.read<AuthProvider>().logout();
                    if (context.mounted) context.go('/splash');
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: dangerSoft,
                    side: BorderSide(color: dangerSoft),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('Đăng xuất', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: danger)),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const NinoLogo(size: 20, showBadge: false),
                  const SizedBox(width: 7),
                  Text('nino · 1.0.0', style: TextStyle(fontSize: 12, color: fnt)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(String value, String label, Color color, Color mut) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 12, color: mut)),
      ],
    );
  }

  Widget _menuRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required Color txt,
    required Color mut,
    required VoidCallback onTap,
    required Border border,
    String? trailingText,
    Widget? trailing,
    int badgeCount = 0,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(border: border),
        child: Row(
          children: [
            Container(width: 34, height: 34, decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(11)), alignment: Alignment.center, child: Icon(icon, color: iconColor, size: 17)),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: txt))),
            if (badgeCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                constraints: const BoxConstraints(minWidth: 18),
                alignment: Alignment.center,
                child: Text('$badgeCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
              ),
            if (trailingText != null) Padding(padding: const EdgeInsets.only(left: 8), child: Text(trailingText, style: TextStyle(fontSize: 12, color: mut))),
            if (trailing != null)
              Padding(padding: const EdgeInsets.only(left: 8), child: trailing)
            else
              Padding(padding: const EdgeInsets.only(left: 8), child: Icon(Icons.chevron_right_rounded, color: mut, size: 18)),
          ],
        ),
      ),
    );
  }
}
