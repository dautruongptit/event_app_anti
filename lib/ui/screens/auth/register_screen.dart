import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/google_logo.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _selectedMeaningIndex = 0;
  bool _isGoogleLoading = false;

  final List<Map<String, String>> _ninoMeanings = [
    {
      'title': 'N · I · N · O',
      'subtitle': 'Never Ignore Near Ones',
    },
    {
      'title': 'N · I · N · O',
      'subtitle': 'Notes In Near Order',
    },
    {
      'title': 'N · I · N · O',
      'subtitle': 'Night & Noon — mọi lúc bên bạn',
    },
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Đăng ký bằng Google thất bại'),
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
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? AppColors.textSecondaryDark.withValues(alpha: 0.3)
                            : AppColors.textSecondaryLight.withValues(alpha: 0.2),
                      ),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.chevron_left_rounded,
                        size: 24,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/splash');
                        }
                      },
                    ),
                  ),

                  // Theme Toggle
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? AppColors.textSecondaryDark.withValues(alpha: 0.3)
                            : AppColors.textSecondaryLight.withValues(alpha: 0.2),
                      ),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.primaryLight,
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
                    const SizedBox(height: 8),

                    // Header Row with Logo & Title
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Small NINO Logo
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF87171), Color(0xFF4DB6AC)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryLight.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.person_rounded, size: 24, color: Colors.white),
                                  Icon(Icons.person_rounded, size: 24, color: Colors.white),
                                ],
                              ),
                              Positioned(
                                top: 30,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.favorite_rounded,
                                    size: 10,
                                    color: Color(0xFFF87171),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TẠO TÀI KHOẢN',
                                style: AppTextStyles.caption.copyWith(
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : const Color(0xFF9E9E9E),
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              RichText(
                                text: TextSpan(
                                  style: AppTextStyles.heading1.copyWith(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: const [
                                    TextSpan(
                                      text: 'Bắt đầu với ',
                                      style: TextStyle(color: Color(0xFF212121)),
                                    ),
                                    TextSpan(
                                      text: 'NI',
                                      style: TextStyle(color: Color(0xFFF87171)),
                                    ),
                                    TextSpan(
                                      text: 'NO',
                                      style: TextStyle(color: Color(0xFF26A69A)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),

                    const SizedBox(height: 20),

                    // Ý nghĩa của NINO Card
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? AppColors.textSecondaryDark.withValues(alpha: 0.15)
                              : const Color(0xFFEFEFEF),
                        ),
                        boxShadow: isDark
                            ? []
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Card Title
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E2633)
                                  : const Color(0xFFFBFBFB),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            child: RichText(
                              text: TextSpan(
                                style: AppTextStyles.subtitle.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.textSecondaryDark : const Color(0xFF757575),
                                ),
                                children: const [
                                  TextSpan(text: 'Ý nghĩa của '),
                                  TextSpan(
                                    text: 'NI',
                                    style: TextStyle(color: Color(0xFFF87171), fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: 'NO',
                                    style: TextStyle(color: Color(0xFF26A69A), fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const Divider(height: 1, color: Color(0xFFF0F0F0)),

                          // 3 Options
                          ...List.generate(_ninoMeanings.length, (index) {
                            final item = _ninoMeanings[index];
                            final isSelected = _selectedMeaningIndex == index;

                            return Column(
                              children: [
                                InkWell(
                                  onTap: () => setState(() => _selectedMeaningIndex = index),
                                  borderRadius: index == _ninoMeanings.length - 1
                                      ? const BorderRadius.vertical(bottom: Radius.circular(16))
                                      : BorderRadius.zero,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    child: Row(
                                      children: [
                                        // Custom Radio Indicator
                                        Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isSelected
                                                  ? const Color(0xFFF87171)
                                                  : const Color(0xFFCCCCCC),
                                              width: isSelected ? 6 : 1.5,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item['title']!,
                                                style: AppTextStyles.subtitle.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: isDark
                                                      ? AppColors.textPrimaryDark
                                                      : const Color(0xFF212121),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                item['subtitle']!,
                                                style: AppTextStyles.bodySmall.copyWith(
                                                  fontSize: 12,
                                                  color: isDark
                                                      ? AppColors.textSecondaryDark
                                                      : const Color(0xFF757575),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (index < _ninoMeanings.length - 1)
                                  const Divider(height: 1, indent: 50, color: Color(0xFFF5F5F5)),
                              ],
                            );
                          }),
                        ],
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

                    const SizedBox(height: 24),

                    // 4 Benefit Items
                    _buildBenefitRow(
                      icon: Icons.favorite_border_rounded,
                      iconBg: const Color(0xFFFFEBEE),
                      iconColor: const Color(0xFFF87171),
                      text: 'Nhắc nhở sinh nhật & kỷ niệm tự động',
                      checkmarkColor: const Color(0xFFF87171),
                      isDark: isDark,
                    ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1),

                    const SizedBox(height: 16),

                    _buildBenefitRow(
                      icon: Icons.notifications_none_rounded,
                      iconBg: const Color(0xFFE0F2F1),
                      iconColor: const Color(0xFF26A69A),
                      text: 'Thông báo trước 1–7 ngày tuỳ chỉnh',
                      checkmarkColor: const Color(0xFF26A69A),
                      isDark: isDark,
                    ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1),

                    const SizedBox(height: 16),

                    _buildBenefitRow(
                      icon: Icons.star_border_rounded,
                      iconBg: const Color(0xFFFFF8E1),
                      iconColor: const Color(0xFFFBC02D),
                      text: 'Lưu trữ kỷ niệm và ghi chú đặc biệt',
                      checkmarkColor: const Color(0xFFFBC02D),
                      isDark: isDark,
                    ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1),

                    const SizedBox(height: 16),

                    _buildBenefitRow(
                      icon: Icons.card_giftcard_rounded,
                      iconBg: const Color(0xFFF3E5F5),
                      iconColor: const Color(0xFFAB47BC),
                      text: 'Gợi ý quà tặng theo từng dịp',
                      checkmarkColor: const Color(0xFFAB47BC),
                      isDark: isDark,
                    ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.1),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Registration Box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark
                            ? AppColors.textSecondaryDark.withValues(alpha: 0.15)
                            : const Color(0xFFEEEEEE),
                      ),
                      boxShadow: isDark
                          ? []
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Đăng ký miễn phí bằng tài khoản Google — nhanh & bảo mật',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : const Color(0xFF757575),
                            fontSize: 13,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Gradient Google Registration Button
                        Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF87171), Color(0xFF4DB6AC)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF87171).withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isGoogleLoading ? null : _registerWithGoogle,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isGoogleLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const GoogleLogo(size: 20),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Đăng ký với Google',
                                        style: AppTextStyles.subtitle.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Link: Đã có tài khoản? Đăng nhập ngay
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: RichText(
                            text: TextSpan(
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : const Color(0xFF757575),
                                fontSize: 13,
                              ),
                              children: const [
                                TextSpan(text: 'Đã có tài khoản? '),
                                TextSpan(
                                  text: 'Đăng nhập ngay',
                                  style: TextStyle(
                                    color: Color(0xFFF87171),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Footer terms link
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: AppTextStyles.caption.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        fontSize: 11,
                        height: 1.4,
                      ),
                      children: const [
                        TextSpan(text: 'Bằng cách đăng ký, bạn đồng ý với '),
                        TextSpan(
                          text: 'Điều khoản',
                          style: TextStyle(color: Color(0xFF26A69A)),
                        ),
                        TextSpan(text: ' và '),
                        TextSpan(
                          text: 'Chính sách bảo mật',
                          style: TextStyle(color: Color(0xFF26A69A)),
                        ),
                        TextSpan(text: '.'),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
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
    required Color checkmarkColor,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textPrimaryDark : const Color(0xFF333333),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.check_rounded,
          color: checkmarkColor,
          size: 20,
        ),
      ],
    );
  }
}
