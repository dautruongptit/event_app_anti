import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/vn_holidays.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/event_list_sort.dart';
import '../../../providers/event_provider.dart';
import '../../widgets/nino/card_row.dart';
import '../../widgets/nino/event_owner_chip.dart';
import '../../widgets/nino/pill_tabs.dart';
import '../../widgets/nino/event_sort_sheet.dart';
import '../../widgets/nino/sticky_action_bars.dart';
import '../../widgets/nino/nino_toast.dart';
import '../../widgets/nino/connection_error_dialog.dart';
import '../../../core/network/api_exceptions.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  EventStatusFilter _statusFilter = EventStatusFilter.all;
  EventSortMode _sortMode = EventSortMode.nearest;

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
    final provider = context.read<EventProvider>();
    await provider.loadEvents();
    if (!mounted) return;
    final error = provider.error;
    if (error == null) return;
    if (isNetworkErrorMessage(error)) {
      showConnectionErrorDialog(context, onRetry: _loadAndNotifyOnError);
    } else {
      showNinoToast(context, error);
    }
  }

  // _daysLabel/_ownerChip sống ở event_owner_chip.dart (eventDaysLabel/
  // ownerChip) — dùng chung với màn Chi tiết sự kiện, xem chi tiết ở đó.

  void _onStatusFilterChanged(EventStatusFilter filter) {
    setState(() => _statusFilter = filter);
  }

  Future<void> _openSortSheet() async {
    final result = await showEventSortSheet(context: context, current: _sortMode);
    if (result != null) setState(() => _sortMode = result);
  }

  Future<void> _deleteEvent(BuildContext context, int eventId) async {
    final confirmed = await showDeleteConfirmSheet(
      context: context,
      title: 'Xoá sự kiện này?',
      message: 'Bạn có chắc chắn muốn xoá sự kiện này không?',
    );
    if (confirmed && context.mounted) {
      context.read<EventProvider>().deleteEvent(eventId);
      showNinoToast(context, 'Đã xoá sự kiện');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EventProvider>();
    final allEvents = provider.events;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final txt = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mut = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final fnt = isDark ? AppColors.textFaintDark : AppColors.textFaintLight;
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final line = isDark ? AppColors.lineDark : AppColors.lineLight;
    final pri = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final priSoft = isDark ? AppColors.primarySoftDark : AppColors.primarySoftLight;

    final filteredEvents = EventListSort.filterByStatus(allEvents, _statusFilter);
    final groups = EventListSort.buildGroups(filteredEvents, _sortMode);

    final year = DateTime.now().year;
    final holidays = resolveVnHolidays(year);
    final officialCount = holidays.where((h) => h.def.official).length;
    final offDays = holidays.where((h) => h.def.official).fold<int>(0, (n, h) => n + h.def.officialDaysOff);

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
                  Text('Sự kiện', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.6, color: txt)),
                  GestureDetector(
                    onTap: () => context.push('/events/new'),
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
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Dương lịch & âm lịch trong một dòng thời gian', style: TextStyle(fontSize: 12, color: mut)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: GestureDetector(
                onTap: () => context.push('/events/holidays'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(18), border: Border.all(color: line)),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(color: priSoft, borderRadius: BorderRadius.circular(12)),
                        alignment: Alignment.center,
                        child: const Text('🇻🇳', style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Lịch nghỉ lễ Việt Nam', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: txt)),
                            const SizedBox(height: 2),
                            Text('$officialCount dịp lễ chính · $offDays ngày nghỉ theo quy định $year', style: TextStyle(fontSize: 12, color: mut)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: fnt),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  Expanded(
                    child: FilterChipsRow(
                      labels: EventStatusFilter.values.map((f) => eventStatusFilterLabels[f]!).toList(),
                      selected: eventStatusFilterLabels[_statusFilter]!,
                      onChanged: (label) => _onStatusFilterChanged(
                        EventStatusFilter.values.firstWhere((f) => eventStatusFilterLabels[f] == label),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  EventSortButton(onTap: _openSortSheet),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredEvents.isEmpty
                      ? Center(child: Text('Không có sự kiện nào', style: TextStyle(color: mut)))
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                          itemCount: groups.length,
                          itemBuilder: (context, index) {
                            final group = groups[index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (group.header != null)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    child: Text(group.header!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.8, color: fnt)),
                                  ),
                                ...group.events.map((event) => Padding(
                                      padding: const EdgeInsets.only(bottom: 9),
                                      child: CardRow(
                                        onTap: () => context.push('/events/${event.id}'),
                                        leading: SquareIconBadge(icon: event.eventTypeIcon, color: event.categoryColorValue, background: event.categoryColorValue.withValues(alpha: 0.15)),
                                        title: event.title,
                                        titleTrailing: ownerChip(event, isDark),
                                        meta: Row(
                                          children: [
                                            Flexible(child: Text(AppDateUtils.formatDate(event.eventDate), style: TextStyle(fontSize: 12, color: mut), overflow: TextOverflow.ellipsis)),
                                            if (event.eventTime != null && event.eventTime!.isNotEmpty) ...[
                                              const SizedBox(width: 8),
                                              Text('· ${AppDateUtils.formatTime(event.eventTime)}', style: TextStyle(fontSize: 12, color: mut)),
                                            ],
                                          ],
                                        ),
                                        metaTrailing: eventDaysLabel(event, isDark),
                                        trailing: PopupMenuButton<String>(
                                          // Đã đo pixel thực tế so với ảnh thiết kế: dùng `icon:` (dù
                                          // padding:0) vẫn bọc trong IconButton mặc định có vùng chạm
                                          // tối thiểu ~40dp, đẩy "⋮" vào trong gấp đôi khoảng cách so
                                          // với thiết kế. Dùng `child:` thay vì `icon:` để icon hiện
                                          // đúng kích thước thật (20px), không bị đệm ẩn thêm.
                                          padding: EdgeInsets.zero,
                                          child: Icon(Icons.more_vert_rounded, color: fnt, size: 20),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                          color: card,
                                          onSelected: (v) {
                                            if (v == 'edit') context.push('/events/${event.id}/edit');
                                            if (v == 'delete') _deleteEvent(context, event.id);
                                          },
                                          itemBuilder: (context) => [
                                            PopupMenuItem(
                                              value: 'edit',
                                              child: Row(children: [const Icon(Icons.edit_rounded, size: 18), const SizedBox(width: 10), Text('Chỉnh sửa', style: TextStyle(color: txt))]),
                                            ),
                                            PopupMenuItem(
                                              value: 'delete',
                                              child: Row(children: [const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error), const SizedBox(width: 10), const Text('Xoá', style: TextStyle(color: AppColors.error))]),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )),
                              ],
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
