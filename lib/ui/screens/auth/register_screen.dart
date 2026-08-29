import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/nino/nino_logo.dart';
import '../../widgets/nino/nino_toast.dart';
import '../../widgets/google_logo.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _selectedMeaningIndex = 0;
  bool _isGoogleLoading = false;

  static const _meanings = [
    (sub: 'Never Ignore Near Ones'),
    (sub: 'Notes In Near Order'),
    (sub: 'Night & Noon — mọi lúc bên bạn'),
  ];

  static const _perks = [
    (icon: '🎂', label: 'Nhắc sinh nhật & kỷ niệm tự động'),
    (icon: '🔔', label: 'Thông báo trước 1–7 ngày tuỳ chỉnh'),
    (icon: '🌕', label: 'Lịch âm: ngày giỗ, rằm, mùng một'),
    (icon: '🎁', label: 'Gợi ý quà tặng theo từng dịp'),
  ];

  Future<void> _registerWithGoogle() async {
    setState(() => _isGoogleLoading = true);
    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.loginWithGoogle();
      if (!mounted) return;
      if (success) {
        context.go('/home');
      } else if (authProvider.error != null) {
        showNinoToast(context, authProvider.error ?? 'Đăng ký bằng Google thất bại');
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => context.canPop() ? context.pop() : context.go('/login'),
                    icon: Icon(Icons.chevron_left_rounded, color: txt),
                    style: IconButton.styleFrom(backgroundColor: card, shape: CircleBorder(side: BorderSide(color: line))),
                  ),
                  IconButton(
                    onPressed: () => context.read<ThemeProvider>().toggleTheme(),
                    icon: Icon(isDark ? Icons.wb_sunny_rounded : Icons.dark_mode_rounded, color: txt),
                    style: IconButton.styleFrom(backgroundColor: card, shape: CircleBorder(side: BorderSide(color: line))),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const NinoLogo(size: 52),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('TẠO TÀI KHOẢN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.6, color: mut)),
                              const SizedBox(height: 3),
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.4, color: txt),
                                  children: [
                                    const TextSpan(text: 'Bắt đầu với '),
                                    TextSpan(text: 'NINO', style: TextStyle(color: pri)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: line),
                        boxShadow: [BoxShadow(color: isDark ? AppColors.shadowDark : AppColors.shadowLight, blurRadius: 10, offset: const Offset(0, 2))],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15, 13, 15, 11),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: mut),
                                  children: [const TextSpan(text: 'Ý nghĩa của '), TextSpan(text: 'NINO', style: TextStyle(color: pri))],
                                ),
                              ),
                            ),
                          ),
                          ...List.generate(_meanings.length, (i) {
                            final isSelected = _selectedMeaningIndex == i;
                            return InkWell(
                              onTap: () => setState(() => _selectedMeaningIndex = i),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                                decoration: BoxDecoration(border: Border(top: BorderSide(color: line))),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 19,
                                      height: 19,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: isSelected ? pri : line, width: isSelected ? 2 : 2),
                                        color: isSelected ? priSoft : Colors.transparent,
                                      ),
                                      child: isSelected ? Center(child: Container(width: 9, height: 9, decoration: BoxDecoration(color: pri, shape: BoxShape.circle))) : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('N·I·N·O', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: isSelected ? pri : txt)),
                                          const SizedBox(height: 2),
                                          Text(_meanings[i].sub, style: TextStyle(fontSize: 12, color: mut)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    ..._perks.map((p) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(color: priSoft, borderRadius: BorderRadius.circular(11)),
                                alignment: Alignment.center,
                                child: Text(p.icon, style: const TextStyle(fontSize: 15)),
                              ),
                              const SizedBox(width: 11),
                              Expanded(child: Text(p.label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: txt))),
                              Icon(Icons.check_rounded, size: 17, color: pri),
                            ],
                          ),
                        )),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: card,
                  border: Border.all(color: line),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: isDark ? AppColors.shadowDark : AppColors.shadowLight, blurRadius: 10, offset: const Offset(0, 2))],
                ),
                child: Column(
                  children: [
                    Text(
                      'Đăng ký miễn phí bằng tài khoản Google — nhanh & bảo mật',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: mut, height: 1.55),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(gradient: AppColors.signupGradient, borderRadius: BorderRadius.circular(15)),
                      child: ElevatedButton(
                        onPressed: _isGoogleLoading ? null : _registerWithGoogle,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                        child: _isGoogleLoading
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4))
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                    child: const Padding(padding: EdgeInsets.all(2), child: GoogleLogo(size: 16)),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text('Đăng ký với Google', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 12, color: mut),
                          children: [const TextSpan(text: 'Đã có tài khoản? '), TextSpan(text: 'Đăng nhập ngay', style: TextStyle(fontWeight: FontWeight.w700, color: txt))],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
              child: Text(
                'Bằng cách đăng ký, bạn đồng ý với Điều khoản và Chính sách bảo mật.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: mut, height: 1.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
