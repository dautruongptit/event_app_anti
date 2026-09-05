import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:event_app/core/constants/app_colors.dart';
import 'package:event_app/core/utils/date_utils.dart';
import 'package:event_app/providers/event_provider.dart';
import 'package:event_app/models/event.dart';
import 'package:event_app/ui/widgets/nino/card_row.dart';
import 'package:event_app/ui/widgets/nino/event_owner_chip.dart';
import 'package:event_app/ui/widgets/nino/sticky_action_bars.dart';
import 'package:event_app/ui/widgets/nino/nino_toast.dart';

/// Nhãn "Lặp lại" theo recurrenceType — khớp các key ở
/// EventFormScreen._repeatOptions (WEEKLY/MONTHLY/YEARLY/LUNAR_YEARLY).
const _recurrenceLabels = {
  'WEEKLY': 'Hàng tuần',
  'MONTHLY': 'Hàng tháng',
  'YEARLY': 'Hàng năm',
  'LUNAR_YEARLY': 'Hàng năm (Âm lịch)',
};

/// Màn Chi tiết sự kiện — danh sách phẳng "nhãn : giá trị" phân cách bởi
/// đường kẻ mảnh, khớp thiết kế exports/19-chi-tiet-su-kien.png. Trước đây
/// dùng header gradient + card bo góc (giống Nino cũ); nay đổi hẳn sang
/// layout phẳng để khớp mockup mới nhất.
class EventDetailScreen extends StatefulWidget {
  final int eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().loadEventById(widget.eventId);
    });
  }

  Future<void> _confirmDelete(BuildContext context, EventModel event) async {
    final confirmed = await showDeleteConfirmSheet(
      context: context,
      title: 'Xoá sự kiện này?',
      message: 'Bạn có chắc chắn muốn xoá "${event.title}" không?',
    );
    if (!confirmed || !context.mounted) return;
    final success = await context.read<EventProvider>().deleteEvent(event.id);
    if (!context.mounted) return;
    if (success) {
      showNinoToast(context, 'Đã xoá sự kiện');
      context.pop();
    } else {
      showNinoToast(context, 'Không thể xoá sự kiện');
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();
    final event = eventProvider.selectedEvent;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final txt = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mut = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final line = isDark ? AppColors.lineDark : AppColors.lineLight;
    final pri = isDark ? AppColors.primaryDark : AppColors.primaryLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(context, event, txt, pri),
            Expanded(
              child: eventProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : event == null
                      ? _notFound(context, txt, mut)
                      : _body(event, isDark, txt, mut, line),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context, EventModel? event, Color txt, Color pri) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 4, 18, 4),
      child: Row(
        children: [
          IconButton(onPressed: () => context.pop(), icon: Icon(Icons.chevron_left_rounded, color: txt)),
          Expanded(
            child: Text(
              'Chi tiết sự kiện',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: txt),
            ),
          ),
          if (event != null) ...[
            IconButton(
              onPressed: () => _confirmDelete(context, event),
              icon: Icon(Icons.delete_outline_rounded, color: pri),
            ),
            TextButton(
              onPressed: () => context.push('/events/${event.id}/edit'),
              child: Text('Sửa', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: pri)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _notFound(BuildContext context, Color txt, Color mut) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Không tìm thấy sự kiện', style: TextStyle(fontSize: 15, color: mut)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<EventProvider>().loadEventById(widget.eventId),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _body(EventModel event, bool isDark, Color txt, Color mut, Color line) {
    final categoryColor = event.categoryColorValue;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: icon + tiêu đề + chip chủ sở hữu/ngày
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SquareIconBadge(
                icon: event.eventTypeIcon,
                color: categoryColor,
                background: categoryColor.withValues(alpha: 0.15),
                size: 56,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: txt),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ownerChip(event, isDark),
                        const SizedBox(width: 8),
                        if (eventDaysLabel(event, isDark) != null) eventDaysLabel(event, isDark)!,
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _detailRow(
            icon: Icons.local_offer_outlined,
            label: 'Danh mục',
            value: event.categoryName,
            valueColor: txt,
            mut: mut,
            line: line,
          ),
          _detailRow(
            icon: Icons.person_outline_rounded,
            label: 'Người thân',
            value: event.relativeName ?? 'Không có',
            valueColor: event.relativeName != null ? txt : mut,
            mut: mut,
            line: line,
          ),
          _detailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Ngày',
            value: event.daysUntil == 0 ? 'Hôm nay' : AppDateUtils.formatDate(event.eventDate),
            valueColor: txt,
            mut: mut,
            line: line,
          ),
          _detailRow(
            icon: Icons.access_time_outlined,
            label: 'Giờ',
            value: (event.eventTime == null || event.eventTime!.isEmpty)
                ? 'Cả ngày'
                : AppDateUtils.formatTime(event.eventTime),
            valueColor: txt,
            mut: mut,
            line: line,
          ),
          _detailRow(
            icon: Icons.autorenew_rounded,
            label: 'Lặp lại',
            value: event.isRecurring ? (_recurrenceLabels[event.recurrenceType] ?? 'Định kỳ') : 'Không lặp',
            valueColor: txt,
            mut: mut,
            line: line,
          ),
          _detailRow(
            icon: Icons.notifications_none_rounded,
            label: 'Nhắc nhở',
            value: event.reminders.isEmpty ? 'Không có' : null,
            valueColor: mut,
            valueWidget: event.reminders.isEmpty ? null : _reminderPills(event.reminders, isDark),
            mut: mut,
            line: line,
          ),
          _detailRow(
            icon: Icons.description_outlined,
            label: 'Ghi chú',
            value: (event.notes == null || event.notes!.isEmpty) ? 'Chưa có ghi chú' : event.notes!,
            valueColor: (event.notes == null || event.notes!.isEmpty) ? mut : txt,
            mut: mut,
            line: line,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _reminderPills(List<ReminderModel> reminders, bool isDark) {
    final pri = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final priSoft = isDark ? AppColors.primarySoftDark : AppColors.primarySoftLight;
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 6,
      runSpacing: 6,
      children: reminders.map((r) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: priSoft, borderRadius: BorderRadius.circular(999)),
          child: Text(r.displayText, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: pri)),
        );
      }).toList(),
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String label,
    String? value,
    Widget? valueWidget,
    required Color valueColor,
    required Color mut,
    required Color line,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(border: isLast ? null : Border(bottom: BorderSide(color: line))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: mut),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(fontSize: 15, color: mut)),
          const Spacer(),
          const SizedBox(width: 12),
          Flexible(
            child: Align(
              alignment: Alignment.centerRight,
              child: valueWidget ??
                  Text(
                    value ?? '',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: valueColor),
                    textAlign: TextAlign.right,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
