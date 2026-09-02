import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/relative_provider.dart';
import '../../widgets/nino/initials_avatar.dart';
import '../../widgets/nino/card_row.dart';
import '../../widgets/nino/pill_tabs.dart';
import '../../widgets/nino/nino_toast.dart';
import '../../widgets/nino/connection_error_dialog.dart';
import '../../../core/network/api_exceptions.dart';

class RelativeListScreen extends StatefulWidget {
  const RelativeListScreen({super.key});

  @override
  State<RelativeListScreen> createState() => _RelativeListScreenState();
}

class _RelativeListScreenState extends State<RelativeListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadAndNotifyOnError();
    });
  }

  /// Backend sập/mất mạng: báo ngay thay vì im lặng hiện danh sách rỗng.
  /// Lỗi mất mạng/timeout dùng popup (có nút "Thử lại"), lỗi khác dùng toast.
  Future<void> _loadAndNotifyOnError() async {
    final provider = context.read<RelativeProvider>();
    await provider.loadRelatives();
    provider.loadGroupSummary();
    if (!mounted) return;
    final error = provider.error;
    if (error == null) return;
    if (isNetworkErrorMessage(error)) {
      showConnectionErrorDialog(context, onRetry: _loadAndNotifyOnError);
    } else {
      showNinoToast(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RelativeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final txt = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mut = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final fnt = isDark ? AppColors.textFaintDark : AppColors.textFaintLight;
    final pri = isDark ? AppColors.primaryDark : AppColors.primaryLight;

    final total = provider.groupSummary.fold<int>(0, (sum, s) => sum + s.count);
    // Chip lọc dựng từ các quan hệ THẬT SỰ đang tồn tại ở người thân của
    // user (groupSummary lấy từ backend) — trước đây dùng 1 danh sách cứng
    // (GIA_DINH/VO_CHONG/CON_CAI/BAN_BE) đã lỗi thời, không khớp các quan hệ
    // hiện dùng ở form Thêm/Sửa (Ông/Bà/Bố/Mẹ/...) nên lọc sai/vô nghĩa.
    final filterLabels = ['Tất cả', ...provider.groupSummary.map((s) => s.displayName)];
    final selectedSummary = provider.groupSummary.where((s) => s.groupType == provider.filterGroupType);
    final selectedLabel = provider.filterGroupType == null
        ? 'Tất cả'
        : (selectedSummary.isEmpty ? 'Tất cả' : selectedSummary.first.displayName);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Người thân', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.6, color: txt)),
                  GestureDetector(
                    onTap: () => context.push('/relatives/create'),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: pri,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: pri.withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 6))],
                      ),
                      child: const Icon(Icons.add_rounded, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
              child: Align(alignment: Alignment.centerLeft, child: Text('$total người', style: TextStyle(fontSize: 12, color: mut))),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: FilterChipsRow(
                labels: filterLabels,
                selected: selectedLabel,
                onChanged: (label) {
                  final key = label == 'Tất cả'
                      ? null
                      : provider.groupSummary.firstWhere((s) => s.displayName == label).groupType;
                  context.read<RelativeProvider>().setGroupFilter(key);
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.relatives.isEmpty
                      ? Center(child: Text('Chưa có người thân nào', style: TextStyle(color: mut)))
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                          itemCount: provider.relatives.length,
                          itemBuilder: (context, index) {
                            final rel = provider.relatives[index];
                            final color = isDark
                                ? (AppColors.groupTypeColorsDark[rel.groupType] ?? AppColors.primaryDark)
                                : (AppColors.groupTypeColors[rel.groupType] ?? AppColors.primaryLight);
                            final softColor = isDark
                                ? (AppColors.groupTypeSoftColorsDark[rel.groupType] ?? AppColors.primarySoftDark)
                                : (AppColors.groupTypeSoftColors[rel.groupType] ?? AppColors.primarySoftLight);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 9),
                              child: CardRow(
                                onTap: () => context.push('/relatives/${rel.id}'),
                                leading: InitialsAvatar(name: rel.displayName, color: color, softColor: softColor, radius: 23, avatarUrl: rel.avatarUrl, emoji: rel.groupTypeEmoji),
                                title: rel.displayName,
                                meta: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${rel.genderDisplay} · ${rel.groupTypeDisplay}', style: TextStyle(fontSize: 12, color: fnt)),
                                    if (rel.daysUntilBirthday != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 3),
                                        child: Text('🎂 Sinh nhật còn ${rel.daysUntilBirthday} ngày',
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
                                      ),
                                  ],
                                ),
                                trailing: Icon(Icons.chevron_right_rounded, color: fnt),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
