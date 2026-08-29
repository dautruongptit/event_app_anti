import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/relative_provider.dart';
import '../../../models/relative.dart';
import '../../widgets/nino/initials_avatar.dart';
import '../../widgets/nino/card_row.dart';
import '../../widgets/nino/sticky_action_bars.dart';
import '../../widgets/nino/nino_toast.dart';

String _formatSpecs(RelativeDetailModel r) {
  final parts = <String>[
    if (r.heightCm != null) '${r.heightCm} cm',
    if (r.weightKg != null) '${r.weightKg} kg',
  ];
  return parts.isEmpty ? '—' : parts.join(' · ');
}

class RelativeDetailScreen extends StatefulWidget {
  final int id;
  const RelativeDetailScreen({super.key, required this.id});

  @override
  State<RelativeDetailScreen> createState() => _RelativeDetailScreenState();
}

class _RelativeDetailScreenState extends State<RelativeDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RelativeProvider>().loadRelativeDetail(widget.id);
    });
  }

  Future<void> _confirmDelete(String name) async {
    final confirmed = await showDeleteConfirmSheet(
      context: context,
      title: 'Xoá $name?',
      message: 'Toàn bộ sự kiện và lời nhắc của người này sẽ bị xoá.',
    );
    if (!confirmed || !mounted) return;
    final success = await context.read<RelativeProvider>().deleteRelative(widget.id);
    if (mounted && success) {
      showNinoToast(context, 'Đã xoá người thân');
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RelativeProvider>();
    final relative = provider.selectedRelative;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final txt = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mut = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final fnt = isDark ? AppColors.textFaintDark : AppColors.textFaintLight;
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final line = isDark ? AppColors.lineDark : AppColors.lineLight;
    final pri = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final priSoft = isDark ? AppColors.primarySoftDark : AppColors.primarySoftLight;
    final mint = isDark ? AppColors.secondaryDark : AppColors.secondaryLight;
    final mintSoft = isDark ? AppColors.secondarySoftDark : AppColors.secondarySoftLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: provider.isLoading || relative == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 26),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: Icon(Icons.chevron_left_rounded, color: txt),
                          style: IconButton.styleFrom(backgroundColor: card, shape: CircleBorder(side: BorderSide(color: line))),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => _confirmDelete(relative.displayName),
                              icon: Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                            ),
                            GestureDetector(
                              onTap: () => context.push('/relatives/${widget.id}/edit'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
                                decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(999), border: Border.all(color: line)),
                                child: Text('Sửa', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: txt)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    InitialsAvatar(name: relative.displayName, color: pri, softColor: priSoft, radius: 40, avatarUrl: relative.avatarUrl),
                    const SizedBox(height: 11),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(relative.displayName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.4, color: txt)),
                        const SizedBox(width: 8),
                        Text('· ${relative.age ?? '?'} tuổi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: mut)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: priSoft, borderRadius: BorderRadius.circular(7)),
                      child: Text(relative.groupTypeDisplay, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: pri)),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(18), border: Border.all(color: line)),
                      child: Column(
                        children: [
                          _infoRow('Giới tính', relative.genderDisplay, mut, txt, line),
                          _infoRow('Ngày sinh', relative.dateOfBirth != null ? DateFormat('dd/MM/yyyy').format(relative.dateOfBirth!) : '—', mut, txt, line),
                          _infoRow('Nơi ở', relative.location ?? '—', mut, txt, line),
                          _infoRow('Thông số', _formatSpecs(relative), mut, txt, line, isLast: relative.hobbies == null || relative.hobbies!.isEmpty),
                          if (relative.hobbies != null && relative.hobbies!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: relative.hobbies!
                                      .map((h) => Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                                            decoration: BoxDecoration(color: mintSoft, borderRadius: BorderRadius.circular(999)),
                                            child: Text(h, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: mint)),
                                          ))
                                      .toList(),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Sự kiện của ${relative.displayName}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: txt)),
                        Text('${relative.relatedEvents.length} sự kiện', style: TextStyle(fontSize: 12, color: fnt)),
                      ],
                    ),
                    const SizedBox(height: 11),
                    if (relative.relatedEvents.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(18), border: Border.all(color: line)),
                        alignment: Alignment.center,
                        child: Text('Chưa có sự kiện nào cho ${relative.displayName}', textAlign: TextAlign.center, style: TextStyle(color: mut)),
                      )
                    else
                      ...relative.relatedEvents.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 9),
                            child: CardRow(
                              leading: SquareIconBadge(icon: e.eventTypeIcon, color: e.categoryColorValue, background: e.categoryColorValue.withValues(alpha: 0.15)),
                              title: e.title,
                              meta: Text(DateFormat('dd/MM/yyyy').format(e.eventDate), style: TextStyle(fontSize: 12, color: mut)),
                              trailing: e.daysUntil != null ? Text(e.daysUntilText, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: mint)) : null,
                            ),
                          )),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => context.push('/events/create?type=relative'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(color: priSoft, borderRadius: BorderRadius.circular(999)),
                          child: Text('＋ Thêm sự kiện', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: pri)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _infoRow(String label, String value, Color mut, Color txt, Color line, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(border: isLast ? null : Border(bottom: BorderSide(color: line))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: mut)),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: txt)),
        ],
      ),
    );
  }
}
