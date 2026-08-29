import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/nino/nino_logo.dart';
import '../../widgets/nino/nino_toast.dart';
import '../../widgets/google_signin_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
        showNinoToast(context, authProvider.error ?? 'Đăng nhập Google thất bại');
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  static const _features = [
    (icon: '🔔', title: 'Nhắc nhở thông minh', sub: 'Không bỏ lỡ ngày quan trọng'),
    (icon: '👨‍👩‍👧', title: 'Quản lý người thân', sub: 'Sinh nhật & kỷ niệm mọi người'),
    (icon: '📅', title: 'Lịch sự kiện', sub: 'Dương lịch & âm lịch trong một chỗ'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final txt = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mut = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final line = isDark ? AppColors.lineDark : AppColors.lineLight;
    final pri = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final priSoft = isDark ? AppColors.primarySoftDark : AppColors.primarySoftLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => context.read<ThemeProvider>().toggleTheme(),
                  icon: Icon(isDark ? Icons.wb_sunny_rounded : Icons.dark_mode_rounded, color: txt),
                  style: IconButton.styleFrom(
                    backgroundColor: card,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999), side: BorderSide(color: line)),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Column(
                  children: [
                    const NinoLogo(size: 84),
                    const SizedBox(height: 16),
                    Text('nino', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, letterSpacing: -1.2, color: txt)),
                    const SizedBox(height: 2),
                    Text(
                      'NEVER IGNORE NEAR ONES',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 2.6, color: mut),
                    ),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        'Đồng hành ngày & đêm — không bao giờ để lỡ những khoảnh khắc bên người thân.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: mut, height: 1.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ..._features.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: card,
                        border: Border.all(color: line),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [BoxShadow(color: isDark ? AppColors.shadowDark : AppColors.shadowLight, blurRadius: 10, offset: const Offset(0, 2))],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(color: priSoft, borderRadius: BorderRadius.circular(13)),
                            alignment: Alignment.center,
                            child: Text(f.icon, style: const TextStyle(fontSize: 18)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(f.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: txt)),
                                const SizedBox(height: 2),
                                Text(f.sub, style: TextStyle(fontSize: 12, color: mut)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: 24),
              GoogleSignInButton(isLoading: _isGoogleLoading, onPressed: _loginWithGoogle),
              const SizedBox(height: 11),
              Row(
                children: [
                  Expanded(child: Divider(color: line)),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 11), child: Text('hoặc', style: TextStyle(fontSize: 12, color: mut))),
                  Expanded(child: Divider(color: line)),
                ],
              ),
              const SizedBox(height: 11),
              OutlinedButton(
                onPressed: () => context.go('/register'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: priSoft,
                  side: BorderSide(color: pri, width: 1.5, style: BorderStyle.solid),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Tạo tài khoản mới →', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: pri)),
              ),
              const SizedBox(height: 11),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'Bằng cách tiếp tục, bạn đồng ý với Điều khoản dịch vụ và Chính sách bảo mật.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: mut, height: 1.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
