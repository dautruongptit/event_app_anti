import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/relative_provider.dart';
import '../../widgets/nino/card_row.dart';

/// Icon/nhãn "Quan hệ" theo `groupType` — khớp bảng emoji dùng ở
/// [RelativeFormScreen] để hiển thị nhất quán giữa 2 màn.
const Map<String, (String, String)> _groupTypes = {
  // Nhóm cũ — chỉ còn để hiển thị đúng cho người thân có sẵn.
  'GIA_DINH': ('Gia đình', '👨‍👩‍👧'),
  'CON_CAI': ('Con cái', '👶'),
  'BAN_BE': ('Bạn bè', '👤'),
  // Danh sách quan hệ hiện dùng (khớp picker "Quan hệ với bạn" ở
  // [RelativeFormScreen]).
  'BAN_THAN': ('Bản thân', '🧑'),
  'ONG': ('Ông', '👴'),
  'BA': ('Bà', '👵'),
  'BO': ('Bố', '👨'),
  'ME': ('Mẹ', '👩'),
  'VO_CHONG': ('Vợ (Chồng)', '💍'),
  'ANH_CHI_EM': ('Anh/Chị/Em', '🧒'),
  'CON': ('Con Trai/Con Gái', '👶'),
  'NGUOI_YEU': ('Người yêu', '💕'),
  'NGUOI_THAN': ('Người Thân', '👤'),
};

/// "Thông tin người thân" — màn xem chi tiết. Theo đúng section `isDetail`
/// trong `Nino App.dc.html`: KHÔNG có avatar lớn ở đầu — đi thẳng vào danh
/// sách dòng thông tin dạng icon + nhãn + giá trị (Quan hệ/Tên/Tuổi/Ngày
/// sinh/Giới tính/Sinh nhật/Sở thích), mỗi dòng có thể chạm để mở màn Sửa.
/// Nút Xoá KHÔNG nằm ở đây theo thiết kế — nó thuộc màn Sửa (xem
/// `RelativeFormScreen`, nút "Xoá" chỉ hiện khi `isEditing`).
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
    final mint = isDark ? AppColors.secondaryDark : AppColors.secondaryLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: provider.isLoading || relative == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(6, 4, 14, 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(onPressed: () => context.pop(), icon: Icon(Icons.chevron_left_rounded, color: txt)),
                        Text('Thông tin người thân', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: txt)),
                        const SizedBox(width: 48), // cân đối với nút back để tiêu đề nằm giữa
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 26),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _detailRow(
                            icon: Icons.favorite_border_rounded,
                            label: 'Quan hệ',
                            fnt: fnt,
                            mut: mut,
                            line: line,
                            onTap: () => context.push('/relatives/${widget.id}/edit'),
                            value: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(_groupTypes[relative.groupType]?.$2 ?? '👤', style: const TextStyle(fontSize: 15)),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    relative.groupTypeDisplay,
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: txt),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _detailRow(
                            icon: Icons.person_outline_rounded,
                            label: 'Tên',
                            fnt: fnt,
                            mut: mut,
                            line: line,
                            onTap: () => context.push('/relatives/${widget.id}/edit'),
                            value: Text(relative.displayName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: txt), overflow: TextOverflow.ellipsis),
                          ),
                          _detailRow(
                            icon: Icons.schedule_rounded,
                            label: 'Tuổi',
                            fnt: fnt,
                            mut: mut,
                            line: line,
                            value: Text(relative.age != null ? '${relative.age} tuổi' : '—', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: txt)),
                          ),
                          _detailRow(
                            icon: Icons.calendar_today_rounded,
                            label: 'Ngày sinh',
                            fnt: fnt,
                            mut: mut,
                            line: line,
                            onTap: () => context.push('/relatives/${widget.id}/edit'),
                            value: Text(
                              relative.dateOfBirth != null ? DateFormat('dd/MM/yyyy').format(relative.dateOfBirth!) : '—',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: txt),
                            ),
                          ),
                          const SizedBox(height: 4),
                          _detailRow(
                            icon: Icons.wc_rounded,
                            label: 'Giới tính',
                            fnt: fnt,
                            mut: mut,
                            line: line,
                            onTap: () => context.push('/relatives/${widget.id}/edit'),
                            value: Text(relative.genderDisplay, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: txt)),
                          ),
                          _detailRow(
                            icon: Icons.cake_rounded,
                            label: 'Sinh nhật',
                            fnt: fnt,
                            mut: mut,
                            line: line,
                            value: Text(
                              relative.daysUntilBirthday != null ? 'Còn ${relative.daysUntilBirthday} ngày' : '—',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: pri),
                            ),
                          ),
                          _detailRow(
                            icon: Icons.sell_outlined,
                            label: 'Sở thích',
                            fnt: fnt,
                            mut: mut,
                            line: line,
                            onTap: () => context.push('/relatives/${widget.id}/edit'),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            value: (relative.hobbies == null || relative.hobbies!.isEmpty)
                                ? Text('—', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: txt))
                                : Wrap(
                                    alignment: WrapAlignment.end,
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: relative.hobbies!
                                        .map((h) => Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                                              decoration: BoxDecoration(
                                                color: isDark ? AppColors.secondarySoftDark : AppColors.secondarySoftLight,
                                                borderRadius: BorderRadius.circular(999),
                                              ),
                                              child: Text(h, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: mint)),
                                            ))
                                        .toList(),
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
                          Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              onTap: () => context.push('/events/create?type=relative'),
                              child: Container(
                                margin: const EdgeInsets.only(top: 2),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.primarySoftDark : AppColors.primarySoftLight,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text('＋ Thêm sự kiện', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: pri)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  /// Một dòng thông tin phẳng: icon nhỏ bên trái + nhãn + giá trị (căn phải)
  /// + chevron nếu [onTap] khác null, có viền dưới — khớp cấu trúc dòng của
  /// section `isDetail` trong thiết kế (không bọc khung card như trước).
  Widget _detailRow({
    required IconData icon,
    required String label,
    required Widget value,
    required Color fnt,
    required Color mut,
    required Color line,
    VoidCallback? onTap,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
  }) {
    final content = Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: line))),
      child: Row(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          SizedBox(width: 24, child: Icon(icon, size: 20, color: fnt)),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(fontSize: 15, color: mut)),
          const SizedBox(width: 8),
          Expanded(child: Align(alignment: Alignment.centerRight, child: value)),
          const SizedBox(width: 6),
          SizedBox(
            width: 18,
            child: onTap != null ? Icon(Icons.chevron_right_rounded, size: 18, color: fnt) : null,
          ),
        ],
      ),
    );
    if (onTap == null) return content;
    return InkWell(onTap: onTap, child: content);
  }
}
