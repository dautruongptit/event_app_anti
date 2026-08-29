import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_provider.dart';

class EventTypeSelectionScreen extends StatelessWidget {
  const EventTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final txt = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mut = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final fnt = isDark ? AppColors.textFaintDark : AppColors.textFaintLight;
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final line = isDark ? AppColors.lineDark : AppColors.lineLight;
    final priSoft = isDark ? AppColors.primarySoftDark : AppColors.primarySoftLight;
    final mintSoft = isDark ? AppColors.secondarySoftDark : AppColors.secondarySoftLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 4, 18, 0),
              child: Row(
                children: [
                  IconButton(onPressed: () => context.pop(), icon: Icon(Icons.chevron_left_rounded, color: txt)),
                  Text('Tạo sự kiện mới', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: txt)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 34, 24, 26),
              child: Column(
                children: [
                  Text('Chọn loại sự kiện', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.5, color: txt)),
                  const SizedBox(height: 7),
                  Text('Sự kiện này dành cho ai?', style: TextStyle(fontSize: 14, color: mut)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                children: [
                  _typeCard(
                    context,
                    icon: '👨‍👩‍👧',
                    bg: priSoft,
                    title: 'Liên kết với Người thân',
                    sub: 'Sinh nhật, kỷ niệm, ngày giỗ…',
                    txt: txt,
                    mut: mut,
                    card: card,
                    line: line,
                    onTap: () => context.push('/events/create?type=relative'),
                  ),
                  const SizedBox(height: 13),
                  _typeCard(
                    context,
                    icon: '📅',
                    bg: mintSoft,
                    title: 'Sự kiện cho Bản thân',
                    sub: 'Đóng tiền, thi cử, lịch học, cúng rằm…',
                    txt: txt,
                    mut: mut,
                    card: card,
                    line: line,
                    onTap: () => context.push('/events/create?type=self'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 18),
              child: Text(
                'Sự kiện của người thân sẽ tự gắn vào hồ sơ người đó và nhắc theo lịch của họ.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: fnt, height: 1.55),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeCard(
    BuildContext context, {
    required String icon,
    required Color bg,
    required String title,
    required String sub,
    required Color txt,
    required Color mut,
    required Color card,
    required Color line,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: line),
          boxShadow: [BoxShadow(color: isDark ? AppColors.shadowDark : AppColors.shadowLight, blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Container(width: 62, height: 62, decoration: BoxDecoration(color: bg, shape: BoxShape.circle), alignment: Alignment.center, child: Text(icon, style: const TextStyle(fontSize: 24))),
            const SizedBox(height: 13),
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.3, color: txt)),
            const SizedBox(height: 5),
            Text(sub, style: TextStyle(fontSize: 12, color: mut), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
